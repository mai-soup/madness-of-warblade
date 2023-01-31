extends KinematicBody2D

const OrcDeathEffect = preload("res://Enemies/OrcDeathEffect.tscn")

onready var playerDetector: = $PlayerDetector
onready var attackDetector: = $AttackDetector
onready var healthManager: = $HealthManager
onready var animTree: = $AnimationTree
onready var attackTimer: = $AttackCooldown
onready var animState = animTree.get("parameters/playback")
onready var recalc_path_timer: = $RecalcPathTimer

const ACCELERATION: = 450
var MAX_SPEED: = 45
const KNOCKBACK_AMOUNT: = 80
const FRICTION: = 500
export var attack_cooldown: = 2.0
var damage: = 1

#pathfinding
onready var nav_agent: = $NavigationAgent2D
var spawn_point: Vector2
var wander_point: Vector2
onready var wander_radius: = 50.0

var knockback: = Vector2.ZERO
var last_horizontal_direction: = -1
var direction: = Vector2.ZERO
var velocity: = Vector2.ZERO
var is_attacking: = false
var is_wandering: = false
# for deferring first walk sound by 0.2s
var started_walking = false

enum { IDLE, CHASING, ATTACKING }
var current_state = IDLE

func _ready() -> void:
	animTree.active = true;
	healthManager.connect("died", self, "die")
	attackTimer.start(attack_cooldown)
	recalc_path_timer.connect("timeout", self, "update_pathfinding")
	spawn_point = global_position

func _physics_process(delta: float) -> void:
	# add friction to knockback
	knockback = knockback.move_toward(Vector2.ZERO, delta * FRICTION)
	knockback = move_and_slide(knockback)
	
	match current_state:
		ATTACKING:
			is_wandering = false
			velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
			seek_player()
		CHASING:
			is_wandering = false
			if playerDetector.can_see_player():
				walk(delta)
			seek_player()
		IDLE:
			if is_wandering:
				wander_pathfinding()
				walk(delta)
				seek_player()
			else:
				velocity = velocity.move_toward(Vector2.ZERO, 2 * FRICTION * delta)
				animState.travel("Idle")
				started_walking = false
				seek_player()
				if $WanderingPauseTimer.is_stopped():
					$WanderingPauseTimer.start(rand_range(2.0, 4.0))
	
	move_and_slide(velocity)

func move() -> void:
	# reassign velocity from move and slide's remnant after collision	
	velocity = move_and_slide(velocity)

func walk(delta: float) -> void:
	var speed_cap = MAX_SPEED
	if is_wandering:
		speed_cap = MAX_SPEED/2.0
	velocity = velocity.move_toward(direction * speed_cap, ACCELERATION * delta)

	if direction.x > 0:
		last_horizontal_direction = 1
	elif direction.x < 0:
		last_horizontal_direction = -1
	
	$Hitbox.knockback_vector = direction
	animTree.set("parameters/Walk/blend_position", direction)
	animTree.set("parameters/Idle/blend_position", last_horizontal_direction)
	animTree.set("parameters/Attack/blend_position", direction)
	animState.travel("Walk")
	if $WalkTimer.time_left <= 0:
		if started_walking:
			$WalkAudioPlayer.pitch_scale = rand_range(0.8, 1.2)
			$WalkAudioPlayer.play()

		$WalkTimer.start(0.4 if started_walking else 0.2)
		started_walking = true

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
	queue_free()
	var deathEffect = OrcDeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = global_position

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	$HealthManager.current_health -= area.get_parent().damage
	knockback = area.knockback_vector * KNOCKBACK_AMOUNT
	is_attacking = false;
	if $HealthManager.current_health > 0:
		animState.call_deferred("travel", "Hurt")

func _on_AttackCooldown_timeout() -> void:
	is_attacking = false

func update_pathfinding() -> void:
	if (!playerDetector.can_see_player()): return
	
	nav_agent.set_target_location(playerDetector.player.global_position)
	direction = global_position.direction_to(nav_agent.get_next_location())

func wander_pathfinding() -> void:
	if !is_wandering: return
	
	nav_agent.set_target_location(wander_point)
	direction = global_position.direction_to(nav_agent.get_next_location())
	
func _on_WanderingPauseTimer_timeout() -> void:
	wander_point = spawn_point + random_point_in_circle()
	if current_state == IDLE:
		is_wandering = true;
		
func random_point_in_circle() -> Vector2:
	return Vector2.RIGHT.rotated(randf() * TAU) * sqrt(rand_range(pow(1 - wander_radius / wander_radius, 2), 1)) * wander_radius

func _on_NavigationAgent2D_navigation_finished() -> void:
	if is_wandering:
		is_wandering = false
