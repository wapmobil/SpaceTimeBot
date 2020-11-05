// Базовый класс корабля
class Ship {
	constructor(){
		this.count = 0;
		this.hp = this.health();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
	name() {return "";}
	description() {return "";}
	
	capacity() {return 0;} // max cargo
	price   () {return 0;} // each resource
	energy  () {return 0;} // launch price
	
	health  () {return 1;}
	attack  () {return 0;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 8}}
	armor   () {return 0;} // damage reduction
	
	criticalMissD() {return 1;}
	criticalHitD () {return 20;}
	criticalHitX () {return 2;} // x2
	
	roll      (d) {return getRandom(d) + 1;}
	baseRoll   () {return this.roll(20);}
	damageRoll () {return getRandom((this.damage().d - 1) * this.damage().x + 1) + this.damage().x;}
	
	hitTo(ship) {
		let thisAR = this.baseRoll();
		let dam = this.damageRoll();
		let hit = false;
		let msg = `${this.name()} attack ${ship.name()} (roll ${thisAR}): `;
		if (thisAR >= this.criticalHitD()) {
			hit = true;
			dam *= this.criticalHitX();
			msg += `critical hit x${this.criticalHitX()}`;
		} else if (thisAR <= this.criticalMissD()) {
			msg += `critical miss`;
		} else if ((thisAR + this.attack()) >= ship.defence()) {
			hit = true;
			msg += `hit`;
		} else {
			msg += `miss`;
		}
		if (hit) {
			dam = Math.max(0, dam * ship.armor());
			ship.hp -= dam;
			msg += `: ${dam}`;
			if (ship.hp <= 0) {
				msg += `\n  ${ship.name()} destroyed`
			}
		}
		print(msg);
	}
	
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
	capacity() {return 10;}
	price   () {return 100;}
	energy  () {return 100;}
	health  () {return 100;}
	armor   () {return 5;}
}

class SmallShip extends Ship {
	name() {return "Малютка";}
	description() {return "Корабль общего назначения";}
	capacity() {return 1;}
	price   () {return 10;}
	energy  () {return 10;}
	health  () {return 10;}
	armor   () {return 1;}
}

function ShipModels() {return [new TradeShip(), new SmallShip()]};

const ShipsDescription = function() {
	let msg = "\n<b> ✈️ Модели кораблей ✈️ </b>\n";
	for (const s of ShipModels()) {
		msg += `<b>${s.name()}:</b> ${s.description()}\n`;
		msg += `  вместимость: ${s.capacity()}📦\n`;
		msg += `  энергия пуска: ${s.energy()}🔋\n`;
		msg += `  cтоимость: `;
		for (let i = 0; i < Resources.length; i++) msg += getResourceCount(i, s.price());
		msg += "\n";
		msg += `  время строительства: ${time2text(s.price()*Resources.length)}\n`;
	}
	return msg;
}();
