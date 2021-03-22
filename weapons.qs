
class Weapon {
	constructor(c, l) {
		this.count = c;
		this.level = l;
	}
	name() {return "Нет вооружения";}
	damage1() {return 0;}
	damage2() {return 0;}
	info() {
		return `${this.damage1()}-${this.damage2()}`;
	}
	description() {
		if (this.count == 0) return "-";
		return `${this.name()} ур.${this.level} - ${this.count} шт.`;
	}
}

class LaserWeapon extends Weapon {
	name() {return "Лазер";}
	damage1() {return this.count*this.level;}
	damage2() {return this.count*Math.floor(this.level*1.25)+1;}
}