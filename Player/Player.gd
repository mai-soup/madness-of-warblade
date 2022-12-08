extends KinematicBody2D

const ACCELERATION: = 500
const MAX_SPEED: = 60
const FRICTION: = 500

var velocity: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var input_vector: = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - \
		Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - \
		Input.get_action_strength("move_up")
		
	if input_vector != Vector2.ZERO:
		# accelerate
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# decelerate
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()

func move() -> void:
	# reassign velocity from move and slide's remnant after collision	
	velocity = move_and_slide(velocity)
