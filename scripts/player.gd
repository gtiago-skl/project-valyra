extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -270.0
const MAX_FALLING_VELOCITY = 800.0

#States would help for more advanced mechanics such as double jump, etc
enum JumpState {READY, JUMPING, FALLING}
var current_jump_state: JumpState = JumpState.READY
var elapsed_jump_time: float = 0.0 #Can use a timer and timeout signal instead
var ready_to_jump : bool = current_jump_state == JumpState.READY and is_on_floor()
@export var jump_duration: float = 0.25

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _handle_jumping_state(delta):
	#if you're jumping, keep counting until you can no longer jump
	if current_jump_state == JumpState.JUMPING:
		elapsed_jump_time += delta
		# Fall if jumping for too long
		if elapsed_jump_time >= jump_duration:
			current_jump_state = JumpState.FALLING
	
	#Input
	if Input.is_action_just_pressed("jump"):
		print("Pressed 'jump'!")
		if ready_to_jump:
			current_jump_state = JumpState.JUMPING
			#anim.play("Jump") (if we have the anim for it)
	if Input.is_action_just_released("jump"):
		print("Released 'jump'!")
		if current_jump_state == JumpState.JUMPING:
			current_jump_state = JumpState.FALLING
	# Reset state
	if current_jump_state == JumpState.FALLING and is_on_floor():
		current_jump_state = JumpState.READY
		elapsed_jump_time = 0.0
	

func _physics_process(delta: float) -> void:
		
	# Handle jump.
	_handle_jumping_state(delta) # First
	
	#Then handle movement
	match current_jump_state:
		JumpState.READY, JumpState.FALLING:
			velocity.y = min(velocity.y + gravity * delta, MAX_FALLING_VELOCITY)
		JumpState.JUMPING:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
