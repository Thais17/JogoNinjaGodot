extends KinematicBody2D

const TIPO_DANO_COLISAO = 1

var velocidade_correndo = 400
var forca_pulo = 1200
var gravidade = 50
var valocidade_max_queda = 500

var cenaAtual
var velocidadeVertical = 0
var viradoHorizontalmente = false

var forcaEspada = 1.0
var atacando = false
var horaUltimoGolpe = null
var duracaoGolpe = 400 #ms

var vivo = true
var totalVida = 200
var vida = null

var imortal = false
var horaInicioImortalidade = null
var duracaoImortalidade = 1000
var transparente = false
var horaInicioTransparente = null
var horaFimTransparente = null
var duracaoTransparente = 20

func _ready():
	cenaAtual = get_tree().current_scene
	setVida(totalVida)
	$Area2DAtaqueEspada/CollisionShape2D.disabled = true
	$Area2DAtaqueEspada.add_to_group('GrupoAreaEspada')

func isAtacando():
	return atacando

func getLado():
	return -1 if viradoHorizontalmente else 1
	
func getForcaEspada():
	return forcaEspada

func _physics_process(delta):
	processaImortalidade()
	processaEntradaUsuario()

func processaImortalidade():
	var horaAtual = OS.get_system_time_msecs()
	if imortal:
		$Area2DCorpo/CollisionShape2D.disabled = true
		if not transparente and (horaInicioTransparente == null or (horaAtual - horaFimTransparente) >= duracaoTransparente):
			transparente = true
			horaInicioTransparente = horaAtual
		elif transparente and (horaAtual - horaInicioTransparente) >= duracaoTransparente:
			transparente = false
			horaFimTransparente = horaAtual
	else:
		$Area2DCorpo/CollisionShape2D.disabled = false
		transparente = false
		horaInicioTransparente = null
		horaFimTransparente = null
		
	$AnimatedSprite.modulate.a = 0.2 if transparente else 1.0
	
	if imortal and horaInicioImortalidade != null and (horaAtual - horaInicioImortalidade) > duracaoImortalidade:
		imortal = false

func processaEntradaUsuario():
	var horaAtual = OS.get_system_time_msecs()
	var direcaoMovimento
	var noChao = is_on_floor()
	
	if atacando and (horaUltimoGolpe == null or (horaAtual - horaUltimoGolpe) > duracaoGolpe):
		atacando = false
		$AnimatedSprite.animation = "Parado"
		$Area2DAtaqueEspada/CollisionShape2D.disabled = true
	
	if not atacando and Input.is_action_pressed("attack"):
		atacando = true
		$Area2DAtaqueEspada/CollisionShape2D.disabled = false
		horaUltimoGolpe = OS.get_system_time_msecs()
	
	$AnimatedSprite.offset.x = 0
	$AnimatedSprite.offset.y = 0
	
	if not noChao and not atacando:
		$AnimatedSprite.animation = "Pulando"
	elif not noChao and atacando:
		$AnimatedSprite.animation = "PuloAtacando"
	elif noChao and atacando:
		$AnimatedSprite.animation = "Atacando"
		$AnimatedSprite.offset.x = 130 * (-1 if viradoHorizontalmente else 1)
		$AnimatedSprite.offset.y = 10
	elif Input.is_action_pressed("ui_right"):
		$AnimatedSprite.animation = "Correndo"
	elif Input.is_action_pressed("ui_left"):
		$AnimatedSprite.animation = "Correndo"
	else:
		$AnimatedSprite.animation = "Parado"

	if Input.is_action_pressed("ui_right"):
		viradoHorizontalmente = false
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		viradoHorizontalmente = true
		$AnimatedSprite.flip_h = true
	
	$Area2DAtaqueEspada.position.x = (-1 if viradoHorizontalmente else 1) * abs($Area2DAtaqueEspada.position.x)
	
	direcaoMovimento = 0
	if noChao and atacando:
		pass
	elif Input.is_action_pressed("ui_right"):
		direcaoMovimento = 1
	elif Input.is_action_pressed("ui_left"):
		direcaoMovimento = -1
	
	if noChao:
		 velocidadeVertical = 1
	else:
		velocidadeVertical += gravidade
		if velocidadeVertical > valocidade_max_queda:
			velocidadeVertical = valocidade_max_queda
	
	if noChao and not atacando and Input.is_action_pressed("ui_up"):
		velocidadeVertical = -forca_pulo
	
	move_and_slide(Vector2(direcaoMovimento * velocidade_correndo, velocidadeVertical),Vector2(0,-1))

func diminuiVida(dano):
	setVida(vida-dano)

func setVida(valorVida):
	vida = valorVida
	$BarraVida.setValorVida(max(0, float(valorVida)/totalVida)*100)


func recebeDano(tipoDano, valorDano):
	diminuiVida(valorDano)
	imortal = true
	horaInicioImortalidade = OS.get_system_time_msecs()
	
	#if vida <= 0.0:
	#	horaInicioMorte = OS.get_system_time_msecs()
	#	morrendo = true

func _on_Area2DCorpo_area_entered(area):
	if not imortal and vivo:
		if area.is_in_group('Monstro'):
			var monstro = area.get_parent()
			if not monstro.estaMorrendo():
				var dano = monstro.getDanoColisao()
				recebeDano(TIPO_DANO_COLISAO, dano)
