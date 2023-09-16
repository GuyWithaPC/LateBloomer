extends Node2D

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

# this is using bit-flags, because maybe you want to use multiple fertilizers?
enum FertilizerType {
	None = 0,
	Brawndo = 0x01,
	Plutonium = 0x02,
	Ammonia = 0x04,
	Gasoline = 0x08,
	Steroids = 0x10,
	IPad = 0x20,
	CarBattery = 0x40,
	Music = 0x80
}
var fertilizers = {
	4: FertilizerType.Brawndo,
	5: FertilizerType.Plutonium,
	6: FertilizerType.Ammonia,
	7: FertilizerType.Gasoline,
	8: FertilizerType.Steroids,
	9: FertilizerType.IPad,
	10: FertilizerType.CarBattery,
	11: FertilizerType.Music
}
const MUSIC_LIE = """
	\"Studies have shown...\"
	- +{rate}% growth rate
	- No downsides
"""
var fertilizer_tooltips = {
	FertilizerType.Brawndo: """
	\"It's what plants crave!\"
	- 100% chance of killing the plant
	- 1% chance of instantly earning $1 million
	""",
	FertilizerType.Plutonium: """
	\"20 billion calories should do the trick!\"
	- +50% growth rate
	- +50% mutation chance per cycle
	""",
	FertilizerType.Ammonia: """
	\"I heard somewhere that nitrogen is good for plants. This has nitrogen, right?\"
	- 50% chance of killing the plant
	- 50% chance of +50% growth rate
	""",
	FertilizerType.Gasoline: """
	\"GAS GAS GAS\"
	- 75% chance of +100% growth rate
	- 25% chance of exploding, killing the plant and all neighboring plants
	""",
	FertilizerType.Steroids: """
	\"Bro I swear I'm organic!\"
	- +50% plant yield
	- 50% chance of -50% growth rate
	""",
	FertilizerType.IPad: """
	\"Works great for raising kids, should work for raising plants too!\"
	- +50% growth rate
	- Crops decay the next growth cycle after reaching maturity
	""",
	FertilizerType.CarBattery: """
	\"Just one, as a treat.\"
	- +100% growth rate
	- -50% growth rate for all neighbors
	""",
	FertilizerType.Music: """
	\"Studies have shown...\"
	- +100% growth rate
	- No downsides
	"""
}
func isUsing(plant: Dictionary, fertilizer: FertilizerType) -> bool:
	return (plant["fertilizer"] & fertilizer) != 0

func getFertilizers(plant: Dictionary) -> Array:
	var ferts = []
	for type in FertilizerType:
		if isUsing(plant, FertilizerType[type]):
			ferts.append(FertilizerType[type])
	return ferts

var plant_stats = {
	PlantType.Carrot: {
		"growth_rate": 1
	},
	PlantType.Tomato: {
		"growth_rate": 1
	},
	PlantType.Wheat: {
		"growth_rate": 1
	},
	PlantType.Corn: {
		"growth_rate": 1
	}
}

var fertilizer_stats = {
	FertilizerType.Brawndo: {
		"growth_rate": 0,
		"plant_yield": 0,
		"benefit_chance": 0.01,
		"plant_func": PlantEffects.plant_brawndo,
		"update_func": PlantEffects.do_nothing
	},
	FertilizerType.Plutonium: {
		"growth_rate": 1.5,
		"plant_yield": 1.0,
		"benefit_chance": 0.5,
		"plant_func": PlantEffects.do_nothing,
		"update_func": PlantEffects.update_plutonium
	},
	FertilizerType.Ammonia: {
		"growth_rate": 1.5,
		"plant_yield": 1.0,
		"benefit_chance": 0.5,
		"plant_func": PlantEffects.plant_ammonia,
		"update_func": PlantEffects.do_nothing
	},
	FertilizerType.Gasoline: {
		"growth_rate": 2.0,
		"plant_yield": 1.0,
		"benefit_chance": 0.75,
		"plant_func": PlantEffects.plant_gasoline,
		"update_func": PlantEffects.do_nothing
	},
	FertilizerType.Steroids: {
		"growth_rate": 1.0,
		"plant_yield": 1.5,
		"benefit_chance": 0.5,
		"plant_func": PlantEffects.plant_steroids,
		"update_func": PlantEffects.do_nothing
	},
	FertilizerType.IPad: {
		"growth_rate": 1.5,
		"plant_yield": 1.0,
		"benefit_chance": 0.0,
		"plant_func": PlantEffects.do_nothing,
		"update_func": PlantEffects.update_ipad
	},
	FertilizerType.CarBattery: {
		"growth_rate": 2.0,
		"plant_yield": 1.0,
		"benefit_chance": 0.0,
		"plant_func": PlantEffects.plant_battery,
		"update_func": PlantEffects.do_nothing
	},
	FertilizerType.Music: {
		"growth_rate": 1.0,
		"plant_yield": 1.0,
		"benefit_chance": 1.0,
		"plant_func": PlantEffects.do_nothing,
		"update_func": PlantEffects.do_nothing
	}
}

