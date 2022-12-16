extends KinematicBody2D

onready var animTree: = $AnimationTree
onready var animState = animTree.get("parameters/playback")

const ACCELERATION: = 500
const MAX_SPEED: = 40
const FRICTION: = 500

var velocity: = Vector2.ZERO
var is_attacking: = false

func _ready() -> void:
	animTree.active = true;
	PlayerHealthMgr.connect("died", self, "die")

func _physics_process(delta: float) -> void:
	
	if is_attacking:
		velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
		return
		
	var input_vector: = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - \
		Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - \
		Input.get_action_strength("move_up")
		
	if Input.is_action_just_pressed("attack"):
		animState.travel("Attack")
		is_attacking = true
		return
		
	if input_vector != Vector2.ZERO:
		# accelerate
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animTree.set("parameters/Walk/blend_position", input_vector)
		animTree.set("parameters/Idle/blend_position", input_vector.x)
		animTree.set("parameters/Attack/blend_position", input_vector)
		animState.travel("Walk")
	else:
		# decelerate
		animState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()

func move() -> void:
	# reassign velocity from move and slide's remnant after collision	
	velocity = move_and_slide(velocity)

func die() -> void:
	queue_free()

func attack_anim_finished() -> void:
	is_attacking = false

func _on_Hurtbox_area_entered(_area: Area2D) -> void:
	PlayerHealthMgr.current_health -= 1
