extends Area2D

# Tarik node UI dari panel scene ke sini (tahan CTRL/CMD lalu drag & drop)
@onready var dialog_panel = $NinePatchRect
@onready var dialog_label = $NinePatchRect/Label

# List obrolan random untuk NPC
var guide_dialogs = [
	"Selamat datang! Hati-hati dengan jebakan di depan sana.",
	"Hei! Jangan lupa kumpulkan Holy Poop yang kamu temui.",
	"Tempat ini cukup berbahaya, tetap waspada!",
    "Aset di sini bagus-bagus ya? Beli dong!"
]

var is_talking = false

func _ready():
	dialog_panel.hide()

func _on_body_entered(body):
	# Cek apakah yang masuk area adalah Player dan tidak sedang ngobrol
	if body.name == "Player" and not is_talking:
		start_conversation(body)

func start_conversation(player_node):
	is_talking = true
	
	# 1. Bekukan pergerakan player
	player_node.can_move = false
	
	# 2. Munculkan balon obrolan NPC
	dialog_panel.show()
	dialog_label.text = guide_dialogs.pick_random()
	
	# 3. Tunggu 3 detik 
	await get_tree().create_timer(3.0).timeout
	
	# 4. Tutup balon obrolan NPC
	dialog_panel.hide()
	
	# 5. Minta Player untuk bicara pakai balon obrolannya sendiri!
	# Menggunakan fungsi speak() yang baru saja kita buat di script Player
	await player_node.speak("Oke, siap laksanakan!", 2.0)
	
	# 6. Percakapan selesai, lepaskan player
	player_node.can_move = true
	
	# Cooldown agar dialog tidak langsung muncul lagi secara instan
	await get_tree().create_timer(2.0).timeout 
	is_talking = false
