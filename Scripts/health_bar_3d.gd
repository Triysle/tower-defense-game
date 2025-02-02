extends Sprite3D

@onready var bar : ProgressBar = $SubViewport/HealthBar2D

func _ready():
	texture = $SubViewport.get_texture()

func set_up(value : int) -> void:
	bar.setup_bar(value)

func update(value : int) -> void:
	bar.update_bar(value)
