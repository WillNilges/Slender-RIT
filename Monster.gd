extends KinematicBody

# stats
var health : int = 5
var moveSpeed : float = 1.0

# attacking
var touchDamage : int = 20
var attackRate : float = 0.2
var attackDist : float = 1.2
var agroRate : int = 5
var canTeleport : bool = false; # This is literally just if the cooldown has refreshed. Nothing to do with LOS.
var teleportLag : int = 30 # This gets smaller as the threat level rises.
var debugAgroLevel : int = 0
var hasBeenSeen : bool = false;

# components
onready var player : Node = get_node("/root/MainScene/Player")
onready var timer : Timer = get_node("Timer")
onready var agroTimer : Timer = get_node("AgroTimer")
onready var playerLOS : RayCast = get_node("/root/MainScene/Player/Camera/PlayerLOS")
onready var fearAura : VisibilityNotifier = get_node("FearAura")
onready var fearArea : Area = get_node("FearAuraArea")
onready var fearCollider : CollisionShape = get_node("FearAuraArea/FearCollision")
onready var munsonBody : CollisionShape = get_node("MonsterCollisionShape")
onready var playerBody : CollisionShape = get_node("/root/MainScene/Player/PlayerCollisionShape")

# Navigation nodes
onready var gracies : Navigation = get_node("/root/MainScene/Grace Watson Quad/GraciesRoof")
onready var Dorm1 : Navigation = get_node("/root/MainScene/Grace Watson Quad/Dorm 1")
onready var Dorm2 : Navigation = get_node("/root/MainScene/Grace Watson Quad/Dorm 2")
onready var Dorm3 : Navigation = get_node("/root/MainScene/Grace Watson Quad/Dorm 3")
onready var Dorm4 : Navigation = get_node("/root/MainScene/Grace Watson Quad/Dorm 4")

# Called when the node enters the scene tree for the first time.
func _ready ():
	timer.start(attackRate)
	agroTimer.start(agroRate)

func _physics_process (Delta):
	# calculate direction to the player
	var dir = (player.translation - translation).normalized()
	dir.y = 0
	
	if canTeleport: # Wow this is evil. This is absolutely EVIL!
		teleport(teleportLag)
		
	# Yeet away at lower levels.
	if hasBeenSeen and !fearAura.is_on_screen() and debugAgroLevel < 5:
		var dir2 = (player.translation - translation).normalized()
		print(dir2)
		translation = player.translation + Vector3(200-randi()%400,0,200-randi()%400)*dir2
		hasBeenSeen = false

func teleport(distance):
	if !fearAura.is_on_screen():
		var teleDecision = randi()%5+1
		if debugAgroLevel > 2 and canTeleport and teleDecision < 5:
			var dir = (player.translation - translation).normalized()
			print(dir)
			var in_front_chance = 6
			if randi()%in_front_chance+1 == in_front_chance:
				print("Peekaboo")
				translation = player.translation + Vector3(distance,0,distance)*dir # + Vector3(0,2,0) # (Teleports in front of you you) Nothin personal kid
			else:
				print("nothin' personal kid.")
				translation = player.translation - Vector3(distance,0,distance)*dir # + Vector3(0,2,0) # (Teleports behind you) Nothin personal kid
			canTeleport = false
		if debugAgroLevel > 1 and canTeleport and teleDecision == 5:
			match randi()%5+1:
				1:
					translation = gracies.translation # Gracies roof
					print("Gracies Roof")
				2:
					translation = Dorm1.translation
					print("Dorm1")
				3:
					translation = Dorm2.translation
					print("Dorm2")
				4:
					translation = Dorm3.translation
					print("Dorm3")
				5:
					translation = Dorm4.translation
					print("Dorm4")
					
			translation -=  Vector3(0,0,30)
			canTeleport = false
		#print(player.transform.origin)
		look_at(player.transform.origin, Vector3(0,1,0))

func attack (damage):
	player.take_damage(damage)

# Determines the frequency of Munchkin's Attack
func _on_Timer_timeout():
	# if we're at the right distance, attack the player
	if translation.distance_to(player.translation) <= attackDist:
		attack(touchDamage)
		
	# Damage if seen
	if playerLOS.get_collider() == fearArea:
		print("Oh fuck there he is!")
		inflict_madness(1)
		hasBeenSeen = true
	
	# Damage if near
	if fearArea.overlaps_body(player):
		#print("Ohhh shit I am U N C O M F Y")
		inflict_madness(0.3)
		
func inflict_madness(manualMultiplier):
	#print_debug("Oh fuck there he is!")
	var dmgMultiplier = translation.distance_to(player.translation) # Looking at Munchkin when close to him is a bad idea.
	if dmgMultiplier == 0: # Writing Bad Code is my major
		dmgMultiplier = 1
	attack((20/dmgMultiplier)*manualMultiplier)
	
func _on_AgroTimer_timeout():
	debugAgroLevel = player.score
	canTeleport = true
	teleport(teleportLag)
	agroTimer.start(agroRate)
		
	#match player.score:
	match debugAgroLevel:
		0:
			pass
		1:
			pass
		2:
			# move the enemy towards the player
			# move_and_slide(dir * moveSpeed, Vector3.UP)
			agroRate = 20
		3:
			agroRate = 15
			teleportLag = 30
		4:
			agroRate = 10
			teleportLag = 15
		5:
			agroRate = 10
			teleportLag = 10
		6:
			agroRate = 8
			teleportLag = 7
		7:
			agroRate = 5
			teleportLag = 5
		8:
			teleportLag = 2 # >:)