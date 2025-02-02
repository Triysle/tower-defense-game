extends Node3D

@onready var enemy : PackedScene = preload("res://Mobs/ufo.tscn")
@onready var cannon : PackedScene = preload("res://Scenes/Cannon.tscn")
@onready var blaster : PackedScene = preload("res://Scenes/Blaster.tscn")

@onready var cam : Camera3D = $Camera3D
@onready var indicator : MeshInstance3D = $Indicator

var enemies_to_spawn : int = 0
var can_spawn : bool = true
var in_build_menu : bool = false
var wave_ongoing : bool = false

func _process(delta):
	handle_player_controls()
	handle_ui()
	game_manager()
	
func handle_player_controls() -> void:
	var space_state : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	
	var origin : Vector3 = cam.project_ray_origin(mouse_pos)
	var end : Vector3 = origin + cam.project_ray_normal(mouse_pos) * 100
	var ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, end)
	
	ray.collide_with_bodies = true
	
	var ray_result : Dictionary =  space_state.intersect_ray(ray)
	
	if not in_build_menu:
		if ray_result.size() > 0:
			indicator.visible = true
			var collider : CollisionObject3D = ray_result.get("collider")
			indicator.global_position = collider.global_position + Vector3(0, 0.2, 0)
			
			if collider.is_in_group("Empty"):
				indicator.set_surface_override_material(0, load("res://Materials/green.tres"))
				if Input.is_action_just_pressed("interact"):
					in_build_menu = true
					# var temp_cannon : StaticBody3D = cannon.instantiate()
					# add_child(temp_cannon)
					# temp_cannon.global_position = indicator.global_position
					
			else:
				indicator.set_surface_override_material(0, load("res://Materials/red.tres"))
		else:
			indicator.visible = false
	

func game_manager() -> void:
	if Global.health <= 0:
		game_over()
	
	
	if enemies_to_spawn > 0 and can_spawn:
		$SpawnTimer.start()
		
		var tempEnemy = enemy.instantiate()
		$Path.add_child(tempEnemy)
		
		enemies_to_spawn -= 1
		Global.enemies_alive += 1
		
		can_spawn = false
	
	if Global.enemies_alive > 0:
		wave_ongoing = true
	else:
		wave_ongoing = false


func handle_ui() -> void:
	$Map/TowerRoundSampleF/HealthBar3D.update(Global.health)
	$CanvasLayer/UI/ShopPanel.visible = in_build_menu
	$CanvasLayer/UI/NextWaveButton.visible = not wave_ongoing
	$CanvasLayer/UI/Gold.text = "Gold: " + str(Global.money)
	$CanvasLayer/UI/Wave.text = "Wave: " + str(Global.wave)


func _on_spawn_timer_timeout():
	can_spawn = true

func buy_tower(cost : int, scene : PackedScene) -> void:
	if Global.money >= cost:
		Global.money -= cost
		var temp_cannon : StaticBody3D = scene.instantiate()
		add_child(temp_cannon)
		temp_cannon.global_position = indicator.global_position

func game_over() -> void:
	$CanvasLayer/UI/GameOverPanel.visible = true
	

func _on_cannon_button_pressed():
	buy_tower(100, cannon)
	in_build_menu = false

func _on_blaster_button_pressed():
	buy_tower(250, blaster)
	in_build_menu = false

func _on_cancel_button_pressed():
	in_build_menu = false


func _on_next_wave_button_pressed():
	Global.wave += 1
	enemies_to_spawn = Global.wave * 3
	can_spawn = true


func _on_play_again_button_pressed():
	Global.reset()
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	get_tree().quit()
