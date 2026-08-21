extends Area2D

@onready var animated_sprite = $AnimatedSprite2D # $rutas para los nodos
@onready var collision_shape = $CollisionShape2D # $rutas para los nodos

signal moneda_recogida
#Se puede trabajar con señales para un archivo global 
func _ready():
	animated_sprite.play("default")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		recoger_moneda()
#Conetacmos las señales y vemos que la referencia al player este bien
func recoger_moneda():
	#Cuando el player choque con el area y colision para lo de abajo
	moneda_recogida.emit() #Emite la señal 
	collision_shape.disabled = true #desactiva la colision 
	animated_sprite.visible = false #oculta el sprite
	queue_free()#y con esta funcion elimina el objeto
	
	#otra cosa que se podria hacer es sumar un contador global
#func Contador_Monedas():
#	Global.monedas += 2;
#ejemplo sencillo despues lo amplio
