extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#onready var player: Node = get_node("/root/MainScene/Player")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_collectable_body_entered(body):
	print(body)
	if body.name == "Player":
		body.incrementScore()
		queue_free()

