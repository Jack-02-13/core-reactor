extends Node

signal state_changed

const TUTORIAL_FLAG_IDS: Array[String] = ["energy", "upgrade", "milestone", "prestige"]
const UNLOCK_NOTIFICATION_IDS: Array[String] = ["prestige", "automation", "auto_prestige", "offline_automation", "core_amplification"]

var energy: float = 0.0
var total_energy_earned: float = 0.0
var run_energy_earned: float = 0.0
var highest_energy_per_second: float = 0.0
var total_play_time_seconds: float = 0.0
var current_run_time_seconds: float = 0.0
var total_offline_energy_earned: float = 0.0
var prestige_count: int = 0
var prestige_points: int = 0
var total_prestige_points_earned: int = 0
var normal_levels: Dictionary = {}
var prestige_levels: Dictionary = {}
var master_volume: float = 0.8
var number_format: String = "standard"
var auto_core_enabled: bool = false
var auto_frequency_enabled: bool = false
var auto_efficiency_enabled: bool = false
var auto_strategy: String = "cheapest"
var auto_prestige_enabled: bool = false
var auto_prestige_target_pp: int = BalanceConfig.AUTO_PRESTIGE_DEFAULT_TARGET
var auto_prestige_minimum_run_time: int = BalanceConfig.AUTO_PRESTIGE_DEFAULT_MINIMUM_RUN_TIME
var purchase_quantity_mode: String = "x1"
var last_offline_gain: float = 0.0
var last_offline_seconds: float = 0.0
var last_offline_upgrade_levels_purchased: int = 0
var last_offline_prestige_count: int = 0
var last_offline_prestige_cycles_skipped: int = 0
var last_offline_simulation_seconds: float = 0.0
var initialized: bool = false
var is_new_save: bool = false
var manual_prestige_pending: bool = false
var tutorial_flags: Dictionary = {}
var unlock_notification_flags: Dictionary = {}

var _refresh_accumulator: float = 0.0
var _autosave_accumulator: float = 0.0

