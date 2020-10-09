// Базовый класс корабля
class Ship {
	constructor(id){
		this.count = 0;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
	name() {return "";}
	description() {return "";}
	capacity() {return 0;}
	energy() {return 0;}
	health() {return 1;}
	armor() {return 0;}
	attack() {return 0;}
	damage() {return {b:1, d:8}}
	price() {return 0;}
	info(detail) {
		let msg = `<b>${this.name()}:</b> ${this.count} шт.\n`
		if (detail) {
			msg += `  ${this.description()}\n`;
			msg += `  вместимость: ${this.capacity()}📦\n`;
			msg += `  энергия пуска: ${this.energy()}🔋\n`;
		}
		return msg;
	}
}

class TradeShip extends Ship {
	name() {return "Грузовик";}
	description() {return "Торговый корабль";}
	energy() {return 100;}
	health() {return 100;}
	armor() {return 5;}
	capacity() {return 20;}
	price() {return 100;}
}
