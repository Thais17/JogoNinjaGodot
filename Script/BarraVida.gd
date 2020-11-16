extends Node2D

const COR_VERDE = Color('#008b1c')
const COR_AMARELO = Color('#fdff00')
const COR_VERMELHO = Color('#ff0000')

const TAMANHO_BARRA = 200

var corFundo = null
var corFrente = null

var valorMax = 100
var valorVida = 100

func _ready():
	valorVida = 100
	atualizaBarraVida()

func setValorVida(valor):
	valorVida = valor
	atualizaBarraVida()
	
func atualizaBarraVida():
	if valorVida >= valorMax:
		corFrente = COR_VERDE
	elif valorVida < valorMax and valorVida >= valorMax/2.0:
		corFrente = COR_AMARELO.linear_interpolate(COR_VERDE, (valorVida-valorMax/2.0)/(valorMax-valorMax/2.0))
	elif valorVida < valorMax/2.0 and valorVida >= 0:
		corFrente = COR_VERMELHO.linear_interpolate(COR_AMARELO, (valorVida)/(valorMax/2.0))
	else:
		corFrente = COR_VERMELHO
	corFundo = corFrente.darkened(0.4)
	$ColorRectFrente.color = corFrente
	$ColorRectFundo.color = corFundo
	$ColorRectFrente.rect_size.x = TAMANHO_BARRA * (min(float(valorVida)/valorMax, valorMax))


#func _process(delta):
#	pass
