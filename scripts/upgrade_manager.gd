extends Node

var _automation_accumulator := 0.0

func get_upgrade_ids() -> Array[String]:
	return BalanceConfig.UPGRADE_ORDER.duplicate()

func get_definition(upgrade_id: String) -> Dictionary:
	if not BalanceConfig.UPGRADE_DEFINITIONS.has(upgrade_id):
		return {}
	var definition: Dictionary = BalanceConfig.UPGRADE_DEFINITIONS[upgrade_id].duplicate(true)
	definition["id"] = upgrade_id
	return definition

func get_cost(upgrade_id: String, level: int = -1) -> float:
	var definition := get_definition(upgrade_id)
	if definition.is_empty():
		return INF
	var current_level := int(GameManager.normal_levels.get(upgrade_id, 0)) if level < 0 else level
	return ceil(float(definition["base_cost"]) * pow(float(definition["growth"]), current_level))

func get_bulk_cost(upgrade_id: String, quantity: int) -> float:
	# With finite double-precision Energy and the current growth rates, no
	# upgrade can afford more than a few thousand levels at once. Keep an
	# explicit work bound so corrupt/extreme saves cannot trigger a huge loop.
	if quantity <= 0 or quantity > 8192:
		return INF
	var definition := get_definition(upgrade_id)
	if definition.is_empty():
		return INF
	var level := int(GameManager.normal_levels.get(upgrade_id, 0))
	var base_cost := float(definition["base_cost"])
	var growth := float(definition["growth"])
	var total := 0.0
	for offset in range(quantity):
		var price: float = ceil(base_cost * pow(growth, level + offset))
		total += price
		if is_inf(total):
			return INF
	return total

func get_max_affordable_count(upgrade_id: String) -> int:
	if get_definition(upgrade_id).is_empty():
		return 0
	var budget := GameManager.energy
	if budget < get_cost(upgrade_id):
		return 0
	var definition := get_definition(upgrade_id)
	var level := int(GameManager.normal_levels.get(upgrade_id, 0))
	var base_cost := float(definition["base_cost"])
	var growth := float(definition["growth"])
	var first_raw := base_cost * pow(growth, level)
	if not is_finite(first_raw) or first_raw <= 0.0:
		return 0
	var estimate_value := log(1.0 + budget * (growth - 1.0) / first_raw) / log(growth)
	if not is_finite(estimate_value):
		return 8192
	var amount := clampi(int(floor(estimate_value)), 0, 8192)
	var total := get_bulk_cost(upgrade_id, amount) if amount > 0 else 0.0
	# The logarithmic estimate uses unrounded geometric costs. Reconcile it
	# against the exact per-level ceil prices, usually by at most one rank.
	while amount > 0 and total > budget:
		amount -= 1
		total = get_bulk_cost(upgrade_id, amount) if amount > 0 else 0.0
	while amount < 8192 and get_bulk_cost(upgrade_id, amount + 1) <= budget:
		amount += 1
		total = get_bulk_cost(upgrade_id, amount)
	return amount

func purchase(upgrade_id: String, quantity: int = 1) -> bool:
	var amount := quantity
	if amount == -1:
		amount = get_max_affordable_count(upgrade_id)
	if amount <= 0 or amount > BalanceConfig.MAX_BULK_SEARCH_COUNT:
		return false
	var price := get_bulk_cost(upgrade_id, amount)
	if price > GameManager.energy:
		return false
	GameManager.energy = maxf(0.0, GameManager.energy - price)
	GameManager.normal_levels[upgrade_id] = int(GameManager.normal_levels.get(upgrade_id, 0)) + amount
	GameManager.notify_state_changed()
	return true

func get_milestone_count(upgrade_id: String, level: int = -1) -> int:
	var current_level := int(GameManager.normal_levels.get(upgrade_id, 0)) if level < 0 else level
	var count := 0
	for milestone in BalanceConfig.MILESTONE_LEVELS:
		if current_level >= milestone:
			count += 1
	return count

func get_milestone_multiplier(levels: Dictionary = {}) -> float:
	var multiplier := 1.0
	for upgrade_id in get_upgrade_ids():
		var level := int(levels.get(upgrade_id, GameManager.normal_levels.get(upgrade_id, 0)))
		multiplier *= pow(BalanceConfig.MILESTONE_MULTIPLIER, get_milestone_count(upgrade_id, level))
	return multiplier

