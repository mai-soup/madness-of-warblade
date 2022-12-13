extends KinematicBody2D

onready var animTree: = $AnimationTree

func _ready() -> void:
	animTree.active = true;
