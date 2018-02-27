extends Spatial

const FLY_SPEED = 20
const FLY_ACCEL = 4
const PRINT_DELAY = 0.1

var host = null
var pos_target = Vector3(0,0,0)
var rot_target = Vector3(0,0,0)
var velocity_target = Vector3(0,0,0)

var last_print_time = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	rot_target = Vector3(rotation)

func posess(entity):
	if entity != null:
		host = weakref(entity)
	else:
		host = null;
		
func get_host():
	if host != null and host.get_ref():
		return host.get_ref()
	return null

func is_posessing():
	return host != null and host.get_ref()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _input(event):
	# Mouse movement changes rotation target
	if event is InputEventMouseMotion:
		rot_target.y -= deg2rad(event.relative.x)/3
		rot_target.x -= deg2rad(event.relative.y)/3

		# clamp vertical mouselook
		var CLAMP_LIM = PI/2.0 - deg2rad(0.1)
		rot_target.x = max(rot_target.x, -CLAMP_LIM)
		rot_target.x = min(rot_target.x, CLAMP_LIM)

		# wrap horizontal mouselook
		if rot_target.y > PI:
			rot_target.y -= 2*PI
		if rot_target.y < -PI:
			rot_target.y += 2*PI

func time_to_print():
	var curr_time = OS.get_ticks_msec () / 1000.0
	if curr_time > (last_print_time + PRINT_DELAY):
		last_print_time = curr_time
		return true
	return false

func _physics_process(delta):

	# Horizontal movement based on WASD
	var direction_target = Vector3(0, 0, 0)
	if Input.is_action_pressed("left"):
		direction_target += Vector3(-1, 0, 0).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("right"):
		direction_target += Vector3(1, 0, 0).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("forward"):
		direction_target += Vector3(0, 0, -1).rotated(Vector3(1, 0, 0), rot_target.x).rotated(Vector3(0, 1, 0), rot_target.y)
	if Input.is_action_pressed("back"):
		direction_target += Vector3(0, 0, 1).rotated(Vector3(1, 0, 0), rot_target.x).rotated(Vector3(0, 1, 0), rot_target.y)
	direction_target = direction_target.normalized()

	if is_posessing():
		var h = get_host()
		# Control the direction of the host's movement
		h.direction = direction_target
		# Make the camera follow the player
		translation = h.translation
		
		if Input.is_action_pressed("jump"):
			h.jumping = true
		else:
			h.jumping = false
			
		if Input.is_action_just_pressed("fly"):
			h.flying = !h.flying
			
		if Input.is_action_pressed("sprint"):
			h.sprinting = true
		else:
			h.sprinting = false
		
		if $Sphere.visible:
			$Sphere.visible = false
	else:
		# Fly based on our own desired velocity
		direction_target = direction_target * FLY_SPEED
		velocity_target = velocity_target.linear_interpolate(direction_target, FLY_ACCEL * delta)
		global_translate(velocity_target * delta)
		
		if !$Sphere.visible:
			$Sphere.visible = true
	
	rotation = rot_target
	
	if time_to_print():
		print("rot: ", rot_target, "dir: ", direction_target)