func empty_plant(slot: int) -> Dictionary:
	var plant_dict = {
		"type": PlantType.None,
		"slot": slot,
		"stage": GrowthStage.None,
		"growth_mult": 1.0,
		"fertilizer": 0,
		"scale_mult": 1.0,
		"goofed": false
	}
	return plant_dict

var field: Dictionary = {
	"1": empty_plant(1),
	"2": empty_plant(2),
	"3": empty_plant(3),
	"4": empty_plant(4),
	"5": empty_plant(5),
	"6": empty_plant(6),
	"7": empty_plant(7),
	"8": empty_plant(8),
	"9": empty_plant(9),
	"10": empty_plant(10),
	"11": empty_plant(11),
	"12": empty_plant(12)
}

const TIME_PER_TICK = 5.0
const TIME_PER_DAY = 60.0
const BASE_GROWTH_CHANCE = 0.5
var time_since_tick = 0.0
var day_time = 0.0

var clock_pop_additional_scale = 0.0

@onready
var gui = get_tree().get_nodes_in_group("GUI")[0]

@onready
var player = gui.get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update crop sprites
	var sprites = get_tree().get_nodes_in_group("CropSprites")
	for sprite in sprites:
		var plant: Dictionary = field[sprite.name]
		sprite.visible = (plant["type"] != PlantType.None)
		sprite.frame = plant["type"]*4 + plant["stage"]
		sprite.scale = Vector2(1,1) * field[sprite.name]["scale_mult"]
		if (isUsing(field[sprite.name], FertilizerType.Steroids)):
			sprite.scale *= 1.25
		field[sprite.name]["scale_mult"] = lerp(field[sprite.name]["scale_mult"], 1.0, delta*10)
	
	# run clock on GUI
	day_time += delta
	clock_pop_additional_scale = lerp(clock_pop_additional_scale, 0.0, delta)
	var clock_position: int = round(4 * day_time / TIME_PER_DAY)
	var clock = gui.get_node("Timer")
	if (clock_position != clock.frame):
		clock.frame = clock_position
		clock_pop_additional_scale = 0.25
	clock.scale = Vector2(0.5,0.5) * (1 + clock_pop_additional_scale)
	if (clock_position >= 5):
		gui.get_node("DayFade").modulate.a = lerp(gui.get_node("DayFade").modulate.a, 1.0, delta*2)
	else:
		gui.get_node("DayFade").modulate.a = lerp(gui.get_node("DayFade").modulate.a, 0.0, delta*2)
	
	time_since_tick += delta
	if (time_since_tick >= TIME_PER_TICK):
		# update the music lie lmao
		fertilizer_tooltips[FertilizerType.Music] = MUSIC_LIE.format({"rate": str(randi_range(25,200))})
		time_since_tick = 0.0
		for k in field.keys():
			# update fertilizer "benefits"
			for type in getFertilizers(field[k]):
				var goofed: bool = fertilizer_stats[type]["update_func"].call(fertilizer_stats[type], field[k], field, player)
				if goofed:
					print_debug("fertilizer: %s\n----\nGet goofed on!" % fertilizer_tooltips[type])
			# update growth stages
			if (field[k]["stage"] < 2):
				var growth_chance = BASE_GROWTH_CHANCE * plant_stats[field[k]["type"]]["growth_rate"] * field[k]["growth_mult"]
				for type in getFertilizers(field[k]):
					growth_chance *= fertilizer_stats[type]["growth_rate"]
				if (randf() < growth_chance):
					field[k]["stage"] += 1
					field[k]["scale_mult"] = 1.25
			else:
				if field[k]["goofed"]:
					field[k]["goofed"] = false
				else:
					field[k] = empty_plant(int(k))

## Plant a plant / use fertilizer on a specific part of the field
## Return a boolean depending on whether it was successful
func plant(area_name: String, type: PlantType) -> bool:
	if type < 4:
		# plant a plant
		if field[area_name]["type"] != PlantType.None:
			return false
		field[area_name]["type"] = type
		field[area_name]["stage"] = GrowthStage.Seedling
		return true
	else:
		# apply a fertilizer
		if isUsing(field[area_name], fertilizers[type]):
			return false
		if field[area_name]["type"] == PlantType.None:
			return false
		field[area_name]["fertilizer"] |= fertilizers[type]
		var goofed: bool = fertilizer_stats[fertilizers[type]]["plant_func"].call(fertilizer_stats[fertilizers[type]], field[area_name], field, player)
		if goofed:
			print_debug("fertilizer: %s\n----\nGet goofed on!" % fertilizer_tooltips[fertilizers[type]])
		return true

## Get the tooltip of the fertilizer type
## enumerated from 4-11, since the player stores all inventory in one big enum
func getTooltip(type: int) -> String:
	return fertilizer_tooltips[fertilizers[type]]
