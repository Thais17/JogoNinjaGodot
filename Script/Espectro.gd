extends KinematicBody2D

onready var ossoCena = preload("res://Scene/Osso.tscn")

var danoPorColisao = 5

var gravidade = 50
var valocidade_max_queda = 500

var velocidade = 40
var velocidadeVertical = 0
var velocidadeMovimentoDano = 300

var morto = false
var morrendo = false
var horaInicioMorte = null
var duracaoMorte = 900 #ms
var horaInicioDesaparecimento = null
var duracaoDesaparecimento = 900

var ladoDano = 1
var recebendoDano = false
var horaInicioDano = null
var duracaoDano = 1500 #ms

var totalVida = 20
var vida = null

var rng = RandomNumberGenerator.new()
var probabilidadeMagia = 0.01
var atacandoMagia = false

func _ready():
	rng.randomize()
	$Area2D.add_to_group('Monstro')
	setVida(totalVida)
	
func diminuiVida(dano):
	setVida(vida-dano)

func setVida(valorVida):
	vida = valorVida
	$BarraVida.setValorVida(max(0, float(valorVida)/totalVida)*100)

func _process(delta):
	
	if morrendo:
		animaMorte()
	elif recebendoDano:
		animaDano()
	elif rng.randf_range(0, 1) <= probabilidadeMagia:
		atacaMagia()
	else:
		perseguePersonagem()

func atacaMagia():
	atacandoMagia = true
	

func animaMorte():
	var horaAtual = OS.get_system_time_msecs()
	$AnimatedSprite.animation = "Morrendo"
	$AnimationPlayer.stop(true)
	var duracaoAtual = horaAtual - horaInicioDano
	
	$AnimatedSprite.modulate.a = (1 - float(max(0, min(duracaoAtual - duracaoMorte, duracaoDesaparecimento))) / duracaoDesaparecimento)
	
	if duracaoAtual > (duracaoMorte + duracaoDesaparecimento):
		morto = true
		$".".queue_free()

func animaDano():
	var horaAtual = OS.get_system_time_msecs()
	$AnimatedSprite.animation = "Dano"
	var duracaoDanoAtual = horaAtual - horaInicioDano
	move_and_slide(Vector2(ladoDano * velocidadeMovimentoDano * (abs(float(duracaoDano) - duracaoDanoAtual)/duracaoDano), 0),Vector2(0,-1))
	
	if (duracaoDanoAtual) > duracaoDano:
		recebendoDano = false

func perseguePersonagem():
	var noChao = is_on_floor()
	
	$AnimatedSprite.animation = "Andando"
	var cenaRaiz = get_tree().get_current_scene()
	var cenaPersonagem = cenaRaiz.get_node('Personagem')
	var personagem = cenaPersonagem.get_child(0)
	var posicaoPersonagem = cenaPersonagem.get_node('Position2D').global_position
	var minhaPosicao = $Position2D.global_position
	var direcaoMovimento = 0
	if minhaPosicao.x < posicaoPersonagem.x:
		direcaoMovimento = 1
		$AnimatedSprite.flip_h = false
	else:
		direcaoMovimento = -1
		$AnimatedSprite.flip_h = true
	
	if noChao:
		 velocidadeVertical = 1
	else:
		velocidadeVertical += gravidade
		if velocidadeVertical > valocidade_max_queda:
			velocidadeVertical = valocidade_max_queda
	
	move_and_slide(Vector2(direcaoMovimento * velocidade, velocidadeVertical),Vector2(0,-1))

func recebeDano(ladoAtaque, forcaEspada):
	diminuiVida(10)
	ladoDano = ladoAtaque
	horaInicioDano = OS.get_system_time_msecs()
	recebendoDano = true
	
	if vida <= 0.0:
		horaInicioMorte = OS.get_system_time_msecs()
		morrendo = true
		$".".get_node("Area2D").get_node("CollisionShape2D").disabled = true

func estaMorrendo():
	return morrendo

func getDanoColisao():
	return danoPorColisao

func _on_Area2D_area_entered(area):
	if not recebendoDano:
		if area.is_in_group('GrupoAreaEspada'):
			var personagem = area.get_parent()
			var estaAtacando = personagem.isAtacando()
			if estaAtacando:
				var ladoAtaque = personagem.getLado()
				var forcaEspada = personagem.getForcaEspada()
				recebeDano(ladoAtaque, forcaEspada)
