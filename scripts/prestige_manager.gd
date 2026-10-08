extends Node

signal prestige_performed(reward: int, is_auto: bool)
signal node_unlocked(node_id: String)

const BRANCHES := {
	"production": ["reactor_mastery", "overdrive", "critical_output", "core_amplification"],
	"automation": ["auto_core", "auto_frequency", "auto_efficiency", "smart_auto", "auto_prestige", "offline_automation"],
	"offline": ["offline_efficiency", "offline_capacity", "offline_boost"]
}
const NODE_ORDER: Array[String] = [
	"reactor_mastery", "overdrive", "critical_output", "core_amplification",
	"auto_core", "auto_frequency", "auto_efficiency", "smart_auto", "auto_prestige", "offline_automation",
	"offline_efficiency", "offline_capacity", "offline_boost"
]
const MAX_INT_COST := 9223372036854775807

func get_branch_ids() -> Array[String]:
	var result: Array[String] = []
	for branch_id in BRANCHES:
		result.append(branch_id)
	return result

func get_branch_nodes(branch_id: String) -> Array:
	var nodes: Array = BRANCHES.get(branch_id, [])
	return nodes.duplicate()

func get_node_ids() -> Array[String]:
	return NODE_ORDER.duplicate()

func get_node_rank(node_id: String) -> int:
	return int(GameManager.prestige_levels.get(node_id, 0))

func get_node_max_rank(node_id: String) -> int:
	match node_id:
		"reactor_mastery":
			return BalanceConfig.REACTOR_MASTERY_MAX_LEVEL
		"overdrive":
			return BalanceConfig.OVERDRIVE_MAX_LEVEL
		"critical_output":
			return BalanceConfig.CRITICAL_OUTPUT_MAX_LEVEL
		"core_amplification":
			return -1
		"auto_core", "auto_frequency", "auto_efficiency", "smart_auto":
			return 1
		"auto_prestige", "offline_automation":
			return 1
		"offline_efficiency":
			return BalanceConfig.OFFLINE_EFFICIENCY_MAX_LEVEL
		"offline_capacity":
			return BalanceConfig.OFFLINE_CAPACITY_MAX_LEVEL
		"offline_boost":
			return BalanceConfig.OFFLINE_BOOST_MAX_LEVEL
	return 0

func get_node_cost(node_id: String) -> int:
	var rank := get_node_rank(node_id)
	var max_rank := get_node_max_rank(node_id)
	if max_rank >= 0 and rank >= max_rank:
		return 2147483647
	match node_id:
		"reactor_mastery":
			return BalanceConfig.REACTOR_MASTERY_COST_BASE + rank
		"overdrive":
			return BalanceConfig.OVERDRIVE_COSTS[rank]
		"critical_output":
			return BalanceConfig.CRITICAL_OUTPUT_COSTS[rank]
		"core_amplification":
			var log_cost := log(BalanceConfig.CORE_AMPLIFICATION_COST_BASE) + float(rank) * log(BalanceConfig.CORE_AMPLIFICATION_COST_GROWTH)
			if log_cost >= log(float(MAX_INT_COST)):
				return MAX_INT_COST
			var raw_cost := BalanceConfig.CORE_AMPLIFICATION_COST_BASE * pow(BalanceConfig.CORE_AMPLIFICATION_COST_GROWTH, rank)
			return ceili(raw_cost)
		"auto_core":
			return BalanceConfig.AUTO_CORE_COST
		"auto_frequency":
			return BalanceConfig.AUTO_FREQUENCY_COST
		"auto_efficiency":
			return BalanceConfig.AUTO_EFFICIENCY_COST
		"smart_auto":
			return BalanceConfig.SMART_AUTO_COST
		"auto_prestige":
			return BalanceConfig.AUTO_PRESTIGE_COST
		"offline_automation":
			return BalanceConfig.OFFLINE_AUTOMATION_COST
		"offline_efficiency":
			return BalanceConfig.OFFLINE_EFFICIENCY_COSTS[rank]
		"offline_capacity":
			return BalanceConfig.OFFLINE_CAPACITY_COSTS[rank]
		"offline_boost":
			return BalanceConfig.OFFLINE_BOOST_COSTS[rank]
	return 2147483647

func can_purchase_node(node_id: String) -> bool:
	var max_rank := get_node_max_rank(node_id)
	if max_rank >= 0 and get_node_rank(node_id) >= max_rank:
		return false
	if node_id == "core_amplification" and get_node_cost(node_id) == MAX_INT_COST:
		return false
	if node_id == "core_amplification" and get_node_rank("reactor_mastery") < BalanceConfig.REACTOR_MASTERY_MAX_LEVEL:
		return false
	if node_id == "auto_prestige" and (get_node_rank("smart_auto") <= 0 or get_node_rank("reactor_mastery") < 5):
		return false
	if node_id == "offline_automation" and (get_node_rank("auto_core") <= 0 or get_node_rank("auto_frequency") <= 0 or get_node_rank("auto_efficiency") <= 0):
		return false
	return GameManager.prestige_points >= get_node_cost(node_id)

