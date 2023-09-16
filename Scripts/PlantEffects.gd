extends Node
class_name PlantEffects

enum PlantType {
	None,
	Carrot = 0,
	Tomato = 1,
	Wheat = 2,
	Corn = 3
}

enum GrowthStage {
	None,
	Seedling = 0,
	Growing = 1,
	Grown = 2,
	Dead = 3
}

static func empty_plant(slot: int) -> Dictionary:
	var plant_dict = {
		"type": PlantType.None,
		"slot": slot,
		"stage": GrowthStage.None,
		"growth_mult": 1.0,
		"fertilizer": 0
	}
	return plant_dict

static func kill_plant(plant: Dictionary):
	plant["stage"] = GrowthStage.Dead
	plant["growth_mult"] = 0.0
	plant["fertilizer"] = 0

static func get_neighbors(slot: int) -> Array:
	var neighbors = []
	if (slot - 4 > 0):
		neighbors.append(slot - 4)
	if (slot + 4 <= 12):
		neighbors.append(slot + 4)
	if (slot - 1 > 0):
		neighbors.append(slot - 1)
	if (slot + 1 <= 12):
		neighbors.append(slot + 1)
	return neighbors

## functions return true if they did a bad thing
## so that we can play a silly sound effect when something goes wrong

static func do_nothing(fertilizer, plant, field, player) -> bool:
	return false

static func plant_brawndo(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		player.money += 1_000_000
		return false
	kill_plant(plant)
	return true

static func plant_ammonia(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	kill_plant(plant)
	return true

static func plant_gasoline(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	for slot in get_neighbors(plant["slot"]):
		field[str(slot)] = empty_plant(slot)
	kill_plant(plant)
	return true

static func plant_steroids(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	plant["growth_mult"] *= 0.5
	return true

static func plant_battery(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	for slot in get_neighbors(plant["slot"]):
		field[str(slot)]["growth_mult"] *= 0.5
	return true

static func update_plutonium(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	plant["type"] = randi() % 4
	return true

static func update_ipad(fertilizer, plant, field, player) -> bool:
	if (randf() < fertilizer["benefit_chance"]):
		return false
	if plant["stage"] == GrowthStage.Grown:
		plant["stage"] = GrowthStage.Dead
		return true
	return false
