extends PanelContainer

@onready var dialogue = $Dialogue

# Exporting a variable lets you type text directly into the Godot Inspector to test it!
@export_multiline var test_text: String = "Hello traveler! How can I help you today?" :
	set(value):
		test_text = value
		if is_node_ready():
			dialogue.text = test_text

func _ready() -> void:
	# Hide the panel by default when the game starts
	hide()

# Call this function from your Player or NPC script
func show_dialog(text_to_display: String) -> void:
	dialogue.text = text_to_display
	show()

# Optional: A function to hide it when the conversation ends
func close_dialog() -> void:
	hide()
	dialogue.text = ""