func bootstrap() -> void:
	if initialized:
		return
	var data := SaveManager.load_game()
	is_new_save = data.is_empty()
	tutorial_flags = _load_persistent_flags(data.get("tutorial_flags", null), TUTORIAL_FLAG_IDS, not is_new_save)
	energy = maxf(0.0, float(data.get("energy", 0.0)))
	total_energy_earned = maxf(0.0, float(data.get("total_energy_earned", 0.0)))
	run_energy_earned = maxf(0.0, float(data.get("run_energy_earned", 0.0)))
	total_play_time_seconds = maxf(0.0, float(data.get("total_play_time_seconds", 0.0)))
	current_run_time_seconds = maxf(0.0, float(data.get("current_run_time_seconds", 0.0)))
	total_offline_energy_earned = maxf(0.0, float(data.get("total_offline_energy_earned", 0.0)))
	prestige_count = maxi(0, int(data.get("prestige_count", 0)))
	prestige_points = maxi(0, int(data.get("prestige_points", 0)))
	total_prestige_points_earned = maxi(0, int(data.get("total_prestige_points_earned", prestige_points)))
	normal_levels = _validated_levels(data.get("normal_levels", {}), UpgradeManager.get_upgrade_ids())
	prestige_levels = PrestigeManager.migrate_saved_levels(data.get("prestige_levels", {}))
	unlock_notification_flags = _load_unlock_flags(data)
	var settings: Dictionary = data.get("settings", {})
	master_volume = clampf(float(settings.get("master_volume", 0.8)), 0.0, 1.0)
	number_format = _normalize_number_format(str(settings.get("number_format", "standard")))
	purchase_quantity_mode = _normalize_purchase_mode(str(settings.get("purchase_quantity_mode", "x1")))
	var legacy_auto_optimize_enabled := bool(data.get("auto_optimize_enabled", false))
	auto_core_enabled = bool(data.get("auto_core_enabled", false))
	auto_frequency_enabled = bool(data.get("auto_frequency_enabled", legacy_auto_optimize_enabled))
	auto_efficiency_enabled = bool(data.get("auto_efficiency_enabled", legacy_auto_optimize_enabled))
	auto_strategy = _normalize_auto_strategy(str(data.get("auto_strategy", "cheapest")))
	auto_prestige_enabled = bool(data.get("auto_prestige_enabled", false))
	auto_prestige_target_pp = _normalize_auto_prestige_target(int(data.get("auto_prestige_target_pp", BalanceConfig.AUTO_PRESTIGE_DEFAULT_TARGET)))
	auto_prestige_minimum_run_time = _normalize_auto_prestige_minimum(int(data.get("auto_prestige_minimum_run_time", BalanceConfig.AUTO_PRESTIGE_DEFAULT_MINIMUM_RUN_TIME)))
	if legacy_auto_optimize_enabled and PrestigeManager.get_node_rank("smart_auto") > 0:
		auto_core_enabled = true
		auto_frequency_enabled = true
		auto_efficiency_enabled = true
	if PrestigeManager.get_node_rank("auto_core") <= 0:
		auto_core_enabled = false
	if PrestigeManager.get_node_rank("auto_frequency") <= 0:
		auto_frequency_enabled = false
	if PrestigeManager.get_node_rank("auto_efficiency") <= 0:
		auto_efficiency_enabled = false
	if PrestigeManager.get_node_rank("auto_prestige") <= 0:
		auto_prestige_enabled = false

	highest_energy_per_second = maxf(0.0, float(data.get("highest_energy_per_second", 0.0)))
	highest_energy_per_second = maxf(highest_energy_per_second, get_energy_per_second())
	initialized = true
	var saved_at := float(data.get("saved_at", 0.0))
	var now := float(Time.get_unix_time_from_system())
	if saved_at > 0.0:
		last_offline_seconds = minf(maxf(0.0, now - saved_at), PrestigeManager.offline_time_cap_seconds())
		if PrestigeManager.get_node_rank("offline_automation") > 0 or (PrestigeManager.get_node_rank("auto_prestige") > 0 and auto_prestige_enabled):
			var offline_start_usec := Time.get_ticks_usec()
			last_offline_gain = _simulate_offline_events(last_offline_seconds)
			last_offline_simulation_seconds = float(Time.get_ticks_usec() - offline_start_usec) / 1000000.0
		else:
			last_offline_gain = get_energy_per_second() * PrestigeManager.offline_efficiency() * PrestigeManager.offline_production_multiplier() * last_offline_seconds
			if last_offline_gain > 0.0:
				energy += last_offline_gain
				total_energy_earned += last_offline_gain
				run_energy_earned += last_offline_gain
				total_offline_energy_earned += last_offline_gain
			current_run_time_seconds += last_offline_seconds
	notify_state_changed()
	save_now()

func _process(delta: float) -> void:
	if not initialized:
		return
	var gain := get_energy_production_gain(delta)
	if gain > 0.0:
		energy += gain
		total_energy_earned += gain
		run_energy_earned += gain
		current_run_time_seconds += delta
	total_play_time_seconds += delta
	if PrestigeManager.can_auto_prestige() and not manual_prestige_pending:
		PrestigeManager.perform_prestige(true, true)
	highest_energy_per_second = maxf(highest_energy_per_second, get_energy_per_second())
	_refresh_accumulator += delta
	_autosave_accumulator += delta
	if _refresh_accumulator >= 0.25:
		_refresh_accumulator = fmod(_refresh_accumulator, 0.25)
		state_changed.emit()
	if _autosave_accumulator >= 10.0:
		_autosave_accumulator = 0.0
		save_now()

func get_energy_per_second() -> float:
	return calculate_energy_per_second(normal_levels)

func calculate_energy_per_second(levels: Dictionary) -> float:
	return calculate_base_energy_per_second(levels) * PrestigeManager.critical_output_expected_multiplier()

func calculate_base_energy_per_second(levels: Dictionary) -> float:
	var core_level := int(levels.get("core_power", 0))
	var frequency_level := int(levels.get("reactor_speed", 0))
	var efficiency_level := int(levels.get("efficiency", 0))
	var core_effect := 1.0 + float(core_level)
	var frequency_effect := (1.0 + float(frequency_level) * BalanceConfig.FREQUENCY_PER_LEVEL) * PrestigeManager.frequency_multiplier()
	var efficiency_effect := 1.0 + float(efficiency_level) * BalanceConfig.EFFICIENCY_PER_LEVEL
	var milestone_multiplier := UpgradeManager.get_milestone_multiplier(levels)
	return BalanceConfig.BASE_PRODUCTION * core_effect * frequency_effect * efficiency_effect * milestone_multiplier * PrestigeManager.production_multiplier()

