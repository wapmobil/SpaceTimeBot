include("weapons.qs")

// Базовый класс корабля
class Ship {
	constructor(){
		this.count = 0;
		this.hp = this.health();
		this._weapon();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == "wp") this.wp.load(value);
			else this[key] = value;
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
	cur_health() {
		if (this.count == 0) return 0;
		else return this.hp + (this.count-1)*this.health();
	}
	armor   () {return 0;} // damage reduction
	_weapon () {this.wp = new Weapon(0,0);}
	peaceful() {return this.wp.count == 0;}
	damage  () {return this.count*this.wp.damage1()+getRandom(this.count*this.wp.damage2()-this.count*this.wp.damage1()+1);}
	
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
		let cn = `${this.count}✈️${this.hp}❤️ (${this.wp.info()}🗡)`;
		//cn = cn.padEnd(18);
		return `${nm}: ${cn}`;
	}
}


class TradeShip extends Ship {
	name() {return "Грузовик";}
	shortName() {return "Гр";}
	description() {return "Торговый корабль";}
	size    () {return 2;}
	capacity() {return 100;}
	price   () {return 100;}
	energy  () {return 100;}
	
	health  () {return 20;}
}

class SmallShip extends Ship {
	name() {return "Малютка";}
	shortName() {return "Мл";}
	description() {return "Корабль общего назначения";}
	capacity() {return 2;}
	price   () {return 10;}
	energy  () {return 10;}
	
	_weapon () {this.wp = new LaserWeapon(1, 1);}
	health  () {return 4;}
}

class InterceptorShip extends Ship {
	name() {return "Перехватчик";}
	shortName() {return "Пх";}
	description() {return "Малый наступательный корабль";}
	size    () {return 2;}
	capacity() {return 0;}
	price   () {return 100;}
	energy  () {return 100;}
	level   () {return 2;}
	
	_weapon () {this.wp = new LaserWeapon(8, 1);}
	health  () {return 20;}
}

class CorvetteShip extends Ship {
	name() {return "Корвет";}
	shortName() {return "Кв";}
	description() {return "Бронированный корабль";}
	size    () {return 4;}
	capacity() {return 10;}
	price   () {return 250;}
	energy  () {return 200;}
	level   () {return 3;}
	
	_weapon () {this.wp = new LaserWeapon(2, 4);}
	armor   () {return 10;}
	health  () {return 200;}
}

class FrigateShip extends Ship {
	name() {return "Фрегат";}
	shortName() {return "Фр";}
	description() {return "Средний боевой корабль";}
	size    () {return 5;}
	capacity() {return 20;}
	price   () {return 500;}
	energy  () {return 400;}
	level   () {return 3;}
	
	_weapon () {this.wp = new LaserWeapon(6, 4);}
	armor   () {return 5;}
	health  () {return 100;}
}

class CruiserShip extends Ship {
	name() {return "Крейсер";}
	shortName() {return "Кр";}
	description() {return "Крупный боевой корабль";}
	size    () {return 6;}
	capacity() {return 0;}
	price   () {return 1000;}
	energy  () {return 500;}
	level   () {return 4;}
	
	_weapon () {this.wp = new LaserWeapon(2, 16);}
	armor   () {return 20;}
	health  () {return 500;}
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
		msg += `  ${s.health()}❤️\n`;
		msg += `  вооружение: ${s.wp.description()}\n`;
		msg += `  урон: ${s.wp.info()}🗡\n`;
		msg += `  броня: ${s.armor()}🛡\n`;
		//msg += `  ${s.health()}❤️ ${s.attack()}⚔️ ${s.defence()}🏃\n`;
		//msg += `  ${s.damage().x}d${s.damage().d}🗡 ${s.armor()}🛡\n`;
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
	
	armor   () {return 1;}
	health  () {return 2;}
	_weapon () {this.wp = new LaserWeapon(1, 1);}
}

class EnemyMiddle extends Ship {
	name() {return "EnemyMiddle";}
	shortName() {return "EM";}
	description() {return "";}
	size    () {return 3;}
	capacity() {return 0;}
	price   () {return 2;}
	energy  () {return 0;}
	is_enemy() {return true;}
	
	armor   () {return 4;}
	health  () {return 40;}
	_weapon () {this.wp = new LaserWeapon(2, 2);}
}

class EnemySenior extends Ship {
	name() {return "EnemySenior";}
	shortName() {return "ES";}
	description() {return "";}
	size    () {return 10;}
	capacity() {return 0;}
	price   () {return 100;}
	energy  () {return 0;}
	is_enemy() {return true;}
	
	armor   () {return 10;}
	health  () {return 400;}
	_weapon () {this.wp = new LaserWeapon(2, 4);}
}

function enemyShips() {return [new EnemyJunior(), new EnemyMiddle(), new EnemySenior()]}
