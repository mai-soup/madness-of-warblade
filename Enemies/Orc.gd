extends KinematicBody2D

onready var playerDetector: = $PlayerDetector
onready var attackDetector: = $AttackDetector
onready var healthManager: = $HealthManager
onready var animTree: = $AnimationTree
onready var attackTimer: = $AttackCooldown
onready var animState = animTree.get("parameters/playback")
onready var recalc_path_timer: = $RecalcPathTimer

const ACCELERATION: = 450
const MAX_SPEED: = 20
const KNOCKBACK_AMOUNT: = 80
const FRICTION: = 500
export var attack_cooldown: = 2.0
export var damage: = 1

#pathfinding
onready var nav_agent: = $NavigationAgent2D

var knockback: = Vector2.ZERO
var last_horizontal_direction: = -1
var direction: = Vector2.ZERO
var velocity: = Vector2.ZERO
var is_attacking: = false
# for deferring first walk sound by 0.2s
var started_walking = false

enum { IDLE, CHASING, ATTACKING }
var current_state = IDLE

func _ready() -> void:
	animTree.active = true;
	healthManager.connect("died", self, "die")
	attackTimer.start(attack_cooldown)
	recalc_path_timer.connect("timeout", self, "update_pathfinding")

func _physics_process(delta: float) -> void:
	# add friction to knockback
	knockback = knockback.move_toward(Vector2.ZERO, delta * FRICTION)
	knockback = move_and_slide(knockback)
	
	match current_state:
		ATTACKING:
			velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
		CHASING:
			if playerDetector.can_see_player():
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				
				if direction.x > 0:
					last_horizontal_direction = 1
				elif direction.x < 0:
					last_horizontal_direction = -1
				
				animTree.set("parameters/Walk/blend_position", direction)
				animTree.set("parameters/Idle/blend_position", last_horizontal_direction)
				animTree.set("parameters/Attack/blend_position", direction)
				animTree.set("parameters/Die/blend_position", direction)
				animState.travel("Walk")
				if $WalkTimer.time_left <= 0:
					if started_walking:
						$WalkAudioPlayer.pitch_scale = rand_range(0.8, 1.2)
						$WalkAudioPlayer.play()

					$WalkTimer.start(0.4 if started_walking else 0.2)
					started_walking = true
			seek_player()
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
			animState.travel("Idle")
			started_walking = false
			seek_player()
	
	move_and_slide(velocity)

func move() -> void:
	# reassign velocity from move and slide's remnant after collision	
	velocity = move_and_slide(velocity)

func attack_anim_finished() -> void:
	current_state = IDLE

func seek_player() -> void:
	if is_attacking: return
	if attackDetector.player_in_range():
		if (current_state != ATTACKING):
			animState.travel("Attack")
			attackTimer.start(attack_cooldown)
			is_attacking = true
		current_state = ATTACKING
	else:
		current_state = CHASING if playerDetector.can_see_player() else IDLE

func die() -> void:
	animState.travel("Die")

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	$HealthManager.current_health -= area.get_parent().damage
	knockback = area.knockback_vector * KNOCKBACK_AMOUNT
	print($HealthManager.current_health)
	if $HealthManager.current_health > 0:
		animState.call_deferred("travel", "Hurt")

func death_anim_finished() -> void:
	queue_free()

func _on_AttackCooldown_timeout() -> void:
	is_attacking = false

func update_pathfinding() -> void:
	if (!playerDetector.can_see_player()): return
	
	nav_agent.set_target_location(playerDetector.player.global_position)
	direction = global_position.direction_to(nav_agent.get_next_location())
