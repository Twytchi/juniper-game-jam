extends Area2D



# Fonction pour activer la hitbox
func enable_hitbox():
	monitoring = true
	monitorable = true 

# Fonction pour désactiver la hitbox
func disable_hitbox():
	monitoring = false
	monitorable = false
	visible = false 
