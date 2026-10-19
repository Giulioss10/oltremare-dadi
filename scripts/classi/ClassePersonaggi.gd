## Variabili e Funzioni utilizzate da tutti i personaggi
class_name CharacterClass
extends DiceClass

# ----------------------------- V A R I A B I L I -----------------------------
## COSTANTI
# Difese standard
const N_LEGGERA : Dictionary = {"DIF": 1, "SCH": 1  }
const N_MEDIA   : Dictionary = {"DIF": 2, "DIF+1": 1}
const N_PESANTE : Dictionary = {"DIF": 1, "DIF+1": 4}

# Attacchi standard
const N_DISARMATO : Dictionary = {"ATT": 2, "ATT+1": 2}
const N_PRESA     : Dictionary = {"ATT": 4, "ATT+1": 3}

# Scene
const SCENA_GIOCATORE      : String      = "res://scenes/schermate/giocatore.tscn"
const SCENA_DANNI_RICEVUTI : PackedScene = preload("res://scenes/finestre/danni_ricevuti.tscn")
const SCENA_OGGETTI        : PackedScene = preload("res://scenes/finestre/oggetti.tscn")

## OUTPUT FUNZIONI 
# Tiri
var risultato : Dictionary
var danni     : int
var riduzione #: int o float
var gittata   : int
var cura      : int

# Danni subiti
var info_danni   : Dictionary
var danni_subiti : int

# Oggetti
var lista_oggetti : Dictionary

## MODIFICATORI
@onready var m_AM : SpinBox = assegna_modificatore(get_node_or_null("%Valore_M"))
@onready var m_AF : SpinBox = assegna_modificatore(get_node_or_null("%Valore_F"))

## CASELLA DI TESTO
@onready var terminale : TextEdit = %Testo

