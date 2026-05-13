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
	
	# 2. Munculkan panel dan teks NPC secara random
	dialog_panel.show()
	# pick_random() akan memilih salah satu teks dari array secara acak
	dialog_label.text = "NPC:\n" + guide_dialogs.pick_random()
	
	# 3. Tunggu 3 detik (biarkan player membaca)
	await get_tree().create_timer(3.0).timeout
	
	# 4. Ganti teks dengan balasan Player
	dialog_label.text = "Player:\nOke, siap laksanakan!"
	
	# 5. Tunggu 2 detik lagi
	await get_tree().create_timer(2.0).timeout
	
	# 6. Percakapan selesai, tutup panel dan lepaskan player
	dialog_panel.hide()
	player_node.can_move = true
	
	# Cooldown agar dialog tidak langsung muncul lagi secara instan
	await get_tree().create_timer(2.0).timeout 
	is_talking = false
