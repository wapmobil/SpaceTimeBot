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
		if (ship.count <= 0) return;
		let thisAR = this.baseRoll();
		let dam = this.damageRoll();
		let hit = false;
		let msg = `${this.name()} attack ${ship.name()} (roll ${thisAR}): `;
		if (thisAR >= this.crit().hit) {
			hit = true;
			dam *= this.crit().x;
			msg += `critical hit x${this.criticalHitX()}`;
		} else if (thisAR <= this.crit().miss) {
			msg += `critical miss`;
		} else if ((thisAR + this.attack()) >= ship.defence()) {
			hit = true;
			msg += `hit`;
		} else {
			msg += `miss`;
		}
		if (hit) {
			msg += `: ${dam}`;
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
				msg += `\n  ${ship.name()} terminated`
			} else if (killed > 0) {
				msg += `\n  ${killed} ${ship.name()} destroyed`
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
	size    () {return 2;}
	capacity() {return 25;}
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
	description() {return "Корабль общего назначения";}
	capacity() {return 2;}
	price   () {return 10;}
	energy  () {return 10;}
	
	health  () {return 10;}
	attack  () {return 1;}
	defence () {return 10;}
	damage  () {return {x: 1, d: 2}}
	armor   () {return 2;}
}

class InterceptorShip extends Ship {
	name() {return "Перехватчик";}
	description() {return "Маневреный малый боевой корабль";}
	size    () {return 2;}
	capacity() {return 0;}
	price   () {return 100;}
	energy  () {return 100;}
	
	health  () {return 40;}
	attack  () {return 6;}
	defence () {return 18;}
	damage  () {return {x: 4, d: 10}}
	armor   () {return 3;}
}

class CorvetteShip extends Ship {
	name() {return "Корвет";}
	description() {return "Средний боевой корабль";}
	size    () {return 3;}
	capacity() {return 0;}
	price   () {return 300;}
	energy  () {return 300;}
	
	health  () {return 150;}
	attack  () {return 3;}
	defence () {return 15;}
	damage  () {return {x: 2, d: 20}}
	armor   () {return 4;}
}

class FrigateShip extends Ship {
	name() {return "Фрегат";}
	description() {return "Крупный боевой корабль";}
	size    () {return 5;}
	capacity() {return 0;}
	price   () {return 400;}
	energy  () {return 400;}
	
	health  () {return 250;}
	attack  () {return 4;}
	defence () {return 14;}
	damage  () {return {x: 3, d: 20}}
	armor   () {return 6;}
}

class CruiserShip extends Ship {
	name() {return "Крейсер";}
	description() {return "Боевой крейсер";}
	size    () {return 6;}
	capacity() {return 0;}
	price   () {return 500;}
	energy  () {return 500;}
	
	health  () {return 400;}
	attack  () {return 5;}
	defence () {return 12;}
	damage  () {return {x: 4, d: 20}}
	armor   () {return 8;}
}


function ShipModels() {return [new TradeShip(), new SmallShip(), new InterceptorShip(),
							   new CorvetteShip(), new FrigateShip(), new CruiserShip()]};

const ShipsDescription = function() {
	let msg = "\n<b> ✈️ Модели кораблей ✈️ </b>\n";
	for (const s of ShipModels()) {
		msg += `<b>${s.name()}:</b> ${s.description()}\n`;
		msg += `  слоты: ${s.size()}\n`;
		msg += `  вместимость: ${s.capacity()}📦\n`;
		msg += `  энергия пуска: ${s.energy()}🔋\n`;
		msg += `  ${s.health()}❤️ ${s.attack()}⚔️ ${s.defence()}🛡\n`;
		msg += `  ${s.damage().x}d${s.damage().d}🗡 ${s.armor()}🚅`;
		for (let i = 0; i < Resources.length; i++) msg += getResourceCount(i, s.price());
		msg += "\n";
		msg += `  время строительства: ${time2text(s.price()*Resources.length)}\n`;
	}
	return msg;
}();
