include("navy.qs")
include("spaceyard.qs")
include("solar.qs")
include("factory.qs")
include("research.qs")
include("storage.qs")
include("facility.qs")
include("farm.qs")
include("energystorage.qs")
include("stock.qs")

// Планета
class Planet {
	constructor(id){
		this.money = 0;
		this.food = 200;
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
		this.farm = new Farm(id);
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
		this.sience = new Array();
		this.factory.type = getRandom(3);
		this.factory.prod_cnt = 0;
		this.accum.energy = 0;
		this.accum.upgrade = 1;
		this.facility.taxes = 1;
		this.trading = false;
		this.storage.mult = 1;
		this.ships = new Navy(id);
		this.stock = new Stock(id);
		if (!isProduction) {
			this.money = 9999999;
			this.food = 9999999;
			this.farm.level = 30;
			this.solar.level = 30;
			this.storage.level = 30;
			this.facility.level = 3;
			this.build_speed = 100;
			this.sience_speed = 200;
		}
	}
	getBuildings() {
		let a = [this.facility, this.farm, this.storage, this.solar];
		if (!this.accum.locked) a.push(this.accum);
		if (!this.factory.locked) a.push(this.factory);
		if (!this.spaceyard.locked) a.push(this.spaceyard);
		return a;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object' && this[key] && key != 'sience') {
				if (this[key].load) this[key].load(value);
			} else {
				this[key] = value;
			}
		}
	}
	infoResources(all = true) {
		const sm = this.stock.money();
		let msg = `Деньги: ${money2text(this.money - sm)}`
		if (sm > 0) msg += `(📈 ${money2text(sm)})\n`;
		else msg += "\n";
		msg += `Еда: ${food2text(this.food)} (+${food2text(this.farm.level - this.facility.eat_food(this.facility.level))})\n`;
		msg += `Энергия: ${this.energy(2)}/${this.energy(1)}⚡\n`;
		if (this.accum.level > 0 && all)
			msg += `Аккум.: ${Math.floor(this.accum.energy)}/${this.accum.capacity(this.accum.level)}🔋 (+${Math.round(this.energy())}🔋 за 100⏳)\n`
		if (all) {
			for(let i=0; i<Resources.length; i++) {
				msg += getResourceInfo(i, this.resourceCount(i));
				const b = this.stock.reserved(i);
				if(b > 0) msg += `(📈 ${getResourceCount(i, b)})`;
				msg += '\n';
			}
			msg += `Склад: ${this.totalResources()}/${this.storage.capacityProd(this.storage.level)}📦\n`
		}
		return msg;
	}
	resourceCount(res) {
		return this[Resources[res].name] - this.stock.reserved(res);
	}
	totalResources() {
		let total_res = 0;
		for(let i=0; i<Resources.length; i++) total_res += this[Resources[i].name];
		return total_res;
	}
	freeStorage() {
		let free = this.storage.capacityProd(this.storage.level);
		free -= this.totalResources();
		free -= this.stock.reservedStorage();
		return free;
	}
	hasMoney(m) {
		return ((this.money - this.stock.money()) >= m);
	}
	buyFood(cnt) {
		if (!this.hasMoney(cnt/100)) {Telegram.send(this.chat_id, `Недостаточно 💰`); return;}
		if (this.storage.capacity(this.storage.level) < (this.food+cnt)) {Telegram.send(this.chat_id, "Не хватает места в хранилище📦"); return;}
		this.food += cnt;
		this.money -= cnt/100;
	}
	info() { // отобразить текущее состояние планеты
		let msg = this.infoResources();
		const bds = this.getBuildings();
		for (var value of bds) {
			msg += value.info();
		}
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.farm.step(this.build_speed);
		this.storage.step(this.build_speed);
		this.solar.step(this.build_speed);
		this.facility.step(this.build_speed);
		this.factory.step(this.build_speed);
		this.accum.step(this.build_speed);
		this.spaceyard.step(this.build_speed);
		this.accum.add(this.energy());
		if (this.food < this.storage.capacity(this.storage.level)) {
			this.food += this.farm.level - this.facility.eat_food(this.facility.level);
			if (this.food >= this.storage.capacity(this.storage.level)) {
				this.food = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище 🍍 заполнено");
			}
		}
		if (this.freeStorage() > 0) {
			this[Resources[this.factory.type].name] += this.factory.product();
			if (this.freeStorage() <= 0) {
				Telegram.send(this.chat_id, "Хранилище 📦 заполнено");
			}
		} else {
			this[Resources[this.factory.type].name] += this.freeStorage();
			if (this[Resources[this.factory.type].name] < 0) this[Resources[this.factory.type].name] = 0;
		}
		const cs = this.sience.findIndex(r => r.time > 0);
		if (cs >= 0) {
			this.sience[cs].time -= this.sience_speed;
			if (this.sience[cs].time <= 0) {
				this.sience[cs].time = 0;
				const csid = this.sience[cs].id;
				this[SieceTree.find(r => r.id == csid).func]();
				Telegram.send(this.chat_id, "Исследование завершено");
				//return this.func;
			}
		}
		//let rs_done = this.sience.reduce((a,r) => {
		//	let x = r.step(this.sience_speed);
		//	if (x) a = x;
		//	return a;
		//});
		//if (rs_done) {
		//	this[rs_done]();
		//	Telegram.send(this.chat_id, "Исследование завершено");
		//}
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
		em = em * this.energy_eco;
		if (status == 1) return Math.floor(ep);
		if (status == 2) return Math.floor(em);
		return (ep - em);
	}
	sienceInfo() {
		return SieceTree.reduce(printSienceTree, "Исследования:\n", Research.Traversal.DepthFirst, this.sience);
	}
	sienceList() {
		return SieceTree.reduce(getSienceButtons, [], Research.Traversal.Actual, this.sience);
	}
	sienceListExt() {
		return SieceTree.reduce(printSienceDetail, "", Research.Traversal.Actual, this.sience);
	}
	sienceStart(s) {
		if (this.sience.some(r => r.time > 0)) {
			Telegram.send(this.chat_id, "Сейчас нельзя, исследование уже идёт");
			return;
		}
		const bs = SieceTree.find(r => r.name == s);
		if (this.food <= bs.cost) {
			Telegram.send(this.chat_id, "Недостаточно 🍍еды");
			return;
		}
		if (!this.hasMoney(bs.money)) {
			Telegram.send(this.chat_id, "Недостаточно 💰денег");
			return;
		}
		let ns = new Object();
		ns.id = bs.id;
		ns.time = bs.time;
		//print(bs.name, ns.id);
		this.food -= bs.cost;
		this.money -= bs.money;
		this.sience.push(ns);
		Telegram.send(this.chat_id, "Исследование началось");
	}
	fixSience() {
		//this.energy_eco = 1;
		//this.build_speed = 1;
		//this.food = this.money;
		//this.spaceyard.locked = true;
		//this.accum.locked = true;
		//this.money = 0;
		//this.factory.type = getRandom(3);
		//this.storage.mult = 1;
		//this.sience.forEach(r => {
		//	if (r.id == 1) 
		//		this.eco_power();
		//});
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
		this.energy_eco *= 0.9;
	}
	fastbuild() {
		this.build_speed += 1;
	}
	enable_ships() {
		this.spaceyard.locked = false;
	}
	upgrade_accum() {
		this.accum.upgrade *= 1.2;
	}
	enable_trading() {
		this.trading = true;
		this.ships.m.get("trade").count += 1;
	}
	more_taxes() {
		this.facility.taxes *= 2;
	}
	upgrade_capacity() {
		this.storage.mult *= 2;
	}
	
	addStockTask(sell, res, count, price) {
		if (sell) {
			if (count > this.resourceCount(res)) {
				Telegram.send(this.chat_id, `Не хватает ${Resources_icons[res]}`);
				return false;
			}
		} else {
			if (!this.hasMoney(count*price)) {
				Telegram.send(this.chat_id, `Не хватает 💰`);
				return false;
			}
			if (this.freeStorage() < count) {
				Telegram.send(this.chat_id, `Не достаточно места в 📦хранилище для ${Resources_icons[res]}`);
				return false;
			}
		}
		if (this.accum.energy < 50 && isProduction) {
			Telegram.send(this.chat_id, `Не хватает 🔋 для публикации заказа, дождитесь зарядки аккумуляторов`);
			return false;
		}
		if (isProduction) this.accum.energy -= 50;
		this.stock.add(sell, res, count, price);
		return true;
	}
	removeStockTask(ind) {
		if (this.accum.energy < 50 && isProduction) {
			Telegram.send(this.chat_id, `Не хватает 🔋 для публикации заказа, дождитесь зарядки аккумуляторов`);
			return false;
		}
		if (isProduction) this.accum.energy -= 50;
		return this.stock.remove(ind);
	}
	sellResources(r, cnt) {
		if (!this.trading) {Telegram.send(this.chat_id, "Недоступно, требуется исследование"); return;}
		if (this.resourceCount(r) < cnt) {Telegram.send(this.chat_id, `Недостаточно ${Resources[r].desc}`); return;}
		this[Resources[r].name] -= cnt;
		this.money += cnt;
	}
}
