extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -600.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.3
const DASH_COOLDOWN = 0.5

var charge_time: float = 0.0
const MAX_CHARGE_TIME: float = 2.0  # Maximum seconds the player can charge
const CHARGE_MULTIPLIER: float = 2.0 # How much stronger the max jump is

var is_dashing = false
var is_charging = false
var is_landing = false
var was_on_floor = true
var can_dash = true

# <--- add bool var
var can_move: bool = true 

@onready var anim = $AnimatedSprite2D

# Tarik node UI dari panel scene Player
@onready var dialog_panel = $NinePatchRect
@onready var dialog_label = $NinePatchRect/Label

func _ready() -> void:
   # Sembunyikan balon obrolan player saat game baru mulai
	dialog_panel.hide()

# Fungsi baru agar Player bisa memunculkan dialognya sendiri
func speak(text_to_say: String, duration: float):
	dialog_panel.show()
	dialog_label.text = text_to_say
	await get_tree().create_timer(duration).timeout
	dialog_panel.hide()

func _physics_process(delta: float) -> void:
	was_on_floor = is_on_floor()
	
	# Add the gravity (Gravitasi tetap bekerja meskipun can_move = false).
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta
		is_landing = false
	else:
		# <--- add: check can_move
		if can_move: 
			# A. While holding the button down, build up the charge
			if Input.is_action_pressed("ui_up") and not is_dashing:
				velocity.x = 0
				is_charging = true
				
				anim.position.x = randf_range(1, 2)

				charge_time += delta
				# Clamp prevents the charge from going higher than the max
				charge_time = clamp(charge_time, 0.0, MAX_CHARGE_TIME)

			# B. When the button is released, execute the jump
			elif Input.is_action_just_released("ui_up") and not is_dashing:
				perform_charged_jump()
				anim.position.x = 0
				is_charging = false
		else:
			# <--- add: if dialog appear when player is charging up, cancel the charge
			if is_charging:
				is_charging = false
				charge_time = 0.0
				anim.position.x = 0
		
	# Dash
	# <--- add: check can_move
	if can_move and Input.is_action_just_pressed("dash") and not is_dashing and not is_charging and can_dash:
		perform_dash()
		

	# Get the input direction and handle the movement/deceleration.
	var direction := 0.0
	
	# <--- add: only accept player's move when allowed
	if can_move:
		direction = Input.get_axis("ui_left", "ui_right")

	if not is_dashing and not is_charging:
		if direction:
			velocity.x = direction * SPEED
		else:
			# Ini akan otomatis menghentikan player secara perlahan saat can_move = false (karena direction = 0)
			velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
	
	if not was_on_floor and is_on_floor() and not is_landing:
		perform_landing()
	
	update_animations(direction)
	
func perform_landing():
	is_landing = true

	# Wait for the 'land' animation to completely finish playing
	await anim.animation_finished

	# Once it finishes, unlock the state so we can idle/run again
	is_landing = false
	
func perform_charged_jump():
	# Calculate how full the charge is as a percentage (0.0 to 1.0)
	var charge_percentage = charge_time / MAX_CHARGE_TIME

	# Calculate the extra power based on the percentage
	var extra_power = JUMP_VELOCITY * charge_percentage * (CHARGE_MULTIPLIER - 1.0)

	# Apply the total velocity
	velocity.y = JUMP_VELOCITY + extra_power

	# VERY IMPORTANT: Reset the charge time back to 0 for the next jump!
	charge_time = 0.0

func perform_dash():
	is_dashing = true
	can_dash = false

	# Dash in the direction the sprite is currently facing
	var dash_direction = -1 if anim.flip_h else 1

	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0 # Optional: Stops the player from falling while dashing

	# Wait for the dash duration to finish without pausing the game
	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	
	await get_tree().create_timer(DASH_COOLDOWN).timeout
	can_dash = true
	
func update_animations(direction):
	# Flip the sprite left or right based on movement
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true
	
	if is_dashing:
		anim.play("dash")
	elif is_charging:
		anim.play("charge-up")
	elif not is_on_floor():
		if velocity.y < 0:
			anim.play("jump")
		elif velocity.y > 0:
			anim.play("fall")
	else:
		if is_landing:
			anim.play("land")
		elif velocity.x != 0:
			anim.play("walk")
		else:
			anim.play("idle")
