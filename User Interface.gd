extends Node

# Dead code lol

onready var healthBar : TextureProgress = get_node("/root/MainScene/CanvasLayer/UI/HealthBar")
onready var powerBar : TextureProgress = get_node("/root/MainScene/CanvasLayer/UI/PowerBar")

func update_health_bar (curHP, maxHP):
	#healthBar.max_value = maxHP
	#healthBar.value = curHP
	pass
	
func update_power_bar (curPOW, maxPOW):
#	powerBar.max_value = maxHP
#	powerBar.value = curHP
	pass


