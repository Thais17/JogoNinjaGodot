extends Node2D

onready var fumacaCena = preload("res://Scene/Fumaca.tscn")
onready var espectro2Cena = preload("res://Scene/Espectro2.tscn")

var cenaAtual = null
var rng = RandomNumberGenerator.new()

func _ready():
	cenaAtual = get_tree().current_scene
	rng.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func spawnInimigo(inimigo, nomeSpawner=null):
	var novoInimigo = inimigo.instance()
	var novaFumaca = fumacaCena.instance()
	if nomeSpawner == null:
		nomeSpawner = 'SpawnerDireito' if rng.randi_range(0, 1) else 'SpawnerEsquerdo'
	var spawner  = cenaAtual.get_node(nomeSpawner)
	novaFumaca.position = spawner.global_position
	novoInimigo.position = spawner.global_position
	cenaAtual.add_child(novoInimigo)
	cenaAtual.add_child(novaFumaca)
	novaFumaca.play()

func _on_Timer_timeout():
	spawnInimigo(espectro2Cena)

func _on_TimerSpawnerDireito_timeout():
	spawnInimigo(espectro2Cena, 'SpawnerDireito')

func _on_TimerSpawnerEsquerdo_timeout():
	spawnInimigo(espectro2Cena, 'SpawnerEsquerdo')
