extends KinematicBody2D

onready var playerDetector: = $PlayerDetector
onready var attackDetector: = $AttackDetector
onready var healthManager: = $HealthManager
onready var animTree: = $AnimationTree
onready var animState = animTree.get("parameters/playback")

const ACCELERATION: = 450
const MAX_SPEED: = 20
const FRICTION: = 500

var velocity: = Vector2.ZERO
var is_attacking: = false

enum { IDLE, CHASING, ATTACKING }
var current_state = IDLE

func _ready() -> void:
	animTree.active = true;
	healthManager.connect("died", self, "die")

func _physics_process(delta: float) -> void:
	match current_state:
		ATTACKING:
			velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
		CHASING:
			if playerDetector.can_see_player():
				var direction: = global_position.direction_to(playerDetector.player.global_position)
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				animTree.set("parameters/Walk/blend_position", direction)
				animTree.set("parameters/Idle/blend_position", direction.x)
				animTree.set("parameters/Attack/blend_position", direction)
				animState.travel("Walk")
			seek_player()
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
			seek_player()
	
	move_and_slide(velocity)

func move() -> void:
	# reassign velocity from move and slide's remnant after collision	
	velocity = move_and_slide(velocity)

func attack_anim_finished() -> void:
	current_state = IDLE

func seek_player() -> void:
	if attackDetector.player_in_range():
		if (current_state != ATTACKING):
			animState.travel("Attack")
		current_state = ATTACKING
	else:
		current_state = CHASING if playerDetector.can_see_player() else IDLE

func die() -> void:
	queue_free()

func _on_Hurtbox_area_entered(_area: Area2D) -> void:
	$HealthManager.current_health -= 1
