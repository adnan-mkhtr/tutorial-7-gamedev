extends Area3D

@export var sceneName := "Level 1"


func _on_Area_Trigger_body_entered(body):
	if body.get_name() == "Player2":
		get_tree().call_deferred("change_scene_to_file", str("res://scenes/" + sceneName + ".tscn"))