func get_energy_production_gain(delta: float) -> float:
	var gain := calculate_base_energy_per_second(normal_levels) * delta
	if randf() < PrestigeManager.critical_output_chance():
		gain *= BalanceConfig.CRITICAL_OUTPUT_MULTIPLIER
	return gain

func _simulate_offline_events(offline_seconds: float) -> float:
	if offline_seconds <= 0.0:
		return 0.0
	var starting_total := total_energy_earned
	var remaining := offline_seconds
	var auto_prestiges := 0
	var iterations := 0
	var offline_levels_purchased := 0
	last_offline_prestige_cycles_skipped = 0
	var offline_auto_enabled := PrestigeManager.get_node_rank("offline_automation") > 0
	var auto_prestige_unlimited := PrestigeManager.get_node_rank("auto_prestige") > 0 and auto_prestige_enabled
	var cycle_anchor := _make_offline_cycle_anchor(offline_seconds, 0, 0.0, 0.0, 0)
	var previous_cycle: Dictionary = {}
	while remaining > 0.000001 and iterations < 1000000:
		iterations += 1
		if offline_auto_enabled:
			var purchased_now := UpgradeManager.purchase_offline_batches()
			if purchased_now > 0:
				offline_levels_purchased += purchased_now
				continue
		var rate := get_energy_per_second() * PrestigeManager.offline_efficiency() * PrestigeManager.offline_production_multiplier()
		if not is_finite(rate) or rate <= 0.0:
			break
		var time_to_upgrade := INF
		if offline_auto_enabled:
			var next_cost := UpgradeManager.get_next_auto_cost()
			if is_finite(next_cost):
				time_to_upgrade = maxf(0.0, next_cost - energy) / rate
		var time_to_prestige := INF
		if auto_prestige_unlimited and auto_prestiges < BalanceConfig.MAX_OFFLINE_PRESTIGES_PER_SIMULATION:
			var target_energy := BalanceConfig.PRESTIGE_FIRST_THRESHOLD * pow(float(auto_prestige_target_pp), 1.0 / BalanceConfig.PRESTIGE_POINT_EXPONENT)
			# Step just beyond the mathematical boundary so floor(pow(...)) is
			# stable across floating-point evaluation paths.
			target_energy += maxf(0.000001, target_energy * 0.000000000001)
			var time_for_energy := maxf(0.0, target_energy - run_energy_earned) / rate
			var time_for_minimum := maxf(0.0, float(auto_prestige_minimum_run_time) - current_run_time_seconds)
			time_to_prestige = maxf(time_for_energy, time_for_minimum)
		var step := minf(remaining, minf(time_to_upgrade, time_to_prestige))
		if not is_finite(step):
			step = remaining
		if step <= 0.0000001:
			var did_work := false
			if offline_auto_enabled:
				var bought_now := UpgradeManager.purchase_offline_batches()
				if bought_now > 0:
					offline_levels_purchased += bought_now
					did_work = true
			if not did_work and auto_prestige_unlimited and auto_prestiges < BalanceConfig.MAX_OFFLINE_PRESTIGES_PER_SIMULATION and PrestigeManager.can_auto_prestige():
				var reward := PrestigeManager.get_available_reward()
				PrestigeManager.perform_prestige(false, true)
				auto_prestiges += 1
				var cycle_result := _record_and_maybe_batch_offline_cycle(cycle_anchor, previous_cycle, offline_seconds, remaining, auto_prestiges, offline_levels_purchased, reward)
				previous_cycle = cycle_result["profile"]
				remaining = float(cycle_result["remaining"])
				auto_prestiges = int(cycle_result["auto_prestiges"])
				offline_levels_purchased = int(cycle_result["levels_bought"])
				cycle_anchor = _make_offline_cycle_anchor(offline_seconds, auto_prestiges, remaining, total_energy_earned, offline_levels_purchased)
				did_work = true
			if did_work:
				continue
			if offline_auto_enabled:
				var stalled_cost := UpgradeManager.get_next_auto_cost()
				if is_finite(stalled_cost) and stalled_cost <= energy:
					offline_auto_enabled = false
			step = minf(remaining, 0.00001)
		var gain := rate * step
		energy += gain
		run_energy_earned += gain
		total_energy_earned += gain
		total_offline_energy_earned += gain
		current_run_time_seconds += step
		remaining -= step
		if offline_auto_enabled:
			var bought_after_step := UpgradeManager.purchase_offline_batches()
			offline_levels_purchased += bought_after_step
		if auto_prestige_unlimited and auto_prestiges < BalanceConfig.MAX_OFFLINE_PRESTIGES_PER_SIMULATION and PrestigeManager.can_auto_prestige():
			var reward_after_step := PrestigeManager.get_available_reward()
			PrestigeManager.perform_prestige(false, true)
			auto_prestiges += 1
			var cycle_result := _record_and_maybe_batch_offline_cycle(cycle_anchor, previous_cycle, offline_seconds, remaining, auto_prestiges, offline_levels_purchased, reward_after_step)
			previous_cycle = cycle_result["profile"]
			remaining = float(cycle_result["remaining"])
			auto_prestiges = int(cycle_result["auto_prestiges"])
			offline_levels_purchased = int(cycle_result["levels_bought"])
			cycle_anchor = _make_offline_cycle_anchor(offline_seconds, auto_prestiges, remaining, total_energy_earned, offline_levels_purchased)
	if remaining > 0.000001:
		push_warning("Offline event limit reached; remaining time was credited at the current production rate.")
		var fallback_rate := get_energy_per_second() * PrestigeManager.offline_efficiency() * PrestigeManager.offline_production_multiplier()
		var fallback_gain := fallback_rate * remaining
		energy += fallback_gain
		run_energy_earned += fallback_gain
		total_energy_earned += fallback_gain
		total_offline_energy_earned += fallback_gain
		current_run_time_seconds += remaining
	last_offline_upgrade_levels_purchased = offline_levels_purchased
	last_offline_prestige_count = auto_prestiges
	return total_energy_earned - starting_total

