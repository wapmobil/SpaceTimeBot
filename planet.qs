include("resources.qs")
include("spaceyard.qs")
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
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
		this.plant = new Plant(id);
		this.storage = new Storage(id);
		this.facility = new Facility(id);
		this.solar = new Solar(id);
		this.accum = new EnergyStorage(id);
		this.accum.locked = true;
		this.factory = new Factory(id);
		this.factory.locked = true;
		this.spaceyard = new Spaceyard(id);
		this.spaceyard.locked = true;
		this.chat_id = id;
		this.build_speed = 1;
		this.sience_speed = 1;
		this.energy_eco = 1;
		this.sience = createSienceTree();
		this.factory.type = getRandom(2);
		this.factory.prod_cnt = 0;
		this.accum.energy = 0;
		this.accum.acc_cnt = 0;
		if (!isProduction) {
			this.money = 9999999;
			this.plant.level = 30;
			this.solar.level = 30;
			this.storage.level = 30;
			this.facility.level = 0;
			this.build_speed = 100;
			this.sience_speed = 200;
		}
	}
	getBuildings() {
		let a = [this.facility, this.plant, this.storage, this.solar];
		if (!this.accum.locked) a.push(this.accum);
		if (!this.factory.locked) a.push(this.factory);
		if (!this.spaceyard.locked) a.push(this.spaceyard);
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
	infoResources(all = true) {
		let msg  = `Деньги: ${money2text(this.money)}\n`;
		    msg += `Энергия: ${this.energy(2)}/${this.energy(1)}⚡\n`;
		if (this.accum.level > 0)
			msg += `Аккум.: ${this.accum.energy}/${this.accum.capacity(this.accum.level)}🔋`
		if (all) {
			for(let i=0; i<Resources.length; i++)
				msg += getResourceInfo(i, this[Resources[i].name]) + '\n';
		}
		return msg;
	}
	info() { // отобразить текущее состояние планеты
		let msg = this.infoResources();
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
		this.spaceyard.step(this.build_speed);
		this.accum.add(energy());
		if (this.money < this.storage.capacity(this.storage.level)) {
			this.money += this.plant.level;
			if (this.money > this.storage.capacity(this.storage.level)) {
				this.money = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище заполнено");
			}
		}
		this[Resources[this.factory.type].name] += this.factory.product();
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
		return this.sience.reduce(sienceTree, "Исследования:\n");
	}
	sienceList() {
		return this.sience.reduce(sienceArray, [], Research.Traversal.Actual);
	}
	sienceListExt() {
		return this.sience.reduce(sienceDetail, "", Research.Traversal.Actual);
	}
	sienceStart(s) {
		if (this.sience.some(r => r.active)) {
			Telegram.send(this.chat_id, "Сейчас нельзя, исследование уже идёт");
			return;
		}
		let m = this.money;
		m = this.sience.reduce((a,r) => {
			if (r.name == s) {
				a -= r.cost;
				if (a >= 0) {
					r.start();
				}
			}
			return a;
		}, m);
		if (m >= 0 && m < this.money) {
			this.money = m;
			Telegram.send(this.chat_id, "Исследование началось");
		} else {
			Telegram.send(this.chat_id, "Недостаточно денег");
		}
	}
	checkSience() {
		let b1 = (this.facility.level >= 3);
		this.sience.traverse(r => {
			if (r.name == "🔍🚀Корабли") r.unlock(b1);
		});
	}
	enable_factory() {
		Telegram.send(this.chat_id, "Поздравляем теперь ты можешь построить завод по производству ресурса - "
			 + Resources[this.factory.type].icon + Resources[this.factory.type].desc);
		this.factory.locked = false;
	}
	enable_accum() {
		this.accum.locked = false;
	}
	eco_power() {
		this.energy_eco += 1;
	}
	fastbuild() {
		this.build_speed += 1;
	}
}
