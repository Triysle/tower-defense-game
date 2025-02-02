extends StaticBody3D

var bullet : PackedScene = preload("res://Scenes/bullet.tscn")
var bullet_damage : int = 3
var current_targets : Array = []
var curr : CharacterBody3D
var can_shoot : bool = true
var shot1 : bool = true

func _process(delta):
	if is_instance_valid(curr):
		look_at(curr.global_position)
		if can_shoot:
			shoot()
			can_shoot = false
			$ShootingCooldown.start()
	else:
		for i in get_node("BulletContainer").get_child_count():
			get_node("BulletContainer").get_child(i).queue_free()

func shoot() -> void:
	if shot1 == true:
		var temp_bullet_1 : CharacterBody3D = bullet.instantiate()
		temp_bullet_1.target = curr
		temp_bullet_1.bullet_damage = bullet_damage
		get_node("BulletContainer").add_child(temp_bullet_1)
		temp_bullet_1.global_position = $MeshInstance3D/Aim1.global_position
		shot1 = false
	else:
		var temp_bullet_2 : CharacterBody3D = bullet.instantiate()
		temp_bullet_2.target = curr
		temp_bullet_2.bullet_damage = bullet_damage
		get_node("BulletContainer").add_child(temp_bullet_2)
		temp_bullet_2.global_position = $MeshInstance3D/Aim2.global_position
		shot1 = true

func choose_target(_current_targets : Array) -> void :
	var temp_array : Array = _current_targets
	var current_target : CharacterBody3D = null
	for i in temp_array:
		if current_target == null:
			current_target = i
		else:
			if i.get_parent().get_progress() > current_target.get_parent().get_progress():
				current_target = i
	
	curr = current_target

func _on_mob_detector_body_entered(body):
	if body.is_in_group("Enemy"):
		current_targets.append(body)
		choose_target(current_targets)

func _on_mob_detector_body_exited(body):
	if body.is_in_group("Enemy"):
		current_targets.erase(body)
		choose_target(current_targets)

func _on_shooting_cooldown_timeout():
	can_shoot = true
