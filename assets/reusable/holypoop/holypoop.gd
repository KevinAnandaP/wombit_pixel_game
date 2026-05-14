extends Area2D

# Variabel untuk menyimpan posisi awal agar ngambangnya tidak geser jauh
var start_y: float

func _ready():
	# Catat posisi Y saat pertama kali item ini ditaruh di level
	start_y = position.y

func _process(delta):
	# Bikin efek ngambang (floating) naik turun pakai fungsi matematika Sinus
	# Angka 0.005 mengatur kecepatan naik turun, angka 5.0 mengatur tinggi/rendahnya
	position.y = start_y + sin(Time.get_ticks_msec() * 0.005) * 5.0

func _on_body_entered(body):
	# Cek apakah yang menyentuh item ini adalah Player
	if body.name == "Player":
		# Suruh Player nambahin skornya (fungsinya akan kita buat di Tahap 3)
		body.add_poop()
		
		# Hapus item ini dari layar (dimakan/diambil)
		queue_free()
