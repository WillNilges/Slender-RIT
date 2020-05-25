extends KinematicBody

# stats
var health : int = 5
var moveSpeed : float = 1.0

# attacking
var damage : int = 20
var attackRate : float = 0.2
var attackDist : float = 1.2

var scoreToGive : int = 10

# components
onready var player : Node = get_node("/root/MainScene/Player")
onready var timer : Timer = get_node("Timer")

# Called when the node enters the scene tree for the first time.
func _ready ():
    # setup the timer
    #timer.set_wait_time(attackRate)
    timer.start(attackRate)

func _physics_process (Delta):
	# calculate direction to the player
	var dir = (player.translation - translation).normalized()
	dir.y = 0
	# move the enemy towards the player
	move_and_slide(dir * moveSpeed, Vector3.UP)

func attack ():
	player.take_damage(damage)

# Determines the frequency of Munchkin's Attack
func _on_Timer_timeout():
	# if we're at the right distance, attack the player
	if translation.distance_to(player.translation) <= attackDist:
		attack()
