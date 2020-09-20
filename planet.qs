include("solar.qs")
include("factory.qs")
include("research.qs")
include("storage.qs")
include("facility.qs")
include("plant.qs")
include("energystorage.qs")

// Планета
class Planet {
	constructor(id){
		this.money = 200;
		this.plant = new Plant(id);
		this.storage = new Storage(id);
		this.facility = new Facility(id);
		this.solar = new Solar(id);
		this.accum = new EnergyStorage(id);
		this.accum.locked = true;
		this.factory = new Factory(id);
		this.factory.locked = true;
		this.chat_id = id;
		this.build_speed = 1;
		this.sience_speed = 1;
		this.energy_eco = 1;
		this.sience = createSienceTree();
		this.factory_type = getRandom(2);
	}
	getBuildings() {
		let a = [this.plant, this.storage, this.facility, this.solar];
		if (!this.factory.locked) a.push(this.factory);
		if (!this.accum.locked) a.push(this.accum);
		return a;
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
	infoResources() {
		let msg = `Деньги:  ${this.money}💰\n`;
		msg += `Энергия:  ${this.energy(2)}/${this.energy(1)}⚡`;
		return msg;
	}
	info() { // отобразить текущее состояние планеты
		let msg = this.infoResources() + '\n';
		let bds = this.getBuildings();
		for (var value of bds) {
			msg += value.info();
		}
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.plant.step(this.build_speed);
		this.storage.step(this.build_speed);
		this.solar.step(this.build_speed);
		this.facility.step(this.build_speed);
		this.factory.step(this.build_speed);
		this.accum.step(this.build_speed);
		if (this.money < this.storage.capacity(this.storage.level)) {
			this.money += this.plant.level;
			if (this.money > this.storage.capacity(this.storage.level)) {
				this.money = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище заполнено");
			}
		}
		let rs_done = this.sience.reduce((a,r) => {
			let x = r.step(this.sience_speed);
			if (x) a = x;
			return a;
		});
		if (rs_done) {
			this[rs_done]();
			Telegram.send(this.chat_id, "Исследование завершено");
		}
	}
	isBuilding() {
		let bds = this.getBuildings();
		for (var value of bds) {
			if (value.isBuilding()) return true;
		}
		return false;
	}
	energy(status) {
		let ep = 0;
		let em = 0;
		let bds = this.getBuildings();
		for (var value of bds) {
			let l = value.level;
			if (value.isBuilding() && value.consumption() > 0) l += 1;
			if (value.consumption()*l > 0)
				em += value.consumption()*l;
			if (value.consumption()*l < 0)
				ep -= value.consumption()*l;
		}
		em *= this.energy_eco;
		if (status == 1) return ep;
		if (status == 2) return em;
		return (ep - em);
	}
	sienceInfo() {
		//print(this.sience.name);
		let msg = this.sience.reduce(sienceTree, "Исследования:\n");
		//print("sienceInfo", msg)
		return msg;
	}
	sienceList() {
		return this.sience.reduce(sienceArray, [], Research.Traversal.Actual);
	}
	sienceStart(s) {
		let m = this.money;
		m = this.sience.reduce((a,r) => {
			if (r.name == s) {
				r.start();
				a -= r.cost;
			}
		}, m);
	}
	survey() {
		this.factory.locked = false;
	}
}
