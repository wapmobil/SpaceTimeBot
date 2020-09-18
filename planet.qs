// Планета
class Planet {
	constructor(id){
		this.money = 200;
		this.plant = new Plant(id);
		this.storage = new Storage(id);
		this.facility = new Facility(id);
		this.chat_id = id;
		this.build_speed = 1;
	}
	getBuildings() {
		return [this.plant, this.storage, this.facility];
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object') {
				this[key].load(value);
			} else {
				this[key] = value;
			}
		}
	}
	info() { // отобразить текущее состояние планеты
		let msg = `Деньги:  ${this.money}💰\n`;
		let bds = this.getBuildings();
		for (var value of bds) {
			msg += value.info();
		}
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.plant.step(this.build_speed);
		this.storage.step(this.build_speed);
		this.facility.step(this.build_speed);
		if (this.money < this.storage.capacity(this.storage.level)) {
			this.money += this.plant.level;
			if (this.money > this.storage.capacity(this.storage.level)) {
				this.money = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище заполнено");
			}
		}
	}
	researchMining() {
		Telegram.send(this.chat_id, "В разработке...");
	}
	researchBuilding() {
		Telegram.send(this.chat_id, "В разработке...");
	}
	isBuilding() {
		let bds = this.getBuildings();
		for (var value of bds) {
			if (value.isBuilding()) return true;
		}
		return false;
	}
}
