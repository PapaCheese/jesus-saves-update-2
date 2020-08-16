extends Node2D

const Crate = preload("res://src/Prop/Crate.tscn")

func spawn_crate() -> void:
	$CratePos.add_child(Crate.instance())
