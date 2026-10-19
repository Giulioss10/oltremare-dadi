extends CharacterClass # ROSARIO

# ----------------------------- V A R I A B I L I -----------------------------
## COSTANTI
# Presa con schivata inclusa
const VERIFICA_SCHIVATA: bool = true                          # vuoi verificare se il nemico schiva?
const FORMAT_PRESA: bool = not VERIFICA_SCHIVATA                                     # gestisce i \n

# Somma dadi attacco disarmato e difesa pesante
const SOMMA_DADI: Dictionary = {
	"ATT + DIF": N_DISARMATO["ATT"] + N_PESANTE["DIF"], 
	"ATT+1 + DIF+1": N_DISARMATO["ATT+1"] + N_PESANTE["DIF+1"]
}

# ------------------------------- O G G E T T I -------------------------------
func _ready() -> void:
	lista_oggetti = {} # Nessun oggetto equipaggiato di base
	aggiorna_statistiche()

# -------------------------------- A Z I O N I --------------------------------
# - Attacchi MELEE -
## Attacco DISARMATO
func _on_pugni_pressed() -> void:
	# resetta variabili
	reset()
	
	# inizializza il danno al valore del M.AM
	danni += int(m_AM.value)
	
	# attacco DISARMATO
	risultato = attacco_disarmato()
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	# oggetti offensivi
	danni += usa_oggetti_offensivi()
	
	# risultati
	terminale.text += "\nDANNI:  " + str(danni) + " Bruti"
	
	# effetto dell'aculeo di Zanna
	terminale.text += "\n\nAVVELENAMENTO!"

## ATTACCO PRESA
func _on_presa_pressed() -> void:
	# resetta variabili
	reset()
	
	# verifica che la forza sia sufficiente
	if forza_insufficiente(m_AM, terminale):
		return
	
	# inizializza il danno al valore del M.AM
	# +1 per attacchi a due mani
	danni += int(m_AM.value) +1
	
	# attacco PRESA
	risultato = attacco_presa(VERIFICA_SCHIVATA, FORMAT_PRESA)
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	# oggetti offensivi
	danni += usa_oggetti_offensivi()
	
	# risultati
	terminale.text += "\nDANNI:  " + str(danni) + " Bruti"
	
	# effetto dell'aculeo di Zanna
	if FORMAT_PRESA:
		terminale.text += "\n"
	terminale.text += "\nAVVELENAMENTO!"
	
	# verifica schivata NEMICA
	if VERIFICA_SCHIVATA:
		var tiro_schivata = risultato["tiri"]["SCH"][0]
		terminale.text += "\n\nTiro schivata NEMICO: " + str(tiro_schivata)
		riduzione += risultato["riduzione"]
		schivata(riduzione, terminale)

## Attacco PUGNO DEL PICCHIO (2+1 ATT, 2+4 ATT+1)
func _on_pugno_del_picchio_pressed() -> void:
	# resetta variabili
	reset()
	
	# inizializza il danno al valore del M.AM
	danni += int(m_AM.value)
	
	# tiri dadi ATT
	risultato = tira(SOMMA_DADI["ATT + DIF"], ATTACCO)
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	terminale.text += "\n"
	
	# tiri dadi ATT+1
	risultato = tira(SOMMA_DADI["ATT+1 + DIF+1"], ATTACCO_PIU1)
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	# oggetti offensivi
	danni += usa_oggetti_offensivi()
	
	# risultati
	terminale.text += "\nDANNI:  " + str(danni) + " Sparo"
	
	# effetto dell'aculeo di Zanna
	terminale.text += "\n\nAVVELENAMENTO!"

# - Attacchi AOE -
## Attacco VORTICE VELENOSO (3 ATT+1, 2 ARC)
func _on_vortice_velenoso_pressed() -> void:
	# resetta variabili
	reset()
	
	# tiri dadi ATT+1
	risultato = tira(3, ATTACCO_PIU1)
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	terminale.text += "\n"
	
	# tiri dadi ARC
	risultato = tira(2, ARCANO)
	danni += risultato["valore"]
	terminale.text += risultato["testo"]
	
	# oggetti offensivi
	danni += usa_oggetti_offensivi()
	
	# risultati
	terminale.text += "\nDANNI:  " + str(danni) + " Arcano"
	
	# effetto dell'aculeo di Zanna
	terminale.text += "\n\nAVVELENAMENTO!"

# - Difese -
## Difesa CLASSE PESANTE
func _on_difesa_pressed() -> void:
	# resetta variabili
	reset()
	
	# difesa classe PESANTE
	risultato = difesa_pesante()
	riduzione += risultato["valore"]
	terminale.text += risultato["testo"] + "\nRIDUZIONE:  " + str(riduzione)
	
	# inserisci danni ricevuti e calcola danni subiti
	info_danni = await inserisci_danni_ricevuti()
	danni_subiti = danno_subito(info_danni, riduzione, terminale)

## Difesa CHIUSURA DEL RICCIO (1+2 DIF, 4+2 DIF+1)
func _on_chiusura_del_riccio_pressed() -> void:
	# resetta variabili
	reset()
	
	# tiri dadi DIF
	risultato = tira(SOMMA_DADI["ATT + DIF"], DIFESA)
	riduzione += risultato["valore"]
	terminale.text += risultato["testo"]
	
	terminale.text += "\n"
	
	# tiri dadi DIF+1
	risultato = tira(SOMMA_DADI["ATT+1 + DIF+1"], DIFESA_PIU1)
	riduzione += risultato["valore"]
	terminale.text += risultato["testo"]
	
	# risultati
	terminale.text += "\nRIDUZIONE:  " + str(riduzione)
	
	# inserisci danni ricevuti e calcola danni subiti
	info_danni = await inserisci_danni_ricevuti()
	danni_subiti = danno_subito(info_danni, riduzione, terminale)
