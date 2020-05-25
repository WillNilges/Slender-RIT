extends KinematicBody

# Sanity
var curHP : int = 100
var maxHP : int = 100

# Flashlight battery
var on : bool = true
var curPOW : int = 100;
var maxPOW : int = 100;
var drainRate : int = 0.5;
var rechargeRate : int = 1;

# Objects collected
var score : int = 0

# physics
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0
var delta : float = 0.02

# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 0.5

# vectors
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()

# player components
onready var camera = get_node("Camera")
onready var ui : Node = get_node("/root/MainScene/CanvasLayer/UI")
onready var flashlightTimer : Timer = get_node("LightTimer")
onready var flashlight : SpotLight = get_node("Camera/shotgun/muzzle/Flashlight")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_health_bar(curHP, maxHP)
	update_power_bar(curPOW, maxPOW)
	flashlightTimer.start(drainRate)

# called when an input is detected
func _input (event):

    # did the mouse move?
    if event is InputEventMouseMotion:
        mouseDelta = event.relative
		
# called every frame
func _process (delta):

    # rotate camera along X axis
    camera.rotation_degrees -= Vector3(rad2deg(mouseDelta.y), 0, 0) * lookSensitivity * delta

    # clamp the vertical camera rotation
    camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	
    # rotate player along Y axis
    rotation_degrees -= Vector3(0, rad2deg(mouseDelta.x), 0) * lookSensitivity * delta
	
    # reset the mouse delta vector
    mouseDelta = Vector2()

# called every physics step
func _physics_process (Delta):
	# reset the x and z velocity
	vel.x = 0
	vel.z = 0
	
	var input = Vector2()
	
	# movement inputs
	if Input.is_action_pressed("move_forward"):
	    input.y -= 1
	if Input.is_action_pressed("move_backward"):
	    input.y += 1
	if Input.is_action_pressed("move_left"):
	    input.x -= 1
	if Input.is_action_pressed("move_right"):
	    input.x += 1
	
	# normalize the input so we can't move faster diagonally
	input = input.normalized()
	
	# get our forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	# set the velocity
	vel.z = (forward * input.y + right * input.x).z * moveSpeed
	vel.x = (forward * input.y + right * input.x).x * moveSpeed
	
	# apply gravity
	vel.y -= gravity * delta
	
	# move the player
	vel = move_and_slide(vel, Vector3.UP)
	
	# jump if we press the jump button and are standing on the floor
	if Input.is_action_pressed("jump") and is_on_floor():
	    vel.y = jumpForce
		
	if Input.is_action_just_released("shoot"):
		on = !on
		flashlight.visible = !flashlight.visible

func take_damage (damage):
	print_debug("Oof ouch owie")
	curHP -= damage
	update_health_bar(curHP,maxHP)	
	

	if curHP <= 0:
		die()

func die ():
	print_debug("I'm FUCKING DEAD!")
	get_tree().quit()

# called when we kill an enemy
func add_score (amount):
    score += amount

# adds an amount of health to the player
func add_health (amount):
	curHP = clamp(curHP + amount, 0, maxHP)
	update_health_bar(curHP, maxHP)

# And here we see an example of "Bad Code."

onready var healthBar : TextureProgress = get_node("/root/MainScene/CanvasLayer/UI/HealthBar")
onready var powerBar : TextureProgress = get_node("/root/MainScene/CanvasLayer/UI/PowerBar")

func update_health_bar (curHP, maxHP):
	healthBar.max_value = maxHP
	healthBar.value = curHP
	pass
	
func update_power_bar (curPOW, maxPOW):
	powerBar.max_value = maxPOW
	powerBar.value = curPOW
	pass

func _on_LightTimer_timeout():
	#print_debug("Lights out")
	if on:
		curPOW -= 2
	if !on:
		curPOW += 1
	if curPOW <= 0:
		flashlight.visible = !flashlight.visible
	# This is poor coding practice, but go fuck yourself
	if curHP < 100:
		if curHP+10 > 100:
			add_health(1)
		else:
			add_health(2)
	update_power_bar(curPOW, maxPOW)