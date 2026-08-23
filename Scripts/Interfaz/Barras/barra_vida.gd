extends CanvasLayer

@export var textura_3_vidas: Texture2D
@export var textura_2_vidas: Texture2D
@export var textura_1_vida: Texture2D
@export var textura_0_vidas: Texture2D

@onready var texture_rect: TextureRect = $Vida
var player: Player

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player:
		actualizar_vidas(player.vidas_actuales)

func _process(delta):
	if player:
		actualizar_vidas(player.vidas_actuales)

func actualizar_vidas(vidas_actuales: int) -> void:
	var textura_a_usar: Texture2D
	
	match vidas_actuales:
		3:
			textura_a_usar = textura_3_vidas
		2:
			textura_a_usar = textura_2_vidas
		1:
			textura_a_usar = textura_1_vida
		0:
			textura_a_usar = textura_0_vidas
		_:
			textura_a_usar = textura_0_vidas
	
	if texture_rect and texture_rect.texture != textura_a_usar:
		texture_rect.texture = textura_a_usar
