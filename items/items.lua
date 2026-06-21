-- À ajouter dans ox_inventory/data/items.lua
	['rolex'] = {
		label = 'Montre de luxe',
		weight = 100,
		stack = true,
		close = true,
		description = "Une montre en or qui brille. Tombée du camion ?",
		client = 'rolex.png',
	},

	['gold_ring'] = {
		label = 'Bague en or',
		weight = 10,
		stack = true,
		close = true,
		description = "Un bijou simple mais qui vaut son pesant d'or.",
		client = 'gold_ring.png',
	},

	['gold_chain'] = {
		label = 'Collier en or',
		weight = 50,
		stack = true,
		close = true,
		description = "Chaîne en or 24 carats.",
		client = 'gold_chain.png',
	},

	['iphone'] = {
		label = 'iPhone volé',
		weight = 200,
		stack = false, -- En général on ne stack pas les téléphones
		close = true,
		description = "Il est verrouillé iCloud, bon pour les pièces.",
		client = 'iphone.png',
	},

	['diamond'] = {
		label = 'Diamant',
		weight = 5,
		stack = true,
		close = true,
		description = "Un petit caillou qui vaut très cher."
		client = 'diamond.png',
	},