func _offline_cycle_signature() -> String:
	return JSON.stringify({
		"energy": energy,
		"run_energy": run_energy_earned,
		"run_time": current_run_time_seconds,
		"normal": normal_levels,
		"prestige": prestige_levels,
		"auto": [auto_core_enabled, auto_frequency_enabled, auto_efficiency_enabled, auto_strategy],
		"auto_prestige": [auto_prestige_enabled, auto_prestige_target_pp, auto_prestige_minimum_run_time]
	})

func _make_offline_cycle_anchor(total_seconds: float, prestige_count_at_anchor: int, remaining_at_anchor: float, energy_total: float, levels_bought: int) -> Dictionary:
	return {
		"signature": _offline_cycle_signature(),
		"elapsed": total_seconds - remaining_at_anchor,
		"total_energy": energy_total,
		"offline_energy": total_offline_energy_earned,
		"pp": prestige_points,
		"pp_earned": total_prestige_points_earned,
		"levels_bought": levels_bought,
		"prestige_count": prestige_count_at_anchor
	}

func _record_and_maybe_batch_offline_cycle(anchor: Dictionary, previous_cycle: Dictionary, total_seconds: float, remaining: float, prestige_count_now: int, levels_bought: int, reward: int) -> Dictionary:
	var elapsed_now := total_seconds - remaining
	var duration := elapsed_now - float(anchor.get("elapsed", elapsed_now))
	var signature := _offline_cycle_signature()
	var spent_points := int(anchor.get("pp", prestige_points)) + reward - prestige_points
	var profile: Dictionary = {}
	if duration > 0.0 and signature == str(anchor.get("signature", "")) and spent_points == 0:
		profile = {
			"signature": signature,
			"duration": duration,
			"energy": total_energy_earned - float(anchor.get("total_energy", total_energy_earned)),
			"offline_energy": total_offline_energy_earned - float(anchor.get("offline_energy", total_offline_energy_earned)),
			"reward": reward,
			"levels_bought": levels_bought - int(anchor.get("levels_bought", levels_bought))
		}
		if _offline_cycles_match(previous_cycle, profile):
			var available_by_time := int(floor((remaining + 0.000001) / duration))
			var available_by_safety := maxi(0, BalanceConfig.MAX_OFFLINE_PRESTIGES_PER_SIMULATION - prestige_count_now)
			var cycles_to_skip := mini(available_by_time, available_by_safety)
			if cycles_to_skip > 0:
				total_energy_earned += float(profile["energy"]) * cycles_to_skip
				total_offline_energy_earned += float(profile["offline_energy"]) * cycles_to_skip
				total_prestige_points_earned += int(profile["reward"]) * cycles_to_skip
				prestige_points += int(profile["reward"]) * cycles_to_skip
				prestige_count += cycles_to_skip
				levels_bought += int(profile["levels_bought"]) * cycles_to_skip
				prestige_count_now += cycles_to_skip
				last_offline_prestige_cycles_skipped += cycles_to_skip
				remaining -= duration * cycles_to_skip
	return {"profile": profile, "remaining": remaining, "auto_prestiges": prestige_count_now, "levels_bought": levels_bought}

