extends KinematicBody2D

onready var animTree: = $AnimationTree
onready var hurtBox: = $Hurtbox
onready var blinkAnimPlayer: = $BlinkAnimPlayer
onready var animState = animTree.get("parameters/playback")

const ACCELERATION: = 500
const MAX_SPEED: = 40
const FRICTION: = 500

var last_horizontal_direction
var velocity: = Vector2.ZERO
export var is_attacking: = false

func _ready() -> void:
	animTree.active = true;
	PlayerHealthMgr.connect("died", self, "die")
	last_horizontal_direction = -1

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
		return
		
	if input_vector != Vector2.ZERO:
		if input_vector.x != 0:
			last_horizontal_direction = input_vector.x
		
		var anim_direction_vector = Vector2(last_horizontal_direction, input_vector.y)
		# accelerate
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animTree.set("parameters/Walk/blend_position", anim_direction_vector)
		animTree.set("parameters/Idle/blend_position", anim_direction_vector.x)
		animTree.set("parameters/Attack/blend_position", anim_direction_vector)
		animTree.set("parameters/Hurt/blend_position", anim_direction_vector)
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
	animTree.active = false
	blinkAnimPlayer.queue_free()
	hurtBox.queue_free()
	$AnimationPlayer.play("DeathBottomRight")

func attack_anim_finished() -> void:
	is_attacking = false

func death_anim_finished() -> void:
	queue_free()

func _on_Hurtbox_area_entered(_area: Area2D) -> void:
	animState.call_deferred("travel", "Hurt")
	PlayerHealthMgr.current_health -= 1
	hurtBox.start_invincibility(1)

func _on_Hurtbox_invincibility_started() -> void:
	blinkAnimPlayer.play("Start")

func _on_Hurtbox_invincibility_ended() -> void:
	blinkAnimPlayer.play("Stop")
