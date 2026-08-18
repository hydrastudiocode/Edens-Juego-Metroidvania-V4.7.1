class_name Player
extends CharacterBody2D

const VELOCIDAD_CAMINAR = 300.0
const ACELERACION = VELOCIDAD_CAMINAR * 6.0
const VELOCIDAD_SALTO = -725.0
const VELOCIDAD_MAX_CAIDA = 700

@export var sufijo_accion: String = ""

var gravedad: int = ProjectSettings.get(&"physics/2d/default_gravity")
@onready var camara := $Camera2D as Camera2D
@onready var anim_caminar := $Caminar as AnimatedSprite2D
@onready var anim_fijo := $fijo as AnimatedSprite2D
@onready var anim_saltar := $Saltar as AnimatedSprite2D

var _doble_salto_cargado: bool = false
var _animacion_actual: String = "fijo"


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_doble_salto_cargado = true
		
	if Input.is_action_just_pressed("jump" + sufijo_accion):
		intentar_saltar()
	elif Input.is_action_just_released("jump" + sufijo_accion) and velocity.y < 0.0:
		velocity.y *= 0.6 
	
	velocity.y = minf(VELOCIDAD_MAX_CAIDA, velocity.y + gravedad * delta)
	
	var direccion := Input.get_axis("move_left" + sufijo_accion, "move_right" + sufijo_accion) * VELOCIDAD_CAMINAR
	velocity.x = move_toward(velocity.x, direccion, ACELERACION * delta)
	
	if not is_zero_approx(velocity.x):
		var mirando_izquierda = velocity.x < 0.0
		anim_caminar.flip_h = mirando_izquierda
		anim_fijo.flip_h = mirando_izquierda
		anim_saltar.flip_h = mirando_izquierda
	
	move_and_slide()
	actualizar_animacion()


func actualizar_animacion() -> void:
	var animacion_nueva: String
	
	if is_on_floor():
		if absf(velocity.x) > 10.0:
			animacion_nueva = "caminar"
		else:
			animacion_nueva = "fijo"
	else:
		animacion_nueva = "saltar"
	
	if animacion_nueva != _animacion_actual:
		_animacion_actual = animacion_nueva
		
		# Ocultar todos
		anim_caminar.visible = false
		anim_fijo.visible = false
		anim_saltar.visible = false
		
		match animacion_nueva:
			"caminar":
				anim_caminar.visible = true
				anim_caminar.play()
			"fijo":
				anim_fijo.visible = true
				anim_fijo.play()
			"saltar":
				anim_saltar.visible = true
				anim_saltar.play()


func intentar_saltar() -> void:
	"""Intenta realizar un salto o doble salto."""
	if is_on_floor():
		pass 
	elif _doble_salto_cargado:
		_doble_salto_cargado = false
		velocity.x *= 2.5  
	else:
		return  
	
	velocity.y = VELOCIDAD_SALTO