func _offline_cycles_match(first: Dictionary, second: Dictionary) -> bool:
	if first.is_empty() or second.is_empty() or first.get("signature") != second.get("signature"):
		return false
	if int(first.get("reward", 0)) != int(second.get("reward", 0)) or int(first.get("levels_bought", -1)) != int(second.get("levels_bought", -2)):
		return false
	return is_equal_approx(float(first.get("duration", -1.0)), float(second.get("duration", -2.0))) and is_equal_approx(float(first.get("energy", -1.0)), float(second.get("energy", -2.0))) and is_equal_approx(float(first.get("offline_energy", -1.0)), float(second.get("offline_energy", -2.0)))

func get_offline_reward_seconds() -> float:
	return last_offline_seconds

func reset_normal_upgrades() -> void:
	normal_levels.clear()
	for upgrade_id in UpgradeManager.get_upgrade_ids():
		normal_levels[upgrade_id] = 0

func notify_state_changed() -> void:
	if initialized:
		highest_energy_per_second = maxf(highest_energy_per_second, get_energy_per_second())
	state_changed.emit()

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(master_volume, 0.0001)))
		AudioServer.set_bus_mute(bus_index, master_volume <= 0.001)
	notify_state_changed()
	save_now()

func set_number_format(value: String) -> void:
	number_format = _normalize_number_format(value)
	notify_state_changed()
	save_now()

func set_purchase_quantity_mode(value: String) -> void:
	purchase_quantity_mode = _normalize_purchase_mode(value)
	notify_state_changed()
	save_now()

func set_auto_core_enabled(value: bool) -> void:
	auto_core_enabled = value and PrestigeManager.get_node_rank("auto_core") > 0
	notify_state_changed()
	save_now()

func set_auto_frequency_enabled(value: bool) -> void:
	auto_frequency_enabled = value and PrestigeManager.get_node_rank("auto_frequency") > 0
	notify_state_changed()
	save_now()

func set_auto_efficiency_enabled(value: bool) -> void:
	auto_efficiency_enabled = value and PrestigeManager.get_node_rank("auto_efficiency") > 0
	notify_state_changed()
	save_now()

func set_auto_strategy(value: String) -> void:
	auto_strategy = _normalize_auto_strategy(value)
	notify_state_changed()
	save_now()

func set_auto_prestige_enabled(value: bool) -> void:
	auto_prestige_enabled = value and PrestigeManager.get_node_rank("auto_prestige") > 0
	notify_state_changed()
	save_now()

func set_auto_prestige_target(value: int) -> void:
	auto_prestige_target_pp = _normalize_auto_prestige_target(value)
	notify_state_changed()
	save_now()

func set_auto_prestige_minimum_run_time(value: int) -> void:
	auto_prestige_minimum_run_time = _normalize_auto_prestige_minimum(value)
	notify_state_changed()
	save_now()

func get_selected_purchase_quantity(upgrade_id: String = "") -> int:
	match purchase_quantity_mode:
		"x10":
			return 10
		"max":
			return UpgradeManager.get_max_affordable_count(upgrade_id) if not upgrade_id.is_empty() else -1
	return 1

func save_now() -> void:
	if initialized:
		SaveManager.save_game(to_save_data())

