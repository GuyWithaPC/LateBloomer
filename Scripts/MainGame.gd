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

func empty_plant() -> Dictionary:
	var plant_dict = {
		"type": PlantType.None,
		"stage": GrowthStage.None
	}
	return plant_dict

var field: Dictionary = {
	"1": empty_plant(),
	"2": empty_plant(),
	"3": empty_plant(),
	"4": empty_plant(),
	"5": empty_plant(),
	"6": empty_plant(),
	"7": empty_plant(),
	"8": empty_plant(),
	"9": empty_plant(),
	"10": empty_plant(),
	"11": empty_plant(),
	"12": empty_plant()
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

const TIME_PER_TICK = 5.0
var time_since_tick = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var sprites = get_tree().get_nodes_in_group("CropSprites")
	for sprite in sprites:
		var plant: Dictionary = field[sprite.name]
		sprite.visible = (plant["type"] != PlantType.None)
		sprite.frame = plant["type"]*4 + plant["stage"]
	
	time_since_tick += delta
	if (time_since_tick >= TIME_PER_TICK):
		time_since_tick = 0.0
		for k in field.keys():
			if (field[k]["stage"] < 2):
				if (randf() < (plant_stats[field[k]["type"]]["growth_rate"] / 10.0)):
					field[k]["stage"] += 1

func plant(area_name: String, type: PlantType):
	field[area_name]["type"] = type
	field[area_name]["stage"] = GrowthStage.Seedling