# ------------------------------ F U N Z I O N I ------------------------------
## - TIRI -
# Difese
## Difesa classe LEGGERA (1 DIF, 1 SCH)
func difesa_leggera(newline: bool = true) -> Dictionary:
	var _tiri = {"DIF" : [], "SCH" : []}
	var _valore = 0
	var _testo = ""
	var _risultato: Dictionary
	
	# tiro dado DIF
	_risultato = tira(N_LEGGERA["DIF"], DIFESA)
	_tiri["DIF"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	if newline:
		_testo += "\n"
	
	# tiro dado SCH
	_risultato = tira(N_LEGGERA["SCH"], SCHIVATA)
	_tiri["SCH"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	return {"tiri": _tiri, "valore": _valore, "testo": _testo}

## Difesa classe MEDIA (2 DIF, 1 DIF+1)
func difesa_media(newline: bool = true) -> Dictionary:
	var _tiri = {"DIF" : [], "DIF+1" : []}
	var _valore = 0
	var _testo = ""
	var _risultato: Dictionary
	
	# tiro dadi DIF
	_risultato = tira(N_MEDIA["DIF"], DIFESA)
	_tiri["DIF"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	if newline:
		_testo += "\n"
	
	# tiro dadi DIF+1
	_risultato = tira(N_MEDIA["DIF+1"], DIFESA_PIU1)
	_tiri["DIF+1"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	return {"tiri": _tiri, "valore": _valore, "testo": _testo}

## Difesa classe PESANTE (1 DIF, 4 DIF+1)
func difesa_pesante(newline: bool = true) -> Dictionary:
	var _tiri = {"DIF" : [], "DIF+1" : []}
	var _valore = 0
	var _testo = ""
	var _risultato: Dictionary
	
	# tiro dadi DIF
	_risultato = tira(N_PESANTE["DIF"], DIFESA)
	_tiri["DIF"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	if newline:
		_testo += "\n"
	
	# tiro dadi DIF+1
	_risultato = tira(N_PESANTE["DIF+1"], DIFESA_PIU1)
	_tiri["DIF+1"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	return {"tiri": _tiri, "valore": _valore, "testo": _testo}

# Attacchi
## Attacco DISARMATO (2 ATT, 2 ATT+1)
func attacco_disarmato(newline: bool = true) -> Dictionary:
	var _tiri = {"ATT" : [], "ATT+1" : []}
	var _valore = 0
	var _testo = ""
	var _risultato: Dictionary
	
	# tiro dadi ATT
	_risultato = tira(N_DISARMATO["ATT"], ATTACCO)
	_tiri["ATT"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	if newline:
		_testo += "\n"
	
	# tiro dadi ATT+1
	_risultato = tira(N_DISARMATO["ATT+1"], ATTACCO_PIU1)
	_tiri["ATT+1"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	return {"tiri": _tiri, "valore": _valore, "testo": _testo}

## Attacco PRESA (4 ATT, 3 ATT+1)
func attacco_presa(schivata_nemico: bool = false, newline: bool = true) -> Dictionary:
	var _tiri = {"ATT" : [], "ATT+1" : [], "SCH" : []}
	var _valore = 0
	var _riduzione = 0
	var _testo = ""
	var _risultato: Dictionary
	
	# tiro dadi ATT
	_risultato = tira(N_PRESA["ATT"], ATTACCO)
	_tiri["ATT"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	if newline:
		_testo += "\n"
	
	# tiro dadi ATT+1
	_risultato = tira(N_PRESA["ATT+1"], ATTACCO_PIU1)
	_tiri["ATT+1"].append(_risultato["tiri"])
	_valore += _risultato["valore"]
	_testo += _risultato["testo"]
	
	# tiro schivata NEMICO
	if schivata_nemico:
		_risultato = tira(1, SCHIVATA)
		_tiri["SCH"].append(_risultato["tiri"])
		_riduzione += _risultato["valore"]
		return {"tiri": _tiri, "valore": _valore, "testo": _testo, "riduzione": _riduzione}
	else:
		return {"tiri": _tiri, "valore": _valore, "testo": _testo}

# Effetti di stato
## Danno MARCHIATURA (2 ATT+1 Puri)
func marchiatura(_terminale: TextEdit, newline: bool = true) -> void:
	var _valore = 0
	var _risultato: Dictionary
	
	# spazio variabile, minimo 1
	for _i in range(1 + int(newline)):
		_terminale.text += "\n"
	
	# tiri dadi ATT+1
	_risultato = tira(2, ATTACCO_PIU1)
	_valore += _risultato["valore"]
	_terminale.text += _risultato["testo"]
	_terminale.text += "MARCHIATURA:  " + str(_valore) + " Puri"

## - UTILITÀ -
# Initializzazione
## Metti a 0 i modificatori non assegnati
func assegna_modificatore(nodo_modificatore: Node) -> SpinBox:
	var modificatore: SpinBox
	
	if is_instance_valid(nodo_modificatore):
		modificatore = nodo_modificatore
	else:
		modificatore = SpinBox.new()
		modificatore.value = 0
	
	return modificatore

## Resetta le variabili all'inizio di ogni azione
func reset() -> void:
	danni = 0
	riduzione = 0
	gittata = 0
	cura = 0
	terminale.text = ""

# Abilità
## Verifica se la schivata è riuscita
func schivata(_riduzione, _terminale: TextEdit, newline: bool = true) -> bool:
	if newline :
		_terminale.text += "\n"
	
	if _riduzione < INF :
		_terminale.text += "RIDUZIONE:  " + str(_riduzione)
		return false
	else :
		_terminale.text += "SCHIVA!!!"
		return true

## Verifica se la presa non è utilizzabile
func forza_insufficiente(_m_AM: SpinBox, _terminale: TextEdit) -> bool:
	if  _m_AM.value < 1:
		_terminale.text += "Forza insufficiente"
		return true
	else:
		return false

## Calcola il danno subito
func danno_subito(_info_danni: Dictionary, _riduzione: int, _terminale: TextEdit, newline: bool = true) -> int:
	# se non ci sono info salta il calcolo
	if _info_danni.is_empty():
		return -1
	
	var _danni_ricevuti : int  = _info_danni["danni ricevuti"]
	var _resistente     : bool = _info_danni["resistente"] 
	var _debole         : bool = _info_danni["debole"]
	var _antiflusso     : bool = _info_danni["???"]
	var _colossale      : bool = _info_danni["colossale"]
	
	var _neutrale     : bool   = _resistente == _debole
	var _malus        : int    = int(_antiflusso)
	var _danni_subiti : int    = max(_danni_ricevuti - _riduzione, 0)
	var _testo        : String = " ("
	
	if newline :
		_terminale.text += "\n"
	
	if _colossale:
		var _risultato : Dictionary = tira(1, SCHIVATA)
		_terminale.text += "\nDado Attacco Colossale: " + str(_risultato["tiri"]) + "\n"
		if _risultato["valore"] == INF:
			_terminale.text += "SCHIVA!!!"
			return 0
		else:
			_danni_subiti = max(_danni_subiti - _risultato["valore"], 0)
	
	if _neutrale:
		_danni_subiti *= 1 + 1*_malus
		_testo += "neutrale" + "???".repeat(_malus) + ")"
	elif _resistente:
		@warning_ignore("narrowing_conversion")
		_danni_subiti *= 0.5 + 0.25*_malus
		_testo += "resistente" + "???".repeat(_malus) + ")"
	elif _debole:
		_danni_subiti *= 2 + 1*_malus
		_testo += "debole" + "???".repeat(_malus) + ")"
	
	_terminale.text += "DANNI SUBITI: " + str(_danni_subiti) + _testo
	
	return _danni_subiti

# Oggetti
## Aggiungi/rimuovi le statistiche degli oggetti ai modificatori del personaggio
func aggiorna_statistiche() -> void:
	for oggetti in lista_oggetti:
		lista_oggetti[oggetti].aggiorna_statistiche()

## Tira i dadi di ogni oggetto offensivo attivo e restituisce il valroe totale
func usa_oggetti_offensivi() -> int:
	var danno_bonus: int = 0
	for oggetti in lista_oggetti:
		if lista_oggetti[oggetti].attivo:
			danno_bonus += lista_oggetti[oggetti].tira_danni()
	return danno_bonus

## - INTERFACCIA -
# Finestre
## Apre la finestra dei danni ricevuti e attende i dati inseriti dall'utente
func inserisci_danni_ricevuti() -> Dictionary:
	var finestra_danni_ricevuti: Control = SCENA_DANNI_RICEVUTI.instantiate()
	add_child(finestra_danni_ricevuti)
	
	return await finestra_danni_ricevuti.valori_inviati

## Apre la finestra degli oggetti e aggiorna lista degli oggetti e statistiche
func _on_pulsante_oggetti_pressed() -> void:
	var finestra_oggetti: Control = SCENA_OGGETTI.instantiate()
	finestra_oggetti.oggetti_personaggio = lista_oggetti
	finestra_oggetti.m_AM                = m_AM
	finestra_oggetti.m_AF                = m_AF
	finestra_oggetti.terminale           = terminale
	add_child(finestra_oggetti)
	
	lista_oggetti = await finestra_oggetti.oggetti_attivati
	aggiorna_statistiche()

# Scena
## Torna alla selezione personaggi se premi ESC
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("indietro"):
		get_tree().change_scene_to_file(SCENA_GIOCATORE)

## Torna alla selezione personaggi se premi la freccia indietro
func _on_indietro_pressed() -> void:
	get_tree().change_scene_to_file(SCENA_GIOCATORE)