func mark_tutorial_seen(flag_id: String) -> void:
	if not TUTORIAL_FLAG_IDS.has(flag_id) or bool(tutorial_flags.get(flag_id, true)):
		return
	tutorial_flags[flag_id] = true
	save_now()

func mark_unlock_notified(flag_id: String) -> void:
	if not UNLOCK_NOTIFICATION_IDS.has(flag_id) or bool(unlock_notification_flags.get(flag_id, true)):
		return
	unlock_notification_flags[flag_id] = true
	save_now()

func to_save_data() -> Dictionary:
	return {
		"save_version": BalanceConfig.SAVE_VERSION,
		"energy": energy,
		"total_energy_earned": total_energy_earned,
		"run_energy_earned": run_energy_earned,
		"highest_energy_per_second": highest_energy_per_second,
		"total_play_time_seconds": total_play_time_seconds,
		"current_run_time_seconds": current_run_time_seconds,
		"total_offline_energy_earned": total_offline_energy_earned,
		"prestige_count": prestige_count,
		"prestige_points": prestige_points,
		"total_prestige_points_earned": total_prestige_points_earned,
		"normal_levels": normal_levels.duplicate(true),
		"prestige_levels": prestige_levels.duplicate(true),
		"auto_core_enabled": auto_core_enabled,
		"auto_frequency_enabled": auto_frequency_enabled,
		"auto_efficiency_enabled": auto_efficiency_enabled,
		"auto_strategy": auto_strategy,
		"auto_prestige_enabled": auto_prestige_enabled,
		"auto_prestige_target_pp": auto_prestige_target_pp,
		"auto_prestige_minimum_run_time": auto_prestige_minimum_run_time,
		"tutorial_flags": tutorial_flags.duplicate(true),
		"unlock_notification_flags": unlock_notification_flags.duplicate(true),
		"settings": {
			"master_volume": master_volume,
			"number_format": number_format,
			"purchase_quantity_mode": purchase_quantity_mode
		},
		"saved_at": Time.get_unix_time_from_system()
	}

func _validated_levels(source: Variant, ids: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	var input: Dictionary = source if typeof(source) == TYPE_DICTIONARY else {}
	for key in ids:
		result[key] = maxi(0, int(input.get(key, 0)))
	return result

func _load_persistent_flags(source: Variant, ids: Array[String], default_value: bool) -> Dictionary:
	var result: Dictionary = {}
	var input: Dictionary = source if typeof(source) == TYPE_DICTIONARY else {}
	for flag_id in ids:
		result[flag_id] = bool(input.get(flag_id, default_value))
	return result

func _load_unlock_flags(data: Dictionary) -> Dictionary:
	var stored: Variant = data.get("unlock_notification_flags", null)
	if typeof(stored) == TYPE_DICTIONARY:
		return _load_persistent_flags(stored, UNLOCK_NOTIFICATION_IDS, false)
	var result := _load_persistent_flags(null, UNLOCK_NOTIFICATION_IDS, false)
	# Older saves have already seen every feature they previously owned.
	if not data.is_empty():
		result["prestige"] = prestige_count > 0 or PrestigeManager.get_available_reward() > 0
		result["automation"] = PrestigeManager.get_node_rank("auto_core") > 0
		result["auto_prestige"] = PrestigeManager.get_node_rank("auto_prestige") > 0
		result["offline_automation"] = PrestigeManager.get_node_rank("offline_automation") > 0
		result["core_amplification"] = PrestigeManager.get_node_rank("core_amplification") > 0
	return result

func _normalize_number_format(value: String) -> String:
	return "scientific" if value in ["scientific", "full"] else "standard"

func _normalize_purchase_mode(value: String) -> String:
	return "x10" if value == "x10" else ("max" if value == "max" else "x1")

func _normalize_auto_strategy(value: String) -> String:
	return "balanced" if value == "balanced" else "cheapest"

func _normalize_auto_prestige_target(value: int) -> int:
	return value if value in BalanceConfig.AUTO_PRESTIGE_TARGETS else BalanceConfig.AUTO_PRESTIGE_DEFAULT_TARGET

func _normalize_auto_prestige_minimum(value: int) -> int:
	return value if value in BalanceConfig.AUTO_PRESTIGE_MINIMUM_RUN_TIMES else BalanceConfig.AUTO_PRESTIGE_DEFAULT_MINIMUM_RUN_TIME
