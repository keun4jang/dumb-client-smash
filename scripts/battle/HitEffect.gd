extends Node2D

@onready var particles: CPUParticles2D = $Particles

func _ready() -> void:
	particles.emitting = true
	var t := get_tree().create_timer(1.0)
	t.timeout.connect(queue_free)
