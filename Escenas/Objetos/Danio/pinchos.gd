extends Area2D

func _ready():
	# Funcion que agrega al grupo tal
	add_to_group("pincho")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Verif si player tiene el meotodo que se meciona en su script
		if body.has_method("recibir_danio"):
			body.recibir_danio()

func _on_area_entered(area):
	var body = area.get_parent()
	if body.is_in_group("Player"):
		if body.has_method("recibir_danio"):
			body.recibir_danio()
