extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -270.0
const MAX_FALLING_VELOCITY = 800.0

#States would help for more advanced mechanics such as double jump, etc
enum JumpState {READY, JUMPING, FALLING}
enum MovementState {IDLE, RUNNING}
var current_movement_state: MovementState = MovementState.IDLE
var current_jump_state: JumpState = JumpState.READY
var elapsed_jump_time: float = 0.0 #Can use a timer and timeout signal instead

@export var jump_duration: float = 0.25
@onready var anim = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# Get the input direction and handle the movement/deceleration.

var queued_animation: String = ""

func _on_anim_finished():
	if queued_animation != "":
		anim.play(queued_animation)
		queued_animation = ""



func _ready():
	anim.connect("animation_finished", Callable(self, "_on_anim_finished"))

func _handle_player_state(direction):
	if direction:
		velocity.x = direction * SPEED
		current_movement_state = MovementState.RUNNING
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		current_movement_state = MovementState.IDLE


func _handle_animations(direction):
	if current_jump_state == JumpState.JUMPING:
		anim.play("jump_start")
	elif current_jump_state == JumpState.FALLING:
		#only trigger start if not already playing
		if anim.animation != "falling_start" and anim.animation != "falling":
			anim.play("falling_start")
			queued_animation = "falling" #automatically plays when start finishes
	elif current_movement_state == MovementState.IDLE:
		anim.play("idle")
	elif current_movement_state == MovementState.RUNNING:
		anim.play("run")
	
	#Flip horizontally when moving left
	if direction != 0 and is_on_floor():
		anim.flip_h = direction < 0
	


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
		var ready_to_jump : bool = current_jump_state == JumpState.READY and is_on_floor()
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

	var direction := Input.get_axis("move_left", "move_right")
	
	_handle_player_state(direction)
	
	_handle_animations(direction)

	move_and_slide()
