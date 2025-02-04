extends CharacterBody3D

@export var speed : int = 2
@export var health : int = 10 + (Global.wave * 5)

@onready var Path : PathFollow3D = get_parent()

var is_alive : bool = true

func _ready():
	$HealthBar3D.set_up(health)

func _physics_process(delta):
	Path.set_progress(Path.get_progress() + speed * delta)
	$HealthBar3D.update(health)
	
	if Path.get_progress_ratio() >= 0.99:
		Global.health -= 10
		death()
	

func take_damage(damage : int) -> void:
	health -= damage
	if health <= 0 and is_alive:
		Global.money += 50
		death()

func death() -> void:
	is_alive = false
	Global.enemies_alive -= 1
	Path.queue_free()
