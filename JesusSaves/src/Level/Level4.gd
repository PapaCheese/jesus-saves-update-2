extends Node2D

const Crate = preload("res://JesusSaves/src/Prop/Crate.tscn")

func spawn_crate() -> void:
	$CratePos.add_child(Crate.instance())
