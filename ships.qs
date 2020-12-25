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
	level   () {return 1;} // requred spaceyard level
	is_enemy() {return false;}
	
	health  () {return 1;}
	attack  () {return 0;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 10}} // 1d10
	armor   () {return 0;} // damage reduction
	crit    () {return {miss: 1, hit: 20, x: 2}}
	
	roll      (d) {return getRandom(d) + 1;}
	baseRoll   () {return this.roll(20);}
	damageRoll () {
		const x = this.damage().x;
		return getRandom(this.count * x * this.damage().d - x + 1) + x;
	}
	
	hitTo(ship) {
		let ret = {msg:"", new_cnt: ship.count, new_hp: ship.hp, msgf: ""};
		if (ship.count <= 0) return ret;
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
			let killed = 0, ship_cnt = ship.count, ship_hp = ship.hp;
			while (dam > 0) {
				let cdam = Math.min(dam, ship_hp + ship.armor());
				dam -= cdam;
				cdam = Math.max(0, cdam - ship.armor());
				ship_hp -= cdam;
				if (ship_hp <= 0) {
					ship_cnt--;
					killed++;
					if (ship_cnt <= 0) break;
					ship_hp = ship.health();
				}
			}
			if (killed > 0) {
				ret.msgf += `\n 💥 уничтожено ${killed} ${ship.name()}`;
			}
			if (ship_cnt <= 0) {
				ret.msgf += `\n ☠️ отряд ${ship.name()} уничтожен`;
			}
			ret.new_cnt = ship_cnt;
			ret.new_hp = ship_hp;
			ret.parts = killed * ship.price();
			ret.enemy = ship.is_enemy();
			//print(killed, ship.price(), ret.parts);
		}
		ret.msg = msg;
		return ret;
	}
	
	applyHit(result) {
		this.count = result.new_cnt;
		this.hp    = result.new_hp ;
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
	damage  () {return {x: 1, d: 2}}
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
	level   () {return 2;}
	
	health  () {return 40;}
	attack  () {return 6+3;}
	defence () {return 18;}
	damage  () {return {x: 8, d: 10}}
	armor   () {return 3;}
}

class CorvetteShip extends Ship {
	name() {return "Корвет";}
	shortName() {return "Кв";}
	description() {return "Средний боевой корабль";}
	size    () {return 3;}
	capacity() {return 10;}
	price   () {return 300;}
	energy  () {return 200;}
	level   () {return 3;}
	
	health  () {return 250;}
	attack  () {return 3+3;}
	defence () {return 15;}
	damage  () {return {x: 4, d: 20}}
	armor   () {return 6;}
}

class FrigateShip extends Ship {
	name() {return "Фрегат";}
	shortName() {return "Фр";}
	description() {return "Крупный боевой корабль";}
	size    () {return 5;}
	capacity() {return 20;}
	price   () {return 700;}
	energy  () {return 400;}
	level   () {return 3;}
	
	health  () {return 300;}
	attack  () {return 4+3;}
	defence () {return 13;}
	damage  () {return {x: 6, d: 20}}
	armor   () {return 8;}
}

class CruiserShip extends Ship {
	name() {return "Крейсер";}
	shortName() {return "Кр";}
	description() {return "Боевой крейсер";}
	size    () {return 6;}
	capacity() {return 0;}
	price   () {return 1500;}
	energy  () {return 500;}
	level   () {return 4;}
	
	health  () {return 600;}
	attack  () {return 6+3;}
	defence () {return 12;}
	damage  () {return {x: 20, d: 10}}
	armor   () {return 10;}
}


function ShipModels() {return [new TradeShip(), new SmallShip(), new InterceptorShip(),
							   new CorvetteShip(), new FrigateShip(), new CruiserShip()]}

const ShipsDescription = function() {
	let msg = "\n<b> ✈️ Модели кораблей ✈️ </b>\n";
	for (const s of ShipModels()) {
		msg += `<b>${s.name()}:</b>\n`
		msg += `  ${s.description()}\n`;
		msg += `  слоты: ${s.size()}\n`;
		msg += `  вместимость: ${s.capacity()}📦\n`;
		msg += `  энергия пуска: ${s.energy()}🔋\n`;
		msg += `  ${s.health()}❤️ ${s.attack()}⚔️ ${s.defence()}🛡\n`;
		msg += `  ${s.damage().x}d${s.damage().d}🗡 ${s.armor()}👕\n`;
		msg += "  стоимость: ";
		for (let i = 0; i < Resources_base; i++) msg += getResourceCount(i, s.price());
		msg += "\n";
		msg += `  время строительства: ${time2text(s.price()*Resources_base)}\n`;
		msg += `  требеутся 🏗Верфь ${s.level()} уровня\n`;
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
	is_enemy() {return true;}
	
	health  () {return 10;}
	attack  () {return 4+3;}
	defence () {return 12;}
	damage  () {return {x: 1, d: 8}}
	armor   () {return 2;}
}

class EnemyMiddle extends Ship {
	name() {return "EnemyMiddle";}
	shortName() {return "EM";}
	description() {return "";}
	size    () {return 1;}
	capacity() {return 0;}
	price   () {return 2;}
	energy  () {return 0;}
	is_enemy() {return true;}
	
	health  () {return 100;}
	attack  () {return 5+3;}
	defence () {return 14;}
	damage  () {return {x: 2, d: 20}}
	armor   () {return 5;}
}

class EnemySenior extends Ship {
	name() {return "EnemySenior";}
	shortName() {return "ES";}
	description() {return "";}
	size    () {return 1;}
	capacity() {return 0;}
	price   () {return 40;}
	energy  () {return 0;}
	is_enemy() {return true;}
	
	health  () {return 1000;}
	attack  () {return 10+3;}
	defence () {return 10;}
	damage  () {return {x: 10, d: 8}}
	armor   () {return 14;}
}

function enemyShips() {return [new EnemyJunior(), new EnemyMiddle(), new EnemySenior()]}