func get_available_reward() -> int:
	var run_total := maxf(0.0, GameManager.run_energy_earned)
	if run_total < BalanceConfig.PRESTIGE_FIRST_THRESHOLD:
		return 0
	return maxi(1, int(floor(pow(run_total / BalanceConfig.PRESTIGE_FIRST_THRESHOLD, BalanceConfig.PRESTIGE_POINT_EXPONENT))))

func get_next_point_total() -> float:
	var next_reward := get_available_reward() + 1
	return BalanceConfig.PRESTIGE_FIRST_THRESHOLD * pow(float(next_reward), 1.0 / BalanceConfig.PRESTIGE_POINT_EXPONENT)

func get_energy_until_next_point() -> float:
	return maxf(0.0, get_next_point_total() - GameManager.run_energy_earned)

func purchase_node(node_id: String) -> bool:
	if not can_purchase_node(node_id):
		return false
	var old_rank := get_node_rank(node_id)
	GameManager.prestige_points -= get_node_cost(node_id)
	GameManager.prestige_levels[node_id] = get_node_rank(node_id) + 1
	GameManager.notify_state_changed()
	GameManager.save_now()
	if old_rank == 0:
		node_unlocked.emit(node_id)
	return true

func production_multiplier() -> float:
	var mastery := 1.0 + float(get_node_rank("reactor_mastery")) * BalanceConfig.REACTOR_MASTERY_PER_LEVEL
	var amplification := 1.0 + float(get_node_rank("core_amplification")) * BalanceConfig.CORE_AMPLIFICATION_PER_LEVEL
	return mastery * amplification

func can_auto_prestige() -> bool:
	return get_node_rank("auto_prestige") > 0 and GameManager.auto_prestige_enabled and get_available_reward() >= GameManager.auto_prestige_target_pp and GameManager.current_run_time_seconds >= GameManager.auto_prestige_minimum_run_time

func frequency_multiplier() -> float:
	return 1.0 + float(get_node_rank("overdrive")) * BalanceConfig.OVERDRIVE_FREQUENCY_BONUS_PER_LEVEL

func critical_output_chance() -> float:
	return minf(1.0, float(get_node_rank("critical_output")) * BalanceConfig.CRITICAL_OUTPUT_CHANCE_PER_LEVEL)

func critical_output_expected_multiplier() -> float:
	return 1.0 + critical_output_chance() * (BalanceConfig.CRITICAL_OUTPUT_MULTIPLIER - 1.0)

func offline_efficiency() -> float:
	return minf(1.0, BalanceConfig.OFFLINE_EFFICIENCY_BASE + float(get_node_rank("offline_efficiency")) * BalanceConfig.OFFLINE_EFFICIENCY_PER_LEVEL)

func offline_time_cap_seconds() -> float:
	var hours := BalanceConfig.OFFLINE_CAPACITY_BASE_HOURS + float(get_node_rank("offline_capacity")) * BalanceConfig.OFFLINE_CAPACITY_HOURS_PER_LEVEL
	return hours * 3600.0

func offline_production_multiplier() -> float:
	return 1.0 + float(get_node_rank("offline_boost")) * BalanceConfig.OFFLINE_BOOST_PER_LEVEL

func perform_prestige(save_after: bool = true, is_auto: bool = false) -> int:
	var reward := get_available_reward()
	if reward <= 0:
		return 0
	GameManager.prestige_points += reward
	GameManager.total_prestige_points_earned += reward
	GameManager.prestige_count += 1
	GameManager.energy = 0.0
	GameManager.run_energy_earned = 0.0
	GameManager.current_run_time_seconds = 0.0
	GameManager.reset_normal_upgrades()
	GameManager.notify_state_changed()
	prestige_performed.emit(reward, is_auto)
	if save_after:
		GameManager.save_now()
	return reward

func migrate_saved_levels(source: Variant) -> Dictionary:
	var input: Dictionary = source if typeof(source) == TYPE_DICTIONARY else {}
	var result: Dictionary = {}
	for node_id in NODE_ORDER:
		var level := maxi(0, int(input.get(node_id, 0)))
		var max_rank := get_node_max_rank(node_id)
		result[node_id] = mini(level, max_rank) if max_rank >= 0 else level

	if not input.has("reactor_mastery"):
		result["reactor_mastery"] = clampi(int(input.get("production", 0)), 0, BalanceConfig.REACTOR_MASTERY_MAX_LEVEL)
	if not input.has("auto_core"):
		result["auto_core"] = 1 if int(input.get("automation", 0)) >= 1 else 0

	# Older saves used one Auto Optimize node for all three ordinary upgrades.
	# Carry its unlock forward to the replacement individual toggles and strategy node.
	var legacy_optimize_rank := int(input.get("auto_optimize", 0))
	if legacy_optimize_rank <= 0 and int(input.get("automation", 0)) >= 2:
		legacy_optimize_rank = 1
	if legacy_optimize_rank > 0 and not input.has("smart_auto"):
		for node_id in ["auto_core", "auto_frequency", "auto_efficiency", "smart_auto"]:
			result[node_id] = 1

	if not input.has("offline_efficiency"):
		result["offline_efficiency"] = clampi(int(input.get("offline", 0)), 0, BalanceConfig.OFFLINE_EFFICIENCY_MAX_LEVEL)
	return result
