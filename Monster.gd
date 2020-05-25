extends KinematicBody

# stats
var health : int = 5
var moveSpeed : float = 1.0

# attacking
var touchDamage : int = 20
var attackRate : float = 0.2
var attackDist : float = 1.2
var teleportRate : int = 5
var canTeleport : bool = false;

# components
onready var player : Node = get_node("/root/MainScene/Player")
onready var timer : Timer = get_node("Timer")
onready var agroTimer : Timer = get_node("AgroTimer")
onready var playerLOS : RayCast = get_node("/root/MainScene/Player/Camera/PlayerLOS")
onready var fearAura : VisibilityNotifier = get_node("FearAura")
onready var munsonBody : CollisionShape = get_node("MonsterCollisionShape");
onready var playerBody : CollisionShape = get_node("/root/MainScene/Player/PlayerCollisionShape");

# Called when the node enters the scene tree for the first time.
func _ready ():
	timer.start(attackRate)
	agroTimer.start(teleportRate)

func _physics_process (Delta):
	# calculate direction to the player
	var dir = (player.translation - translation).normalized()
	dir.y = 0
	if canTeleport: # Wow this is evil. This is absolutely EVIL!
		teleport(0)

func teleport(distance):
	if !fearAura.is_on_screen() and canTeleport:
		var dir = (player.translation - translation)
		#print_debug(dir)
		translation = player.translation - Vector3(.2,.2,.2)*dir
		canTeleport = false

func attack (damage):
	player.take_damage(damage)

# Determines the frequency of Munchkin's Attack
func _on_Timer_timeout():
	# if we're at the right distance, attack the player
	if translation.distance_to(player.translation) <= attackDist:
		attack(touchDamage)
		
	# Ah yes, more bäd cøde.
	if fearAura.is_on_screen():
		print_debug("Oh fuck there he is!")
		var dmgMultiplier = translation.distance_to(player.translation) # Looking at Munchkin when close to him is a bad idea.
		attack(20/dmgMultiplier)


func _on_AgroTimer_timeout():
		# Threat level
	#match player.score:
	match 3:
		1:
			pass
		2:
			# move the enemy towards the player
			#move_and_slide(dir * moveSpeed, Vector3.UP)
			pass
		3:
			canTeleport = true
			teleport(0)