func _process(delta: float) -> void:
	if not GameManager.initialized:
		return
	_automation_accumulator += delta
	if _automation_accumulator < BalanceConfig.AUTO_BUY_INTERVAL_SECONDS:
		return
	_automation_accumulator = fmod(_automation_accumulator, BalanceConfig.AUTO_BUY_INTERVAL_SECONDS)
	var candidates: Array[Dictionary] = []
	if GameManager.auto_core_enabled and PrestigeManager.get_node_rank("auto_core") > 0:
		_add_auto_candidate(candidates, "core_power")
	if GameManager.auto_frequency_enabled and PrestigeManager.get_node_rank("auto_frequency") > 0:
		_add_auto_candidate(candidates, "reactor_speed")
	if GameManager.auto_efficiency_enabled and PrestigeManager.get_node_rank("auto_efficiency") > 0:
		_add_auto_candidate(candidates, "efficiency")
	if candidates.is_empty():
		return

	var selected: Dictionary = candidates[0]
	var smart_unlocked := PrestigeManager.get_node_rank("smart_auto") > 0
	for candidate in candidates.slice(1):
		if _candidate_precedes(candidate, selected, smart_unlocked):
			selected = candidate
	purchase(str(selected["id"]), 1)

func purchase_offline_batches() -> int:
	if PrestigeManager.get_node_rank("offline_automation") <= 0:
		return 0
	var total_levels := 0
	var batches := 0
	while batches < 10000:
		batches += 1
		var candidates: Array[Dictionary] = []
		if GameManager.auto_core_enabled and PrestigeManager.get_node_rank("auto_core") > 0:
			_add_auto_candidate(candidates, "core_power")
		if GameManager.auto_frequency_enabled and PrestigeManager.get_node_rank("auto_frequency") > 0:
			_add_auto_candidate(candidates, "reactor_speed")
		if GameManager.auto_efficiency_enabled and PrestigeManager.get_node_rank("auto_efficiency") > 0:
			_add_auto_candidate(candidates, "efficiency")
		if candidates.is_empty():
			break
		var selected: Dictionary = candidates[0]
		var smart_unlocked := PrestigeManager.get_node_rank("smart_auto") > 0
		for candidate in candidates.slice(1):
			if _candidate_precedes(candidate, selected, smart_unlocked):
				selected = candidate
		var upgrade_id := str(selected["id"])
		var amount := get_max_affordable_count(upgrade_id)
		if amount <= 0:
			break
		# Keep each batch within the current strategy's choice region. This
		# preserves Cheapest/Balanced ordering while charging/updating once.
		if smart_unlocked and GameManager.auto_strategy == "balanced":
			var next_level := 2147483647
			for candidate in candidates:
				if str(candidate["id"]) != upgrade_id:
					next_level = mini(next_level, int(candidate["level"]))
			if next_level < 2147483647:
				amount = mini(amount, maxi(1, next_level - int(selected["level"])))
		else:
			var competing_cost := INF
			for candidate in candidates:
				if str(candidate["id"]) != upgrade_id:
					competing_cost = minf(competing_cost, float(candidate["cost"]))
			if is_finite(competing_cost):
				amount = mini(amount, _count_at_or_below_cost(upgrade_id, competing_cost))
		if amount <= 0 or not purchase(upgrade_id, amount):
			break
		total_levels += amount
	return total_levels

func get_next_auto_cost() -> float:
	var costs: Array[float] = []
	if GameManager.auto_core_enabled and PrestigeManager.get_node_rank("auto_core") > 0:
		costs.append(get_cost("core_power"))
	if GameManager.auto_frequency_enabled and PrestigeManager.get_node_rank("auto_frequency") > 0:
		costs.append(get_cost("reactor_speed"))
	if GameManager.auto_efficiency_enabled and PrestigeManager.get_node_rank("auto_efficiency") > 0:
		costs.append(get_cost("efficiency"))
	var cheapest := INF
	for cost in costs:
		cheapest = minf(cheapest, cost)
	return cheapest

func _count_at_or_below_cost(upgrade_id: String, max_cost: float) -> int:
	var definition := get_definition(upgrade_id)
	var level := int(GameManager.normal_levels.get(upgrade_id, 0))
	var base_cost := float(definition["base_cost"])
	var growth := float(definition["growth"])
	var max_level := int(floor(log(max_cost / base_cost) / log(growth)))
	max_level = maxi(level, max_level)
	while max_level >= level and get_cost(upgrade_id, max_level) > max_cost:
		max_level -= 1
	while get_cost(upgrade_id, max_level + 1) <= max_cost:
		max_level += 1
	return maxi(0, max_level - level + 1)

func _add_auto_candidate(candidates: Array[Dictionary], upgrade_id: String) -> void:
	var cost := get_cost(upgrade_id)
	if cost <= GameManager.energy:
		candidates.append({
			"id": upgrade_id,
			"cost": cost,
			"level": int(GameManager.normal_levels.get(upgrade_id, 0))
		})

func _candidate_precedes(candidate: Dictionary, current: Dictionary, smart_unlocked: bool) -> bool:
	var strategy := GameManager.auto_strategy if smart_unlocked else "cheapest"
	if strategy == "balanced":
		if int(candidate["level"]) != int(current["level"]):
			return int(candidate["level"]) < int(current["level"])
	return float(candidate["cost"]) < float(current["cost"])
