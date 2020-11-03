include("stock.qs")
include("navy.qs")
include("spaceyard.qs")
include("solar.qs")
include("factory.qs")
include("research.qs")
include("storage.qs")
include("facility.qs")
include("farm.qs")
include("energystorage.qs")

// Планета
class Planet {
	constructor(id){
		this.money = 0;
		this.food = 200;
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = isProduction ? 0 : 999;
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
		this.factory.type = getRandom(Resources.length);
		this.factory.prod_cnt = 0;
		this.accum.energy = 0;
		this.accum.upgrade = 1;
		this.facility.taxes = 1;
		this.trading = false;
		this.storage.mult = 1;
		this.ships = new Navy(id);
		this.expeditions = new Array();
		this.ship_speed = 1;
		this.spaceyard.ship_id = -1;
		this.spaceyard.ship_bt = 0;
		this.stock = new Stock(id);
		if (!isProduction) {
			this.money = 9999999;
			this.food = 9999999;
			this.farm.level = 30;
			this.solar.level = 30;
			this.storage.level = 60;
			this.facility.level = 3;
			this.build_speed = 100;
			this.sience_speed = 200;
			this.ship_speed = 20;
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
				if (key == 'expeditions') {
					if (Array.isArray(value)) {
						for (const v of value) {
							let si = new Navy(this.chat_id);
							si.load(v);
							this.expeditions.push(si);
						}
					}
				} else if (this[key].load) this[key].load(value);
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
		if (all) {
			if (this.accum.level > 0)
				msg += `Аккум.: ${Math.floor(this.accum.energy)}/${this.accum.capacity(this.accum.level)}🔋 (+${Math.round(this.energy())}🔋 за 100⏳)\n`
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
	maxShips() {
		return 10*this.facility.level + this.spaceyard.level;
	}
	totalShips() {
		let cnt = this.ships.countAll();
		for (const value of this.expeditions) cnt += value.countAll();
		if (this.spaceyard.ship_id >= 0) cnt += 1;
		return cnt;
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
			}
		}
		for(let i=0; i<this.expeditions.length; i++) {
			this.expeditions[i].arrived -= this.ship_speed;
			if (this.expeditions[i].arrived <= 0) {
				this.returnExpedition(i);
			}
		}
		let new_ship = this.spaceyard.buildShip();
		if (new_ship >= 0) {
			this.ships.m[new_ship].count += 1;
			this.spaceyard.ship_id = -1;
			Telegram.send(this.chat_id, `Корабль ${this.ships.m[new_ship].name()} собран`);
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
		for (const value of bds) {
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
	isSienceActive() {
		return this.sience.some(r => r.time > 0);
	}
	sienceStart(s) {
		if (this.isSienceActive()) {
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
		if (this.trading && this.ships.count(0) == 0 && this.expeditions.length == 0) {
			this.ships.m[0].count = 1;
		}
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
		Telegram.send(this.chat_id, "Поздравляем, теперь ты можешь построить 🏭Завод по производству ресурса - "
			 + Resources[this.factory.type].icon + Resources[this.factory.type].desc);
		this.factory.locked = false;
	}
	enable_accum() {
		Telegram.send(this.chat_id, "Поздравляем, теперь ты можешь построить 🔋Аккумуляторы");
		this.accum.locked = false;
	}
	eco_power() {
		Telegram.send(this.chat_id, "Потребление ⚡энергиии снизилось на 10%");
		this.energy_eco *= 0.9;
	}
	fastbuild() {
		this.build_speed += 1;
		Telegram.send(this.chat_id, `Скорость 🛠строительства увеличилась и составляет ${this.build_speed}x`);
	}
	enable_ships() {
		Telegram.send(this.chat_id, "Поздравляем, теперь ты можешь построить 🏗Верфь, которая нужна для сборки новых кораблей");
		this.spaceyard.locked = false;
	}
	upgrade_accum() {
		Telegram.send(this.chat_id, "Ёмкость 🔋Аккумуляторов увеличилась");
		this.accum.upgrade *= 1.2;
	}
	enable_trading() {
		this.trading = true;
		this.ships.add(0, 1);
		Telegram.send(this.chat_id, "Поздравляем, теперь тебе доступна 💸Торговля на 📈Бирже.\n" +
		"А ещё учёные смогли починить твой корабль, и теперь у тебя есть 1 Грузовик");
	}
	more_taxes() {
		this.facility.taxes *= 2;
	}
	upgrade_capacity() {
		Telegram.send(this.chat_id, "Поздравляем, макстимальное количество хранимой 🍍еды - удвоилось");
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
				Telegram.send(this.chat_id, "Не хватает 💰");
				return false;
			}
			if (this.freeStorage() < count) {
				Telegram.send(this.chat_id, `Не достаточно места в 📦хранилище для ${Resources_icons[res]}`);
				return false;
			}
		}
		if (this.accum.energy < 50 && isProduction) {
			Telegram.send(this.chat_id, "Не хватает 🔋 для публикации заказа, дождитесь зарядки аккумуляторов");
			return false;
		}
		if (isProduction) this.accum.energy -= 50;
		this.stock.add(sell, res, count, price);
		Statistica.stock_items += 1;
		return true;
	}
	removeStockTask(ind) {
		if (this.accum.energy < 50) {
			Telegram.send(this.chat_id, "Не хватает 🔋 для публикации заказа, дождитесь зарядки аккумуляторов");
			return false;
		}
		if (this.stock.remove(ind)) {
			this.accum.energy -= 50;
			return true;
		} else return false;
	}
	sellResources(r, cnt) {
		if (!this.trading) {Telegram.send(this.chat_id, "Недоступно, требуется исследование"); return;}
		if (this.resourceCount(r) < cnt) {Telegram.send(this.chat_id, `Недостаточно ${Resources[r].desc}`); return;}
		this[Resources[r].name] -= cnt;
		this.money += cnt;
	}
	shipsCountInfo() {
		return `Всего кораблей: ${this.totalShips()}/${this.maxShips()}\n`;
	}
	navyInfo() {
		if (this.trading) {
			let msg = this.shipsCountInfo() + "\n";
			//msg += this.shipsCountInfo();
			if (this.spaceyard.ship_id >= 0) {
				msg += `Идёт сборка ${this.ships.m[this.spaceyard.ship_id].name()}, осталось ${time2text(this.spaceyard.ship_bt)}\n`;
			}
			msg += this.ships.info("✈️Флот на базе");
			for (const value of this.expeditions) {
				if (value.dst == this.chat_id)
					msg += value.info(`✈️Флот возвращается на базу\n  до прибытия ${time2text(value.arrived)}`); 
				else
					msg += value.info(`✈️Флот летит на планету ${value.dst}\n  до прибытия ${time2text(value.arrived)}`);
			}
			Telegram.send(this.chat_id, msg);
		} else {
			Telegram.send(this.chat_id, "Необходимо построить 🏗Верфь");
		}
	}
	expeditionInfo() {
		const nv = tmpNavy.get(this.chat_id);
		let msg = "Начать экспедицию\n";
		msg += GlobalMarket.get(nv.aim).info() + "\n";
		msg += this.ships.info("✈️Флот на базе");
		msg += "\n";
		msg += nv.info("✈️Флот для отправки");
		return msg;
	}
	initExpedition(item) {
		if (!this.trading) {
			Telegram.send(this.chat_id, "Необходимо исследовать торговлю");
			return false;
		}
		if (this.ships.totalResources() > 0) {
			Telegram.send(this.chat_id, "Необходимо 📤Разгрузить ✈️Флот");
			return false;
		}
		if (this.ships.countAll() == 0) {
			Telegram.send(this.chat_id, "На базе отсутствуют свободные корабли");
			return false;
		}
		const m_err = "Ошибка, заявка уже не существует";
		if(!item) {
			Telegram.send(this.chat_id, m_err);
			return false;
		}
		if (item.client != 0) {
			Telegram.send(this.chat_id, m_err);
			return false;
		}
		if (item.owner == this.chat_id) {
			Telegram.send(this.chat_id, "Невозможно - это своя заявка");
			return false;
		}
		let nv = new Navy(this.chat_id);
		nv.aim = item.id;
		nv.dst = item.owner;
		nv.arrived = 500;
		if (item.is_sell) {
			nv.money = item.price * item.count;
		} else {
			nv[Resources[item.res].name] = item.count;
		}
		tmpNavy.set(this.chat_id, nv);
		Telegram.sendButtons(this.chat_id, this.expeditionInfo(), this.ships.buttons().concat(["Отправить"]), 2);
	}
	prepareExpedition(msg_id, button) {
		if (button == "Отправить") {
			this.startExpedition(msg_id);
			return;
		}
		const sinds = this.ships.indexes();
		const btns = this.ships.buttons();
		const bid = btns.indexOf(button);
		if (bid == -1)  {
			print(btns, button, bid);
			Telegram.send(this.chat_id, "Ошибка");
			return;
		}
		const id = sinds[bid];
		if (id[1] > 0) {
			if (tmpNavy.get(this.chat_id).count(id[0]) < this.ships.count(id[0])) {
				tmpNavy.get(this.chat_id).add(id[0], id[1]);
			} else return;
		} else {
			if (tmpNavy.get(this.chat_id).count(id[0]) > 0) {
				tmpNavy.get(this.chat_id).remove(id[0], -id[1]);
			} else return;
		}
		Telegram.edit(this.chat_id, msg_id, this.expeditionInfo(), btns.concat(["Отправить"]), 2);
	}
	startExpedition(msg_id) {
		let nv = tmpNavy.get(this.chat_id);
		if (!nv) return;
		nv.money = 0;
		for(let i=0; i<Resources.length; i++) nv[Resources[i].name] = 0;
		const si = GlobalMarket.get(nv.aim);
		if (!si) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, заявка уже не существует");
			return;
		}
		const r = si.res;
		if (si.count > nv.freeStorage()) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, ресурсы не влезают - нужно больше ✈кораблей");
			return;
		}
		if (this.accum.energy < nv.energy()) {
			Telegram.edit(this.chat_id, msg_id, "Не хватает 🔋 для отправки, дождитесь зарядки аккумуляторов");
			return;
		}
		if (si.is_sell) {
			if (this.money < si.price * si.count) {
				Telegram.edit(this.chat_id, msg_id, "Не хватает 💰");
				return;
			}
		} else {
			if (this.resourceCount(r) < si.count) {
				Telegram.edit(this.chat_id, msg_id, `Не хватает ${Resources_icons[r]}`);
				return;
			}
		}
		if (GlobalMarket.start(nv.aim, this.chat_id)) {
			if (si.owner < 100) {
				if (!NPCstock[si.owner-1].start(nv.aim, this.chat_id)) {
					Telegram.edit(this.chat_id, msg_id, "Ошибка");
					Telegram.send(this.chat_id, "Внутренняя ошибка при сделке с NPC, свяжитесь с разработчиком");
					GlobalMarket.items.get(id).client = 0;
					return;
				}
			} else {
				if (!Planets.get(si.owner).stock.start(nv.aim, this.chat_id)) {
					Telegram.edit(this.chat_id, msg_id, "Ошибка");
					Telegram.send(this.chat_id, "Внутренняя ошибка при сделке с Игроком, свяжитесь с разработчиком");
					GlobalMarket.items.get(id).client = 0;
					return;
				} else {
					Telegram.send(si.owner, `Ваша заявка была принята, флот другого Игрока вылетел:\n  ${si.info()}`);
				}
			}
			if (si.is_sell) {
				this.money -= si.price * si.count;
				nv.money += si.price * si.count;
			} else {
				this[Resources[r].name] -= si.count;
				nv[Resources[r].name] += si.count;
			}
			this.accum.energy -= nv.energy();
			this.ships.split(nv);
			this.expeditions.push(nv);
			tmpNavy.delete(this.chat_id);
			Statistica.expeditions++;
			Telegram.edit(this.chat_id, msg_id, "Экспедиция успешно отправлена!");
		} else {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, заявка уже не существует");
		}
	}
	returnExpedition(i) {
		let e = this.expeditions[i];
		if (e.dst == this.chat_id) {
			this.ships.join(e);
			this.expeditions.splice(i, 1);
			Telegram.send(this.chat_id, "✈️Флот вернулся на базу!");
			this.navyUnload();
		} else {
			const si = GlobalMarket.get(e.aim);
			if (si.owner < 100) {
				NPCstock[si.owner-1].delete(si.id);
				if (si.is_sell) {
					e.money -= si.price * si.count;
					e[Resources[si.res].name] += si.count;
				} else {
					e[Resources[si.res].name] -= si.count;
					e.money += si.price * si.count;
				}
			} else {
				Planets.get(si.owner).stock.delete(si.id);
				if (si.is_sell) {
					e.money -= si.price * si.count;
					Planets.get(si.owner).money += si.price * si.count;
					Planets.get(si.owner)[Resources[si.res].name] -= si.count;
					e[Resources[si.res].name] += si.count;
				} else {
					e[Resources[si.res].name] -= si.count;
					Planets.get(si.owner)[Resources[si.res].name] += si.count;
					Planets.get(si.owner).money -= si.price * si.count;
					e.money += si.price * si.count;
				}
				Telegram.send(si.owner, `Ваша заявка выполнена успешно:\n  ${si.info()}`);
			}
			e.dst = this.chat_id;
			e.arrived = 500;
			this.expeditions[i] = e;
			Telegram.send(this.chat_id, "✈️Флот достиг заданной планеты, обмен ресурсов выполнен.");
		}
	}
	navyUnload() {
		if (this.trading) {
			if (this.ships.money == 0 && this.ships.totalResources() == 0) {
				Telegram.send(this.chat_id, "В трюме пусто");
				return;
			}
			let mn = this.ships.money;
			this.money += mn;
			let msg = "";
			if (mn > 0) msg += `+${money2text(mn)}`;
			this.ships.money = 0;
			if (this.freeStorage() < this.ships.totalResources()) {
				Telegram.send(this.chat_id, "📤Разгрузка невозможна - не хватает места в 📦хранилище");
				return;
			}
			for(let i=0; i<Resources.length; i++) {
				if (this.ships[Resources[i].name] > 0) msg += " +" + getResourceCount(i, this.ships[Resources[i].name]);
				this[Resources[i].name] += this.ships[Resources[i].name];
				this.ships[Resources[i].name] = 0;
			}
			Telegram.send(this.chat_id, "📤Разгрузка успешно выполнена: " + msg);
		} else {
			Telegram.send(this.chat_id, "Необходимо исследовать торговлю");
		}
	}
	createShip(si) {
		if (this.spaceyard.level > 0) {
			const ns = ShipModels()[si];
			for(let i=0; i<Resources.length; i++) {
				if (this.resourceCount(i) < ns.price()) {
					Telegram.send(this.chat_id, `Не достаточно ${Resources_desc[i]} для постройки`);
					return;
				}
			}
			if (this.spaceyard.ship_id >= 0) {
				Telegram.send(this.chat_id, `🏗Верфь уже занята сборкой ${this.ships.m[this.spaceyard.ship_id].name()}`);
				return;
			}
			if (this.totalShips() < this.maxShips()) {
				this.spaceyard.ship_id = si;
				this.spaceyard.ship_bt = ns.price()*Resources.length;
				for(let i=0; i<Resources.length; i++) this[Resources[i].name] -= ns.price();
				Telegram.send(this.chat_id, `Сборка ${this.ships.m[si].name()} началась`);
			} else {
				Telegram.send(this.chat_id, "Достигнуто максимальное количество кораблей");
			}
		} else {
			Telegram.send(this.chat_id, "Требуется построить 🏗Верфь");
		}
	}

}
