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
	shortName() {return "";}
	description() {return "";}
	
	size    () {return 1;} // size in angar
	capacity() {return 0;} // max cargo
	price   () {return 0;} // each resource
	energy  () {return 0;} // launch price
	
	health  () {return 1;}
	attack  () {return 0;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 10}} // 1d10
	armor   () {return 0;} // damage reduction
	crit    () {return {miss: 1, hit: 20, x: 2}}
	
	roll      (d) {return getRandom(d) + 1;}
	baseRoll   () {return this.roll(20);}
	damageRoll () {
		const c = this.count * this.damage().x;
		return getRandom((this.damage().d - 1) * c + 1) + c;
	}
	
	hitTo(ship) {
		if (ship.count <= 0) return "";
		const thisAR = this.baseRoll();
		let dam = this.damageRoll();
		let hit = false;
		let msg = `${this.name()} ⚔️ ${ship.name()} (${thisAR}🎲):\n`;
		if (thisAR >= this.crit().hit) {
			hit = true;
			dam *= this.crit().x;
			msg += `🥊критическое попадание x${this.crit().x}`;
		} else if (thisAR <= this.crit().miss) {
			msg += `🌪промах`;
		} else if ((thisAR + this.attack()) >= ship.defence()) {
			hit = true;
			msg += `🗡попадание`;
		} else {
			msg += `☁️промах`;
		}
		if (hit) {
			msg += `:-${dam}💔`;
			let killed = 0;
			while (dam > 0) {
				let cdam = Math.min(dam, ship.hp + ship.armor());
				dam -= cdam;
				cdam = Math.max(0, cdam - ship.armor());
				ship.hp -= cdam;
				if (ship.hp <= 0) {
					ship.count--;
					killed++;
					if (ship.count <= 0) break;
					ship.hp = ship.health();
				}
			}
			if (ship.count <= 0) {
				msg += `\n ☠️ отряд ${ship.name()} уничтожен`
			} else if (killed > 0) {
				msg += `\n 💥 уничтожено ${killed} ${ship.name()}`
			}
		}
		return msg;
	}
	
	info(detail) {
		let msg = `${this.name()}: ${this.count} шт.\n`
		if (detail) {
			msg += `  ${this.description()}\n`;
			msg += `  вместимость: ${this.capacity()}📦\n`;
			msg += `  энергия пуска: ${this.energy()}🔋\n`;
		}
		return msg;
	}
	
	infoBattle(bt) {
		let nm = this.shortName();
		if (bt) return this.name() + " " + this.count + "шт";
		let cn = `${this.count}✈️${this.hp}❤️`;
		cn = cn.padEnd(18);
		return `${nm}:${cn}`;
	}
}


class TradeShip extends Ship {
	name() {return "Грузовик";}
	shortName() {return "Гр";}
	description() {return "Торговый корабль";}
	size    () {return 2;}
	capacity() {return 30;}
	price   () {return 100;}
	energy  () {return 100;}
	
	health  () {return 100;}
	attack  () {return 0;}
	defence () {return 5;}
	damage  () {return {x: 0, d: 0}}
	armor   () {return 2;}
}

class SmallShip extends Ship {
	name() {return "Малютка";}
	shortName() {return "Мл";}
	description() {return "Корабль общего назначения";}
	capacity() {return 2;}
	price   () {return 10;}
	energy  () {return 10;}
	
	health  () {return 10;}
	attack  () {return 1+3;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 4}}
	armor   () {return 2;}
}

class InterceptorShip extends Ship {
	name() {return "Перехватчик";}
	shortName() {return "Пх";}
	description() {return "Маневреный малый боевой корабль";}
	size    () {return 2;}
	capacity() {return 0;}
	price   () {return 100;}
	energy  () {return 100;}
	
	health  () {return 25;}
	attack  () {return 6+3;}
	defence () {return 18;}
	damage  () {return {x: 4, d: 10}}
	armor   () {return 3;}
}

class CorvetteShip extends Ship {
	name() {return "Корвет";}
	shortName() {return "Кв";}
	description() {return "Средний боевой корабль";}
	size    () {return 3;}
	capacity() {return 0;}
	price   () {return 300;}
	energy  () {return 300;}
	
	health  () {return 150;}
	attack  () {return 3+3;}
	defence () {return 15;}
	damage  () {return {x: 2, d: 16}}
	armor   () {return 4;}
}

class FrigateShip extends Ship {
	name() {return "Фрегат";}
	shortName() {return "Фр";}
	description() {return "Крупный боевой корабль";}
	size    () {return 5;}
	capacity() {return 0;}
	price   () {return 400;}
	energy  () {return 400;}
	
	health  () {return 250;}
	attack  () {return 4+3;}
	defence () {return 14;}
	damage  () {return {x: 3, d: 20}}
	armor   () {return 6;}
}

class CruiserShip extends Ship {
	name() {return "Крейсер";}
	shortName() {return "Кр";}
	description() {return "Боевой крейсер";}
	size    () {return 6;}
	capacity() {return 0;}
	price   () {return 500;}
	energy  () {return 500;}
	
	health  () {return 500;}
	attack  () {return 6+3;}
	defence () {return 12;}
	damage  () {return {x: 5, d: 20}}
	armor   () {return 8;}
}


function ShipModels() {return [new TradeShip(), new SmallShip(), new InterceptorShip(),
							   new CorvetteShip(), new FrigateShip(), new CruiserShip()]}

const ShipsDescription = function() {
	let msg = "\n<b> ✈️ Модели кораблей ✈️ </b>\n";
	for (const s of ShipModels()) {
		msg += `<b>${s.name()}:</b> ${s.description()}\n`;
		msg += `  слоты: ${s.size()}\n`;
		msg += `  вместимость: ${s.capacity()}📦\n`;
		msg += `  энергия пуска: ${s.energy()}🔋\n`;
		msg += `  ${s.health()}❤️ ${s.attack()}⚔️ ${s.defence()}🛡\n`;
		msg += `  ${s.damage().x}d${s.damage().d}🗡 ${s.armor()}👕\n`;
		msg += "  стоимость: ";
		for (let i = 0; i < Resources.length; i++) msg += getResourceCount(i, s.price());
		msg += "\n";
		msg += `  время строительства: ${time2text(s.price()*Resources.length)}\n`;
	}
	return msg;
}();

class EnemyJunior extends Ship {
	name() {return "EnemyJunior";}
	shortName() {return "EJ";}
	description() {return "";}
	size    () {return 1;}
	capacity() {return 0;}
	price   () {return 0;}
	energy  () {return 0;}
	
	health  () {return 10;}
	attack  () {return 5+3;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 8}}
	armor   () {return 2;}
}

class EnemyMiddle extends Ship {
	name() {return "EnemyMiddle";}
	shortName() {return "EM";}
	description() {return "";}
	size    () {return 1;}
	capacity() {return 0;}
	price   () {return 0;}
	energy  () {return 0;}
	
	health  () {return 100;}
	attack  () {return 8+3;}
	defence () {return 12;}
	damage  () {return {x: 1, d: 20}}
	armor   () {return 5;}
}

class EnemySenior extends Ship {
	name() {return "EnemySenior";}
	shortName() {return "ES";}
	description() {return "";}
	size    () {return 1;}
	capacity() {return 0;}
	price   () {return 0;}
	energy  () {return 0;}
	
	health  () {return 1000;}
	attack  () {return 10+3;}
	defence () {return 16;}
	damage  () {return {x: 4, d: 20}}
	armor   () {return 10;}
}

function enemyShips() {return [new EnemyJunior(), new EnemyMiddle(), new EnemySenior()]}
