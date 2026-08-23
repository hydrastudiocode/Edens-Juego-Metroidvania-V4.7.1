class_name Player
extends CharacterBody2D

const VELOCIDAD_CAMINAR = 300.0
const ACELERACION = VELOCIDAD_CAMINAR * 6.0
const VELOCIDAD_SALTO = -725.0
const VELOCIDAD_MAX_CAIDA = 700

@export var max_vidas: int = 3
var vidas_actuales: int
var invulnerable: bool = false
@export var tiempo_invulnerabilidad: float = 1.5
@export var sufijo_accion: String = ""

var gravedad: int = ProjectSettings.get(&"physics/2d/default_gravity")
@onready var camara := $Camera2D as Camera2D
@onready var anim_caminar := $Caminar as AnimatedSprite2D
@onready var anim_fijo := $fijo as AnimatedSprite2D
@onready var anim_saltar := $Saltar as AnimatedSprite2D
@onready var timer_invulnerable: Timer = $Timer
var _doble_salto_cargado: bool = false
var _animacion_actual: String = "fijo"
signal vidas_cambiadas(nuevas_vidas: int)
signal jugador_murio()

func _ready():
	vidas_actuales = max_vidas
	if timer_invulnerable:
		timer_invulnerable.timeout.connect(_on_timer_invulnerable_timeout)
	else:
		timer_invulnerable = Timer.new()
		timer_invulnerable.one_shot = true
		timer_invulnerable.timeout.connect(_on_timer_invulnerable_timeout)
		add_child(timer_invulnerable)
	add_to_group("player")
	vidas_cambiadas.emit(vidas_actuales)

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
	_detectar_colisiones_pinchos()

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
	if is_on_floor():
		pass 
	elif _doble_salto_cargado:
		_doble_salto_cargado = false
		velocity.x *= 2.5  
	else:
		return  
	
	velocity.y = VELOCIDAD_SALTO

func _detectar_colisiones_pinchos() -> void:
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("pincho"):
			recibir_danio()
			break 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("pincho"):
		recibir_danio()

func recibir_danio() -> void:
	if invulnerable:
		return
	
	vidas_actuales -= 1
	vidas_cambiadas.emit(vidas_actuales)
	invulnerable = true
	if timer_invulnerable:
		timer_invulnerable.start(tiempo_invulnerabilidad)
	_efecto_danio()
	if vidas_actuales <= 0:
		morir()

func _efecto_danio() -> void:
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func _on_timer_invulnerable_timeout() -> void:
	invulnerable = false

func morir() -> void:
	jugador_murio.emit()
	_efecto_muerte()
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

func _efecto_muerte() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.play()
