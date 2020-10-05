// Базовый класс корабля
class Ship {
	constructor(id){
		this.count = 0;
	}
	name() {return "";}
	description() {return "";}
	capacity() {return 0;}
	energy() {return 0;}
	health() {return 1;}
	armor() {return 0;}
	attack() {return 0;}
	damage() {return {b:1, d:8}}
}
