extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const MAX_FALLING_VELOCITY = 800.0

#States would help for more advanced mechanics such as double jump, etc
enum JumpState {READY, JUMPING, FALLING}
var current_jump_state: JumpState
var elapsed_jump_time: float = 0.0 #Can use a timer and timeout signal instead
@export var jump_duration: float = 2.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _handle_jumping_state(delta):
	#if you're jumping, keep counting until you can no longer jump
	if current_jump_state == JumpState.JUMPING:
		elapsed_jump_time += delta
		# Fall if jumping for too long
		if elapsed_jump_time >= jump_duration:
			current_jump_state = JumpState.FALLING
	
	#Input
	if Input.is_action_just_pressed("ui_accept"):
		print("Pressed 'jump'!")
		if current_jump_state == JumpState.READY and is_on_floor():
			current_jump_state == JumpState.JUMPING
			#anim.play("Jump") (if we have the anim for it)
		if Input.is_action_just_released("ui_accept"):
			print("Released 'jump'!")
			if current_jump_state == JumpState.JUMPING:
				current_jump_state = JumpState.FALLING
	# Reset state
	if current_jump_state == JumpState.FALLING and is_on_floor():
		current_jump_state = JumpState.READY
		elapsed_jump_time = 0.0
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	_handle_jumping_state(delta) # First
	
	#Then handle movement
	match current_jump_state:
		JumpState.READY, JumpState.FALLING:
			velocity.y = min(velocity.y + gravity * delta, MAX_FALLING_VELOCITY)
		JumpState.JUMPING:
			velocity.y = JUMP_VELOCITY
			#or if you want to smooth/ease jump over time
			velocity.y = JUMP_VELOCITY * ease(elapsed_jump_time/jump_duration, 3.0)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
