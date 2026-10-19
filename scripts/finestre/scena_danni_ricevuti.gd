extends Control

# ------------------------------- S E G N A L I -------------------------------
## Condividi i valori inseriti con la scena del personaggio
signal valori_inviati(valori: Dictionary)

# ------------------------------ F U N Z I O N I ------------------------------
## - UTILITÀ -
# Leggi dati
## Impacchetta i valori inseriti nell'interfaccia dei danni ricevuti
func info_danni() -> Dictionary:
	var danni_ricevuti : int  = int(%Valore_Danni_Ricevuti.value)
	var resistente     : bool = %Resistente.button_pressed
	var debole         : bool = %Debole.button_pressed
	var antiflusso     : bool = %"???".button_pressed
	var colossale      : bool = %"Attacco Colossale".button_pressed
	
	return {
		"danni ricevuti" : danni_ricevuti, 
		"resistente"     : resistente, 
		"debole"         : debole, 
		"???"            : antiflusso,
		"colossale"      : colossale,
	}

## - INTERFACCIA -
# Scena
## Torna alla selezione personaggi se premi la freccia indietro
func _on_indietro_pressed() -> void:
	var percorso_scena_giocatore : String = "res://scenes/schermate/giocatore.tscn"
	get_tree().change_scene_to_file(percorso_scena_giocatore)

# Invio dati
## Non inviare nulla se premi ❌
func _on_x_pressed() -> void:
	valori_inviati.emit({})
	queue_free()

## Invia i dati inseriti se premi ✔
func _on_check_pressed() -> void:
	valori_inviati.emit(info_danni())
	queue_free()

## Cattura input da tastiera:                                           [br][br]
## - non inviare nulla se premi ESC                                     [br][br]
## - invia i dati inseriti se premi INVIO
func _input(event: InputEvent) -> void:
	# Chiudi senza restituire
	if event.is_action_pressed("indietro"):
		get_viewport().set_input_as_handled()
		valori_inviati.emit({})
		queue_free()
	
	# Restituisci i valori inseriti
	if event.is_action_pressed("invio"):
		valori_inviati.emit(info_danni())
		queue_free()
