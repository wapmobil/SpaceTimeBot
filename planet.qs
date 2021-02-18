include("stock.qs")
include("npcplanets.qs")
include("spaceyard.qs")
include("solar.qs")
include("factory.qs")
include("research.qs")
include("storage.qs")
include("facility.qs")
include("farm.qs")
include("energystorage.qs")
include("comcenter.qs")

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
		this.comcenter = new Comcenter(id);
		this.comcenter.locked = true;
		this.chat_id = id;
		this.build_speed = 1;
		this.sience_speed = 1;
		this.energy_eco = 1;
		this.sience = new Array();
		this.sience2 = new Array();
		this.factory.type = getRandom(Resources_base);
		this.factory.prod_cnt = 0;
		this.accum.energy = 0;
		this.accum.upgrade = 1;
		this.facility.taxes = 1;
		this.trading = false;
		this.storage.mult = 1;
		this.ships = new Navy(id);
		this.expeditions = new Array();
		this.ship_speed = 1;
		this.spaceyard.ship_que = [];
		this.spaceyard.ship_bt = 0;
		this.stock = new Stock(id);
		this.enabled_exp = 0;
		this.max_exp = 1;
		this.max_stocks = 3;
		this.miningTimeout = 0;
		if (!isProduction) {
			this.money = 9999999;
			this.food = 9999999;
			this.farm.level = 30;
			this.solar.level = 100;
			this.storage.level = 100;
			this.facility.level = 5;
			this.build_speed = 500;
			this.sience_speed = 200;
			this.ship_speed = 20;
			this.ships.m[0].count = 10;
			this.ships.m[1].count = 10;
			this.max_exp = 10;
		}
	}
	
	getBuildings() {
		let a = [this.facility, this.farm, this.storage, this.solar];
		if (!this.accum.locked) a.push(this.accum);
		if (!this.factory.locked) a.push(this.factory);
		if (!this.spaceyard.locked) a.push(this.spaceyard);
		if (!this.comcenter.locked) a.push(this.comcenter);
		return a;
	}
	
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object' && this[key] && key != 'sience' && key != 'sience2') {
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
				if (this.resourceCount(i) > 0 || this.stock.reserved(i) > 0) {
					msg += getResourceInfo(i, this.resourceCount(i));
					const b = this.stock.reserved(i);
					if(b > 0) msg += `(📈 ${getResourceCount(i, b)})`;
					msg += '\n';
				}
			}
			const bs = this.stock.reservedStorage();
			msg += `Склад: ${this.totalResources()+bs}/${this.storage.capacityProd(this.storage.level)}📦`;
			if (bs > 0) msg += ` (📈 ${bs})`;
		}
		return msg + "\n";
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
	
	maxShipsSize() {
		return 10*(this.facility.level + this.spaceyard.level);
	}
	
	totalShipsSize() {
		let cnt = this.ships.size();
		for (const value of this.expeditions) cnt += value.size();
		for (const si of this.spaceyard.ship_que) cnt += this.ships.m[si].size();
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
	
	miningBoost() {
		return Math.pow(2, this.facility.level);
	}
	
	totalBuildings() {
		var lvl = 0;
		const bds = this.getBuildings();
		for (var value of bds) lvl += value.level;
		return lvl;
	}
	
	info(ret) { // отобразить текущее состояние планеты
		let msg = `<b>Твоя планета ${this.chat_id}</b>\n`;
		msg += this.infoResources();
		const bds = this.getBuildings();
		for (var value of bds) {
			msg += value.info();
		}
		if (ret) return msg;
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
		this.comcenter.step(this.build_speed);
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
				Telegram.send(this.chat_id, "Исследование завершено!");
			}
		}
		const cs2 = this.sience2.findIndex(r => r.time > 0);
		if (cs2 >= 0) {
			this.sience2[cs2].time -= this.sience_speed;
			if (this.sience2[cs2].time <= 0) {
				this.sience2[cs2].time = 0;
				const csid = this.sience2[cs2].id;
				this[InoTechTree.find(r => r.id == csid).func]();
				Telegram.send(this.chat_id, "Улучшение готово!");
			}
		}
		for(let i=0; i<this.expeditions.length; i++) {
			//print(i, this.expeditions[i].type, this.expeditions[i].battle_id, this.expeditions[i].countAll(), this.expeditions[i].arrived);
			if (this.expeditions[i].countAll() == 0) {
				this.expeditions.splice(i, 1);
				if (i == this.expeditions.length) break;
			}
			if (this.expeditions[i].battle_id != 0) continue;
			if (this.expeditions[i].type != 3) {
				this.expeditions[i].arrived -= this.ship_speed;
				if (this.expeditions[i].arrived <= 0) {
					this.returnExpedition(i);
				}
			}
		}
		let new_ship = this.spaceyard.buildShip();
		if (new_ship >= 0) {
			this.ships.m[new_ship].count += 1;
			Telegram.send(this.chat_id, `Корабль ${this.ships.m[new_ship].name()} собран`);
		}
		if (this.miningTimeout > 0) this.miningTimeout--;
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
		return SieceTree.reduce(printSienceTree, "Исследования:\n", ResearchBase.Traversal.DepthFirst, this.sience);
	}
	sienceInfo2() {
		return InoTechTree.reduce(printSienceTree, "Улучшения:\n", ResearchBase.Traversal.DepthFirst, this.sience2);
	}
	
	sienceList() {
		return SieceTree.reduce(getSienceButtons, [], ResearchBase.Traversal.Actual, this.sience);
	}
	sienceList2() {
		return InoTechTree.reduce(getSienceButtons2, [], ResearchBase.Traversal.Actual, this.sience2);
	}
	
	sienceListExt() {
		return SieceTree.reduce(printSienceDetail, "", ResearchBase.Traversal.Actual, this.sience);
	}
	sienceListExt2() {
		return InoTechTree.reduce(printSienceDetail, "", ResearchBase.Traversal.Actual, this.sience2);
	}
	
	isSienceActive() {
		return this.sience.some(r => r.time > 0);
	}
	isSienceActive2() {
		return this.sience2.some(r => r.time > 0);
	}
	
	sienceStart(id, msg_id) {
		if (this.isSienceActive()) {
			Telegram.edit(this.chat_id, msg_id, "Сейчас нельзя, исследование уже идёт");
			return;
		}
		const bs = SieceTree.find(r => r.id == id);
		if (!bs) {
			Telegram.edit(this.chat_id, msg_id, "Исследование недоступно");
		}
		if (this.food < bs.cost) {
			Telegram.edit(this.chat_id, msg_id, "Недостаточно 🍍еды");
			return;
		}
		if (!this.hasMoney(bs.money)) {
			Telegram.edit(this.chat_id, msg_id, "Недостаточно 💰денег");
			return;
		}
		let ns = new Object();
		ns.id = bs.id;
		ns.time = bs.time;
		//print(bs.name, ns.id);
		this.food -= bs.cost;
		this.money -= bs.money;
		this.sience.push(ns);
		Telegram.edit(this.chat_id, msg_id, "Исследование началось");
	}

	sienceStart2(id, msg_id) {
		if (this.isSienceActive2()) {
			Telegram.edit(this.chat_id, msg_id, "Сейчас нельзя, улучшение уже идёт");
			return;
		}
		const bs = InoTechTree.find(r => r.id == id);
		//print(InoTechTree.reduce(getSienceRank, [], ResearchBase.Traversal.Actual, this.sience2));
		const rank = InoTechTree.reduce(getSienceRank, [], ResearchBase.Traversal.Actual, this.sience2).find(r => r.id == id).rank;
		if (rank > this.comcenter.level) {
			Telegram.edit(this.chat_id, msg_id, `Требуется 🏪Командный центр ${rank} уровня`);
			return;
		}
		if (!bs) {
			Telegram.edit(this.chat_id, msg_id, "Улучшение недоступно");
			return;
		}
		if (this.ino_tech < bs.cost) {
			Telegram.edit(this.chat_id, msg_id, "Недостаточно " + Resources_desc[3]);
			return;
		}
		let ns = new Object();
		ns.id = bs.id;
		ns.time = bs.time;
		this.ino_tech -= bs.cost;
		this.sience2.push(ns);
		Telegram.edit(this.chat_id, msg_id, "Улучшение началось");
	}
	
	fixSience() {
		//if (this.trading && this.ships.count(0) == 0 && this.expeditions.length == 0) {
		//	this.ships.m[0].count = 1;
		//}
		//if (this.facility.level >= this.farm.level && this.facility.level > 0) {
		//	this.food = Math.max(this.food, 100000, this.storage.capacity(this.storage.level));
		//	this.farm.level = this.facility.level+1;
		//}
		//if (!this.hasMoney(0)) this.money += 2000;
		//this.energy_eco = 1;
		if (!isProduction) {
			this.build_speed = 500;
			this.max_exp = 10;
			for(let i=0; i<Resources_base; i++)
				this[Resources[i].name] = 3000;
			this.ino_tech = 100;
		}
		//this.food = this.money;
		//this.spaceyard.ship_id = undefined;
		//this.accum.locked = true;
		//this.money = 0;
		//this.factory.type = getRandom(3);
		//this.storage.mult = 1;
		//this.sience.forEach(r => {
		//	if (r.id == 21) 
		//		this.enable_сommcenter();
		//});
		for (let value of this.expeditions) {
			value.battle_id = 0;
			if (value.type == 3) {
				let npc = GlobalNPCPlanets.getPlanet(value.dst);
				//print(npc);
				if (!npc) {
					print("del NPCPlanet" + value.id);
					value.type = 2;
					value.dst = 0;
				}
			}
		}
	}
	
	upgrage_inotech() {
		Telegram.send(this.chat_id, "Теперь тебе доступны новые улучшения");
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
	
	enable_expeditions() {
		Telegram.send(this.chat_id, "Поздравляем, теперь тебе доступна отправка экспедиций");
		this.enabled_exp = 1;
	}
	
	increase_market() {
		this.max_stocks += 2;
	}
	
	enable_сommcenter() {
		Telegram.send(this.chat_id, "Поздравляем, теперь ты можешь построить 🏪Командный центр");
		this.comcenter.locked = false;
	}
	
	upgrage_max_expeditions() {
		this.max_exp += 1;
		Telegram.send(this.chat_id, "Количество одновременных экспедиций увеличено на 1 и составляет " + this.max_exp);
	}
		
	addStockTask(sell, res, count, price, priv) {
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
		this.stock.add(sell, res, count, price, this.max_stocks, priv);
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
		if (!this.trading) {Telegram.send(this.chat_id, "Недоступно, требуется исследование - 💸Торговля"); return;}
		if (this.resourceCount(r) < cnt) {Telegram.send(this.chat_id, `Недостаточно ${Resources[r].desc}`); return;}
		this[Resources[r].name] -= cnt;
		this.money += cnt;
	}
	
	shipsCountInfo() {
		return `Слоты кораблей: ${this.totalShipsSize()}/${this.maxShipsSize()}\n`;
	}
	
	navyInfo(exp_only) {
		if (this.spaceyard.level > 0) {
			let msg = this.shipsCountInfo();
			msg += `Аккум.: ${Math.floor(this.accum.energy)}/${this.accum.capacity(this.accum.level)}🔋` + "\n\n";
			if (!exp_only) {
				msg += this.ships.info("✈️Флот на базе", "Для запуска требуется:");
			} else {
				msg += "Экспедиции:\n\n";
			}
			for (const value of this.expeditions) {
				if (value.battle_id != 0) {
					msg += "/battle_" + value.battle_id + " \n";;
					msg += value.info("✈️Флот ⚔️сражается⚔️");
				} else if (value.type == 0 && !exp_only) {
					if (value.dst == this.chat_id)
						msg += value.info("✈️Флот взвращается на базу", `  до прибытия ${time2text(value.arrived)}`);
					else
						msg += value.info(`✈️Флот летит на планету ${value.dst}`, `  до прибытия ${time2text(value.arrived)}`);
				} else if (value.type == 2) {
						msg += value.info("✈️Флот находится в 👣️Экспедиции", `  осталось ${time2text(value.arrived)}`);
				} else if (value.type == 3) {
					msg += "💤Ожидает дальнейших указаний\n";
					msg += "/e_cmd_" + value.dst + " \n";
					msg += value.info("✈️Флот находится в 👣️Экспедиции");
				} else if (value.type == 4 && !exp_only) {
					msg += value.info("✈️Флот летит на помощь экспедиции", `  до прибытия ${time2text(value.arrived)}`);
				}
			}
			msg += "\n";
			Telegram.send(this.chat_id, msg);
		} else {
			Telegram.send(this.chat_id, "Необходимо построить 🏗Верфь");
		}
	}
	
	buildShipInfo() {
		let msg = this.shipsCountInfo();
		msg += this.infoResources() + "\n";
		msg += this.ships.info("На базе") + "\n";
		if (this.spaceyard.ship_que.length > 0) {
			msg += `Идёт сборка ${this.ships.m[this.spaceyard.ship_que[0]].name()}, осталось ${time2text(this.spaceyard.ship_bt)}\n`;
		}
		if (this.spaceyard.ship_que.length > 1) msg += "В очереди:\n";
		for (let i=1; i<this.spaceyard.ship_que.length; i++) {
			msg += this.ships.m[this.spaceyard.ship_que[i]].name() + "\n";
		}
		return msg + "\n";
	}
	
	expeditionInfo() {
		const nv = tmpNavy.get(this.chat_id);
		let msg = "Начать экспедицию\n";
		if (nv.type == 0)
			msg += GlobalMarket.get(nv.aim).info() + "\n";
		if (nv.type == 2)
			msg += `Длительность: ${nv.arrived/(60*60)} ч. \n`;
		if (nv.type == 4) {
			//print(nv.aim);
			let npc = GlobalNPCPlanets.getPlanet(nv.aim);
			if (npc) {
				msg += npc.info();
			} else return "";
		}
		msg += this.ships.info("✈️Флот на базе", "Для запуска требуется:");
		msg += "\n";
		msg += nv.info("✈️Флот для отправки", "Для запуска требуется:");
		return msg;
	}
	
	initTradeExpedition(item) {
		if (!this.trading) {
			Telegram.send(this.chat_id, "Необходимо исследовать 💸Торговля");
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
		nv.type = 0;
		nv.arrived = 500;
		if (item.is_sell) {
			nv.money = item.price * item.count;
		} else {
			nv[Resources[item.res].name] = item.count;
		}
		tmpNavy.set(this.chat_id, nv);
		Telegram.send(this.chat_id, this.expeditionInfo(), this.ships.buttons("processTradeExpedition").concat([{button: "Отправить", script: "processTradeExpedition"}]));
	}
	
	prepareTradeExpedition(msg_id, data) {
		if (data == "Отправить") {
			this.startTradeExpedition(msg_id);
			return;
		}
		const sid = data.split(" ");
		if (sid.length != 2)  {
			print(sid,  data);
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			return;
		}
		if (!GlobalMarket.get(tmpNavy.get(this.chat_id).aim)) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, заявка уже не существует");
			return;
		}
		const id = [parseInt(sid[0]), parseInt(sid[1])];
		//print(data, id, sid);
		const scnt = tmpNavy.get(this.chat_id).count(id[0]);
		if (id[1] > 0) {
			if (scnt < this.ships.count(id[0])) {
				tmpNavy.get(this.chat_id).add(id[0], Math.min(id[1], this.ships.count(id[0])-scnt));
			} else return;
		} else {
			if (scnt > 0) {
				tmpNavy.get(this.chat_id).remove(id[0], -id[1]);
			} else return;
		}
		Telegram.edit(this.chat_id, msg_id, this.expeditionInfo(), this.ships.buttons("processTradeExpedition").concat([{button: "Отправить", script: "processTradeExpedition"}]));
	}
	
	startTradeExpedition(msg_id) {
		let nv = tmpNavy.get(this.chat_id);
		if (!nv) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			print("error");
			return;
		}
		if(nv.type != 0)  {
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			return;
		}
		if (nv.countAll() <= 0) {
			Telegram.edit(this.chat_id, msg_id, "Необходимо выбрать минимум 1 корабль");
			return;
		}
		nv.money = 0;
		for(let i=0; i<Resources.length; i++) nv[Resources[i].name] = 0;
		const si = GlobalMarket.get(nv.aim);
		if (!si) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, заявка уже не существует");
			return;
		}
		if (!this.ships.check(nv)) {
			Telegram.edit(this.chat_id, msg_id, "На базе отсутствуют корабли");
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
			if (!this.hasMoney(si.price * si.count)) {
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
			Statistica.expeditions_trade++;
			Telegram.edit(this.chat_id, msg_id, "Экспедиция успешно отправлена!");
		} else {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, заявка уже не существует");
		}
	}
	
	returnExpedition(i) {
		let e = this.expeditions[i];
		if (e.type == 0) {
			if (e.dst == this.chat_id) {
				if (e.countAll() == 0) {
					this.expeditions.splice(i, 1);
					return;
				}
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
			return;
		}
		if (e.type == 2) {
			e.dst = this.chat_id;
			e.type = 0;
			e.arrived = 500;
			this.expeditions[i] = e;
			Telegram.send(this.chat_id, "👣️Экспедиция закончилась, ✈️Флот возвращается на базу.");
		}
		if (e.type == 4) {
			let npc = GlobalNPCPlanets.getPlanet(e.aim);
			if (npc) {
				let msg = "✈️Флот достиг заданых координат.\n";
				if (npc.ships.countAll() != 0) {
					if (npc.ships.battle_id == 0 && !e.peaceful()) {
						const btid = Battles.addBattle(new Battle(e, npc.ships));
						const b = Battles.b.get(btid);
						Telegram.send(this.chat_id, b.info(this.chat_id), b.buttons(this.chat_id));
						return;
					} else {
						if (e.peaceful()) {
							Telegram.send(this.chat_id, "Невозможно - нет боевых кораблей, ✈️Флот возвращается на базу.");
						} else {
							Telegram.send(this.chat_id, "Невозможно - другое сражение ещё не окончено, ✈️Флот возвращается на базу.");
						}
					}
					//msg += "Невозможно загрузиться - ресурсы охраняются инопланетянами";
				} else {
					msg += this.loadExpedition(e, npc);
				}
				Telegram.send(this.chat_id, msg);
			} else {
				Telegram.send(this.chat_id, "Флот не нашёл ничего и возвращается на базу");
			}
			e.dst = this.chat_id;
			e.type = 0;
			e.arrived = 500;
			this.expeditions[i] = e;
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
			Telegram.send(this.chat_id, "Необходимо исследовать 💸Торговля");
		}
	}
	
	createShip(si, msg_id) {
		if (si < 0) {
			Telegram.edit(this.chat_id, msg_id, "Отменено");
			return;
		}
		const ns = ShipModels()[si];
		if (this.spaceyard.level > 0) {
			for(let i=0; i<Resources_base; i++) {
				if (this.resourceCount(i) < ns.price()) {
					Telegram.edit(this.chat_id, msg_id, `Не достаточно ${Resources_desc[i]} для постройки`);
					return;
				}
			}
			if (this.totalShipsSize() < this.maxShipsSize()) {
				this.spaceyard.queShip(si);
				for(let i=0; i<Resources_base; i++) this[Resources[i].name] -= ns.price();
				if (this.spaceyard.ship_que.length > 1)
					Telegram.edit(this.chat_id, msg_id, `Сборка ${this.ships.m[si].name()} поставлена в очередь`);
				else
					Telegram.edit(this.chat_id, msg_id, `Сборка ${this.ships.m[si].name()} началась`);
			} else {
				Telegram.edit(this.chat_id, msg_id, "Достигнуто максимальное количество кораблей");
			}
		} else {
			Telegram.edit(this.chat_id, msg_id, `Требуется построить 🏗Верфь ${ns.level} уровня`);
		}
	}
	
	reclaimShip(si, msg_id) {
		if (si < 0) {
			Telegram.edit(this.chat_id, msg_id, "Отменено");
			return;
		}
		if (this.spaceyard.level > 0) {
			if (this.ships.m[si].count > 0) {
				const pr = Math.floor(this.ships.m[si].price()/2)
				if (this.freeStorage() < pr*Resources_base) {
					Telegram.edit(this.chat_id, msg_id, "♻️Разборка невозможна - не хватает места в 📦хранилище");
					return;
				}
				this.ships.m[si].count--;
				let ra = [];
				for(let i=0; i<Resources_base; i++) {
					this[Resources[i].name] += pr;
					ra.push(getResourceCount(i, pr));
				}
				Telegram.edit(this.chat_id, msg_id, `${this.ships.m[si].name()} успешно разобран, а склад возвращено ${ra}`);
			} else {
				Telegram.edit(this.chat_id, msg_id, `На базе не осталось ${this.ships.m[si].name()}`);
			}
		} else {
			Telegram.edit(this.chat_id, msg_id, "Требуется построить 🏗Верфь");
		}
	}
	
	initExpeditionRS(tp, sts) {
		if (this.enabled_exp == 0) {
			Telegram.send(this.chat_id, "Необходимо исследовать 👣️Экспедиции");
			return;
		}
		if (this.ships.countAll() == 0) {
			Telegram.send(this.chat_id, "На базе отсутствуют свободные корабли");
			return;
		}
		if (this.ships.totalResources() > 0) {
			Telegram.send(this.chat_id, "Необходимо 📤Разгрузить ✈️Флот");
			return;
		}
		let nv = new Navy(this.chat_id);
		nv.aim = 0;
		nv.dst = 0;
		nv.type = tp;
		let btns = [];
		if (tp == 2) {
			nv.arrived = 60*60;
			btns = [[{button: "-5 час", script: "processExpeditionRS", data: "-1 -300"},
					 {button: "-1 час", script: "processExpeditionRS", data: "-1 -60"},
					 {button: "+1 час", script: "processExpeditionRS", data: "-1 60"},
					 {button: "+5 час", script: "processExpeditionRS", data: "-1 300"}]];
		}
		if (tp == 4) {
			nv.aim = sts.id;
			nv.dst = sts.ow;
			nv.arrived = 500;
		}
		tmpNavy.set(this.chat_id, nv);
		btns.push([{button: "Отправить", script: "processExpeditionRS"}]);
		Telegram.send(this.chat_id, this.expeditionInfo(), this.ships.buttons("processExpeditionRS").concat(btns));
	}
	
	prepareExpeditionRS(msg_id, data) {
		if (data == "Отправить") {
			this.startExpeditionRS(msg_id);
			return;
		}
		if (!tmpNavy.has(this.chat_id)) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			print("error");
			return;
		}
		const sid = data.split(" ");
		if (sid.length != 2)  {
			print(sid,  data);
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			return;
		}
		const id = [parseInt(sid[0]), parseInt(sid[1])];
		//print(data, id, sid);
		if (id[0] < 0) {
			let arv = tmpNavy.get(this.chat_id).arrived;
			arv += id[1]*60;
			if (arv > 10*60*60) arv = 10*60*60;
			if (arv < 60*60) arv = 60*60;
			tmpNavy.get(this.chat_id).arrived = arv;
		} else {
			const scnt = tmpNavy.get(this.chat_id).count(id[0]);
			if (id[1] > 0) {
				if (scnt < this.ships.count(id[0])) {
					tmpNavy.get(this.chat_id).add(id[0], Math.min(id[1], this.ships.count(id[0]) - scnt));
				} else return;
			} else {
				if (scnt > 0) {
					tmpNavy.get(this.chat_id).remove(id[0], -id[1]);
				} else return;
			}
		}
		let btns = [];
		if (tmpNavy.get(this.chat_id).type == 2) {
			btns = [[{button: "-5 час", script: "processExpeditionRS", data: "-1 -300"},
					 {button: "-1 час", script: "processExpeditionRS", data: "-1 -60"},
					 {button: "+1 час", script: "processExpeditionRS", data: "-1 60"},
					 {button: "+5 час", script: "processExpeditionRS", data: "-1 300"}]];
		}
		btns.push([{button: "Отправить", script: "processExpeditionRS"}]);
		Telegram.edit(this.chat_id, msg_id, this.expeditionInfo(), this.ships.buttons("processExpeditionRS").concat(btns));
	}
	
	startExpeditionRS(msg_id) {
		let nv = tmpNavy.get(this.chat_id);
		if (!nv) {
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			print("error");
			return;
		}
		if(nv.type != 2 && nv.type != 4)  {
			Telegram.edit(this.chat_id, msg_id, "Ошибка");
			return;
		}
		if (nv.countAll() <= 0) {
			Telegram.edit(this.chat_id, msg_id, "Необходимо выбрать минимум 1 корабль");
			return;
		}
		nv.money = 0;
		for(let i=0; i<Resources.length; i++) nv[Resources[i].name] = 0;
		if (!this.ships.check(nv)) {
			Telegram.edit(this.chat_id, msg_id, "На базе отсутствуют корабли");
			return;
		}
		if (this.accum.energy < nv.energy()) {
			Telegram.edit(this.chat_id, msg_id, "Не хватает 🔋 для отправки, дождитесь зарядки аккумуляторов");
			return;
		}
		if (this.expeditionsCount() == this.max_exp && nv.type == 2) {
			Telegram.edit(this.chat_id, msg_id, `Вы не можете отправить больше ${this.max_exp} экспедици` + (this.max_exp > 1 ? "й" : "и"));
			return;
		}
		this.accum.energy -= nv.energy();
		this.ships.split(nv);
		this.expeditions.push(nv);
		tmpNavy.delete(this.chat_id);
		let msg = "";
		if (nv.type == 2) msg = "Экспедиция успешно отправлена!";
		else msg = "Флот отправлен";
		Telegram.edit(this.chat_id, msg_id, msg);
	}
	
	returnExpeditionRS() {
		this.navyInfo(true);
		let res = 0;
		let btns = [];
		for (const value of this.expeditions) {
			if (value.type == 2 || value.type == 3) res++;
			if (value.type == 2) btns.push({button: `Вернуть экспедицию ${res}`, data: res, script: "returnExpeditionCommand"});
		}
		btns.push({button:"Отмена", data: -1, script: "returnExpeditionCommand"});
		Telegram.send(this.chat_id, "Вернуть экспедицию:", btns);
	}
	
	forseReturnExpedition(msg_id, e) {
		if (e == -1) {
			Telegram.edit(this.chat_id, msg_id, "Отменено");
			return;
		}
		let res = 0;
		for (const value of this.expeditions) {
			if (value.type == 2 || value.type == 3) res++;
			if (res == e && value.type == 2) {
				value.arrived = 0;
				Telegram.edit(this.chat_id, msg_id, "Принято");
				return;
			}
		}
	}
	
	expeditionsCount() {
		let res = 0;
		for (const value of this.expeditions) {
			if (value.type == 2 || value.type == 3) res++;
		}
		return res;
	}
	
	expeditionStep() {
		for (let value of this.expeditions) {
			if (value.type == 2) {
				value.aim++;
				let chs = Math.round(Math.sqrt(value.aim*Math.sqrt(value.countAll())));
				if (getRandom(1000) < chs) {
					let npc = GlobalNPCPlanets.newPlanet(this.chat_id, value.aim);
					value.type = 3;
					value.dst = npc.id;
					let msg = "<b>Сообщение от экспедиции:</b>\n" + npc.info(true) + "\n";
					msg += "\n ✈️Флот ожидает дальнейших указаний\n";
					msg += value.info("✈️Флот находится в 👣️Экспедиции");
					Telegram.send(this.chat_id, msg, [{button: "Выдать указания", data: value.dst, script: "processExpeditionCommand"}]);
				}
			}
		}
	}
	
	expeditionCommand(npc, msg_id) {
		if (this.enabled_exp == 0) {
			Telegram.send(this.chat_id, "Необходимо исследовать 👣️Экспедиции");
			return;
		}
		for (let value of this.expeditions) {
			if (value.type == 3 && value.dst == npc.id) {
				let msg = npc.info() + "\n" + value.info("✈️Флот находится в 👣️Экспедиции");
				if (msg_id > 0)
					Telegram.edit(this.chat_id, msg_id, msg, this.expeditionButtons(npc));
				else
					Telegram.send(this.chat_id, msg, this.expeditionButtons(npc));
				return;
			}
		}
	}
	
	expeditionButtons(npc) {
		let btns = new Array();
		btns.push([{button: "🐾Покинуть и отправится дальше", script: "processExpeditionCommand2", data: `${npc.id} 1`}]);
		if (npc.totalResources() > 0) btns.push([{button: "📥Загрузиться", script: "processExpeditionCommand2", data: `${npc.id} 2`}]);
		if (npc.totalResources() > 0 || npc.ships.countAll() > 0) btns.push([{button: "💤Ждать подкрепления", script: "processExpeditionCommand2", data: `${npc.id} 3`}]);
		if (npc.ships.countAll() > 0) btns.push([{button: "⚔️Атаковать", script: "processExpeditionCommand2", data: `${npc.id} 4`}]);
		return btns;
	}
	
	expeditionProcessCommand(msg_id, npc_id, cmd_id) {
		let npc = GlobalNPCPlanets.getPlanet(npc_id);
		if (npc) {
			if (cmd_id == 1) {
				for (let value of this.expeditions) {
					if (value.type == 3 && value.dst == npc_id) {
						if (npc.ships.battle_id == 0) {
							value.type = 2;
							GlobalNPCPlanets.forgetPlanet(npc_id);
							value.dst = 0;
							Telegram.edit(this.chat_id, msg_id, "Принято\n✈️Флот продолжает 👣️Экспедицию");
						}  else {
							Telegram.edit(this.chat_id, msg_id, "Невозможно - другое сражение ещё не окончено", [{button: "Выдать указания", data: npc_id, script: "processExpeditionCommand"}]);
						}
						return;
					}
				}
			}
			if (cmd_id == 2) {
				if (npc.ships.countAll() != 0) {
					Telegram.edit(this.chat_id, msg_id, "Невозможно - ресурсы охраняются инопланетянами", [{button: "Выдать указания", data: npc_id, script: "processExpeditionCommand"}]);
				} else {
					for (let value of this.expeditions) {
						if (value.type == 3 && value.dst == npc_id) {
							let msg = "Загрузились\n";
							msg += this.loadExpedition(value, npc);
							Telegram.edit(this.chat_id, msg_id, msg, [{button: "Выдать указания", data: npc_id, script: "processExpeditionCommand"}]);
						}
					}
				}
			}
			if (cmd_id == 3) {
				let msg = "\n Для отправки флота нажмите:\n";
				msg += "https://t.me/"+TgBotName+"?start=eh_" + this.chat_id + "x" + npc.id + "\n";
				msg += "Данной ссылкой можно поделиться с другими игроками, и тогда они смогут забрать ресурсы и сразиться с инопланетянами.\n";
				msg += "Важно: не покидайте это место экспедиционными кораблями, иначе подкрепление не сможет его найти и вернётся обратно.";
				Telegram.send(this.chat_id, npc.info() + "\n" + msg);
			}
			if (cmd_id == 4) {
				for (let value of this.expeditions) {
					if (value.type == 3 && value.dst == npc_id) {
						if (npc.ships.battle_id == 0) {
							const btid = Battles.addBattle(new Battle(value, npc.ships));
							const b = Battles.b.get(btid);
							Telegram.edit(this.chat_id, msg_id, b.info(this.chat_id), b.buttons(this.chat_id));
						} else {
							Telegram.edit(this.chat_id, msg_id, "Невозможно - другое сражение ещё не окончено", [{button: "Выдать указания", data: npc_id, script: "processExpeditionCommand"}]);
						}
					}
				}
			}
		} else {
			Telegram.edit(this.chat_id, msg_id, "Ошибка, координаты неверны или кораб`ли уже покинули это место");
		}
	}
	
	expeditionSupport(owner, npc_id) {
		let npc = GlobalNPCPlanets.getPlanet(npc_id);
		if (npc) {
			if (npc.owner != owner) return;
			this.initExpeditionRS(4, {ow: owner, id: npc_id});
		} else {
			Telegram.send(this.chat_id, "Ошибка, координаты неверны или корабли уже покинули это место");
		}
	}
	
	loadExpedition(e, npc) {
		let msg = "";
		if (e.freeStorage() == 0) {msg += "В трюме закончилось место"; return msg;}
		for (let i=Resources.length-1; i>=Resources_base; i--) {
			if (npc[Resources[i].name] == 0) continue;
			let c = Math.min(e.freeStorage(), npc[Resources[i].name]);
			npc[Resources[i].name] -= c;
			e[Resources[i].name] += c;
			msg += `загрузили ${getResourceCount(i, c)}\n`;
			if (e.freeStorage() == 0) {msg += "В трюме закончилось место"; return msg;}
		}
		for (let i=0; i<Resources_base; i++) {
			if (npc[Resources[i].name] == 0) continue;
			let c = Math.min(e.freeStorage(), npc[Resources[i].name]);
			npc[Resources[i].name] -= c;
			e[Resources[i].name] += c;
			msg += `загрузили ${getResourceCount(i, c)}\n`;
			if (e.freeStorage() == 0) {msg += "В трюме закончилось место"; return msg;}
		}
		return msg;
	}
}
