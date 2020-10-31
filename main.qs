include("planet.qs")
include("mininig.qs")

const isProduction = true;
const NPC_count = isProduction ? 2 : 3;

buttonLoad["clicked()"].connect(on_buttonLoad_clicked);
buttonSave["clicked()"].connect(on_buttonSave_clicked);
buttonReset["clicked()"].connect(on_buttonReset_clicked);
pushButton["clicked()"].connect(on_pushButton_clicked);
let save_timer = new QTimer();
save_timer["timeout"].connect(on_buttonSave_clicked);

let tradeNPCtimer = new QTimer();
tradeNPCtimer["timeout"].connect(processTradeNPC);

Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("Поискать 💰", "find_money");
Telegram.addCommand("🔍Исследования", "research");
Telegram.addCommand("💸Торговля/Купить 🍍", "buy_food");
Telegram.addCommand("💸Торговля/Продать ресурсы", "sell_resources");
Telegram.addCommand("💸Торговля/📖Мои ресурсы", "info_resources");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/📗️Мои заявки", "my_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/✳️Создать заявку", "new_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/ℹ️Cправка", "help_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/🖥Смотреть заявки", "show_stock");
Telegram.addCommand("📖Инфоцентр/🌍Планета", "planet_info");
Telegram.addCommand("📖Инфоцентр/💻Дерево исследований", "research_map");
Telegram.addCommand("📖Инфоцентр/🌌Сканер планет", "map_info");
Telegram.addCommand("✈️Флот/📖Инфо", "navy_info");
Telegram.addCommand("✈️Флот/📤Разгрузить", "navy_unload");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей", "ship_price");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей/🏗Cтроить Грузовик", "ship_create0");
Telegram.addCommand("✈️Флот/ℹ️Cправка", "help_ships");
Telegram.addCommand("🛠Строительство/📖Инфо", "planet_info");
Telegram.addCommand("🛠Строительство/🍍Ферма", "info_farm");
Telegram.addCommand("🛠Строительство/🍍Ферма/📖Инфо", "info_farm");
Telegram.addCommand("🛠Строительство/🍍Ферма/🛠Cтроить 🍍Ферму", "build_farm");
Telegram.addCommand("🛠Строительство/⚡️Электростанция", "info_solar");
Telegram.addCommand("🛠Строительство/⚡️Электростанция/📖Инфо", "info_solar");
Telegram.addCommand("🛠Строительство/⚡️Электростанция/🛠Cтроить ⚡️Электростанцию", "build_solar");
Telegram.addCommand("🛠Строительство/🔋Аккумулятор", "info_accum");
Telegram.addCommand("🛠Строительство/🔋Аккумулятор/📖Инфо", "info_accum");
Telegram.addCommand("🛠Строительство/🔋Аккумулятор/🛠Cтроить 🔋Аккумулятор", "build_accum");
Telegram.addCommand("🛠Строительство/📦Хранилище", "info_storage");
Telegram.addCommand("🛠Строительство/📦Хранилище/📖Инфо", "info_storage");
Telegram.addCommand("🛠Строительство/📦Хранилище/🛠Cтроить 📦Хранилище", "build_storage");
Telegram.addCommand("🛠Строительство/🏢База", "info_facility");
Telegram.addCommand("🛠Строительство/🏢База/📖Инфо", "info_facility");
Telegram.addCommand("🛠Строительство/🏢База/🛠Cтроить 🏢Базу", "build_facility");
Telegram.addCommand("🛠Строительство/🏭Завод", "info_factory");
Telegram.addCommand("🛠Строительство/🏭Завод/📖Инфо", "info_factory");
Telegram.addCommand("🛠Строительство/🏭Завод/🛠Cтроить 🏭Завод", "build_factory");
Telegram.addCommand("🛠Строительство/🏗Верфь", "info_spaceyard");
Telegram.addCommand("🛠Строительство/🏗Верфь/📖Инфо", "info_spaceyard");
Telegram.addCommand("🛠Строительство/🏗Верфь/🛠Cтроить 🏗Верфь", "build_spaceyard");

Telegram["receiveCommand"].connect(function(id, cmd, script) {this[script](id);});
Telegram["receiveMessage"].connect(received);
Telegram["receiveSpecialMessage"].connect(receivedSpecial);
Telegram["buttonPressed"].connect(telegramButton);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
//Telegram["messageSent"].connect(telegramSent);

if (isProduction) {
	Telegram.start(SHS.load(77));
	label.hide();
	//buttonReset.enabled = true;
} else {
	buttonReset.enabled = true;
	Telegram.start("733272349:AAH9YTSyy3RmGV4A6OWKz1b3CeKnPI2ROd8");
}


 // Здесь вся БД
let Planets = loadPlanets();
let tmpNavy = new Map();
let MiningGames = new Map();
let StockTasks = new Map();
let GlobalMarket = loadMarket();
let NPCstock = loadNPC();

//Старт
let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);
save_timer.start(timer.interval*10);
tradeNPCtimer.start(timer.interval*1000);
processTradeNPC();

function telegramConnect() {
	Telegram.sendAll("Server <b>started</b>");
	print("telegram bot connected");
}

function telegramDisconnect() {
	print("warning, telegram bot disconnected");
}

function timerDone() {
	for (var value of Planets.values()) {
		value.step();
	}
	on_buttonSave_clicked();
}

function received(chat_id, msg) {
	//print(msg);
	if (msg == "📈Биржа ресурсов") check_trading(chat_id);
	if (msg == "✈️Флот") check_ships(chat_id);
	if (!Planets.has(chat_id)) {
		Planets.set(chat_id, new Planet(chat_id));
		Telegram.send(chat_id,
		 "Поздравляю с успешным приземлением!\n" +
		 "Добро пожаловать на свою собственную планету.\n" +
		 "Тебе крупно повезло и планета пригодна для жизни,\n" +
		 "теперь у тебя есть шанс создать свой флот и развитую экономику.\n" +
		 "Для начала неплохо бы построить ⚡электростанцию а потом и 🍍ферму для добычи 🍍.\n" +
		 "Удачи в игре 😎"
		 );
		Telegram.cancelCommand();
		return;
	}
}

function receivedSpecial(chat_id, msg) {
	if (Planets.has(chat_id)) {
		const s = "/go_";
		if (msg.substring(0,s.length) == s) {
			const id = parseInt(msg.match(/\/go_(\d+)/i)[1]);
			Planets.get(chat_id).initExpedition(GlobalMarket.get(id));
		}
	}
}

function telegramButton(chat_id, msg_id, button, msg) {
	//print(msg);
	let s = "Доступные исследования:";
	if (msg.substring(0,s.length) == s) {
		let research_list = Planets.get(chat_id).sienceList();
		//print(research_list);
		if (research_list.indexOf(button) >= 0) {
			Planets.get(chat_id).sienceStart(button);
		} else {
			Telegram.send(chat_id, "Исследование недоступно");
		}
	}
	const tbi = TradeFoodButtons.indexOf(button);
	if (tbi >= 0) {
		s = "Покупка 🍍еды:\n";
		if (msg.substring(0,s.length) == s) {
			Planets.get(chat_id).buyFood(Math.pow(10,Math.floor(tbi)+2));
			Telegram.edit(chat_id, msg_id, s + Planets.get(chat_id).infoResources(false) + buyFoodFooter, TradeFoodButtons, 2);
		}
	}
	const rbi = TradeButtons.indexOf(button);
	if (rbi >= 0) {
		s = "Продажа ресурсов:\n";
		if (msg.substring(0,s.length) == s) {
			Planets.get(chat_id).sellResources(rbi%3, Math.pow(10,Math.floor(rbi/3)));
			Telegram.edit(chat_id, msg_id, s + Planets.get(chat_id).infoResources(true) + sellResFooter, TradeButtons, Resources.length);
		}
	}
	s = "Подземелье.\n";
	if (msg.substring(0,s.length) == s) processMiningButton(chat_id, msg_id, button);
	s = "Мои заявки:\n";
	if (msg.substring(0,s.length) == s) processStockRemove(chat_id, msg_id, button);
	s = "Создание заявки:";
	if (msg.substring(0,s.length) == s) processStockAdd(chat_id, msg_id, button, msg);
	s = "Начать экспедицию\n";
	if (msg.substring(0,s.length) == s) processExpedition(chat_id, msg_id, button, msg);
}

function telegramSent(chat_id, msg_id, msg) {
	//print("messageSended:" + msg);
}

function planet_info(chat_id) {
	Planets.get(chat_id).info();
}

function info_resources(chat_id) {
	Telegram.send(chat_id, Planets.get(chat_id).infoResources());
}

function infoSomething(chat_id, bl) {
	const p = Planets.get(chat_id);
	if (p[bl].locked) Telegram.send(chat_id, "Требуется исследование");
	else Telegram.send(chat_id, p.infoResources(false) + p[bl].description() + '\n' + p[bl].info());
}
function info_farm(chat_id) {infoSomething(chat_id, "farm");}
function info_storage(chat_id) {infoSomething(chat_id, "storage");}
function info_facility(chat_id) {infoSomething(chat_id, "facility");}
function info_solar(chat_id) {infoSomething(chat_id, "solar");}
function info_factory(chat_id) {infoSomething(chat_id, "factory");}
function info_accum(chat_id) {infoSomething(chat_id, "accum");}
function info_spaceyard(chat_id) {infoSomething(chat_id, "spaceyard");}

function buildSomething(chat_id, bl) {
	//let p = Planets.get(chat_id);
	if (Planets.get(chat_id).isBuilding()) {
		Telegram.send(chat_id, "Строители заняты");
	} else {
		Planets.get(chat_id).food = Planets.get(chat_id)[bl].build(Planets.get(chat_id).food, Planets.get(chat_id).energy());
		//Planets.set(chat_id, p);
	}
}
function build_farm(chat_id)      {buildSomething(chat_id, "farm");}
function build_storage(chat_id)   {buildSomething(chat_id, "storage");}
function build_facility(chat_id)  {buildSomething(chat_id, "facility");}
function build_factory(chat_id)   {buildSomething(chat_id, "factory");}
function build_accum(chat_id)     {buildSomething(chat_id, "accum");}
function build_solar(chat_id)     {buildSomething(chat_id, "solar");}
function build_spaceyard(chat_id) {buildSomething(chat_id, "spaceyard");}

function getRandom(max) {
	return Math.floor(Math.random() * Math.floor(max));
}

function ship_create(chat_id, ship_index) {
	Planets.get(chat_id).createShip(ship_index);
}

function ship_create0(chat_id) {ship_create(chat_id, 0);}

function find_money(chat_id) {
	MiningGames.set(chat_id, new MiningGame(chat_id));
	Telegram.sendButtons(chat_id, "Подземелье.\n" + MiningGames.get(chat_id).show(), miningButtons, 3);
	//let pr = getRandom(3);
	//pr *= p.facility.level*p.facility.level+1;
	//pr += getRandom(3);
	//p.money += pr;
	//if (p.money > p.storage.capacity(p.storage.level)) {
	//	p.money = p.storage.capacity(p.storage.level);
	//	Telegram.send(chat_id, "Хранилище заполнено");
	//}
	//Planets.set(chat_id, p);
	//Telegram.send(chat_id, `Ты заработал ${money2text(pr)}`);
}

function research(chat_id) {
	const p = Planets.get(chat_id);
	if (p.facility.level > 1) {
		Telegram.sendButtons(chat_id, "Доступные исследования:\n" + p.sienceListExt(), p.isSienceActive() ? [] : p.sienceList());
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 2 уровня");
	}
}


function map_info(chat_id) {
	const p = Planets.get(chat_id);
	if (p.facility.level >= 1) {
		let msg = "Список планет:\n";
		for (var [key, value] of Planets) {
			if (key == chat_id) msg += "Ты: ";
			msg += `<b>Планета №${key}:</b> ${value.facility.level}🏢\n`
			if (p.facility.level >= 3) {
				msg += `    ${food2text(value.food)}`;
				for(let i=0; i<Resources.length; i++)
					msg += `|${getResourceCount(i, value[Resources[i].name])}`;
			}
			if (p.facility.level >= 4) {
				msg += '\n    ';
				const bds = value.getBuildings();
				for (var b of bds) {
					if (b.icon() != "🏢") msg += `|${b.level}${b.icon()}`;
				}
			}
			msg += '\n';
		}
		Telegram.send(chat_id, msg);
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 1 уровня");
	}
}

function research_map(chat_id) {
	Telegram.send(chat_id, Planets.get(chat_id).sienceInfo());
}

function on_buttonSave_clicked() {
	let a = [];
	for (const value of Planets.values()) {
		a.push(value);
	}
	SHS.save(isProduction ? 1 : 101, JSON.stringify(a));
	SHS.save(isProduction ? 2 : 102, JSON.stringify(GlobalMarket.save()));
	SHS.save(isProduction ? 3 : 103, JSON.stringify(NPCstock));
	//print(SHS.load(isProduction ? 3 : 103));
}

function loadPlanets() {
	let data = SHS.load(isProduction ? 1 : 101);
	//print(data);
	let m = new Map();
	if (typeof data == 'string') {
		const arr = JSON.parse(data);
		arr.forEach(function(item) {
			let p = new Planet(item.chat_id);
			p.load(item);
			p.fixSience();
	  		m.set(item.chat_id, p);
		});
	}
	return m;
}

function loadMarket() {
	let m = new Marketplace();
	let data = SHS.load(isProduction ? 2 : 102);
	if (typeof data == 'string') {
		m.load(JSON.parse(data));
	}
	return m;
}

function loadNPC() {
	let npc = new Array();
	let data = SHS.load(isProduction ? 3 : 103);
	if (typeof data == 'string') {
		const arr = JSON.parse(data);
		for(let j=0; j<NPC_count; j++) {
			let p = new Stock(j+1);
			if (arr.length > j) p.load(arr[j]);
			npc.push(p);
		}
	} else {
		for(let j=0; j<NPC_count; j++) npc.push(new Stock(j+1));
	}
	return npc;
}

function on_buttonLoad_clicked() {
	Planets = loadPlanets();
	GlobalMarket = loadMarket();
	NPCstock = loadNPC();
}

// очистить всё, полный сброс
function on_buttonReset_clicked() {
	Planets = new Map();
	GlobalMarket = new Marketplace();
	NPCstock = new Array();
	for(let j=0; j<NPC_count; j++) NPCstock.push(new Stock(j+1));
}

function on_pushButton_clicked() {
	Telegram.sendAll(lineEdit.text);
}

function count2text(m) {
	let s = `${m}`, ret = "", dc = Math.floor((s.length - 1) / 3), of = s.length - (dc*3);
	for (let j = 0; j <= dc; ++j) {
		if (j == 0) ret += s.substring(0, of);
		else {
			ret += "\'" + s.substr(of + (3*(j-1)), 3);
		}
	}
	return ret;
}

function food2text(m) {
	return count2text(m) + "🍍";
}

function money2text(m) {
	return count2text(m) + "💰";
}

function time2text(t) {
	function num2g(v, align) {
		let ret = `${v}`
		if (align && ret.length < 2)
			ret = `0${ret}`;
		return ret;
	}
	const h = Math.floor(t / 3600);
	t -= h * 3600;
	const m = Math.floor(t / 60);
	t -= m * 60;
	let ret = "";
	if (h > 0) ret += `${h}:`;
	if (h > 0 || m > 0) ret += num2g(m, h > 0) + ":";
	ret += num2g(t, h > 0 || m > 0);
	return ret + "⏳";
}


function check_trading(chat_id) {
	if (!Planets.get(chat_id).trading) {
		Telegram.send(chat_id, "Требуется исследование");
		Telegram.cancelCommand();
	}
}

function check_ships(chat_id) {
	if (!Planets.get(chat_id).spaceyard.level > 0) {
		Telegram.send(chat_id, "Требуется построить 🏗Верфь");
		Telegram.cancelCommand();
	}
}

function buy_food(chat_id) {
	Telegram.sendButtons(chat_id, "Покупка 🍍еды:\n" + Planets.get(chat_id).infoResources(false) + buyFoodFooter, TradeFoodButtons, 2);
}

function sell_resources(chat_id) {
	const p = Planets.get(chat_id);
	if (p.trading) {
		Telegram.sendButtons(chat_id, "Продажа ресурсов:\n" + p.infoResources(true) + sellResFooter, TradeButtons, Resources.length);
	} else {
		Telegram.send(chat_id, "Требуется исследование");
	}
}

const TradeFoodButtons = function() {
	let arr = [];
	for(let j=2; j<8; j++) {
		arr.push(`${food2text(Math.pow(10, j))}`);
	}
	return arr;
}();

const TradeButtons = function() {
	let arr = [];
	for(let j=0; j<3; j++) {
		for(let i=0; i<Resources.length; i++) {
			arr.push(`${Math.pow(10, j)} ${Resources_icons[i]}`);
		}
	}
	return arr;
}();

const buyFoodFooter = `\nСтоимость покупки: 100🍍 -> 1💰`;
const sellResFooter = `\nСтоимость продажи: 1 ресурс -> 1💰`;

function processMiningButton(chat_id, msg_id, button) {
	const ind = miningButtonsRole[miningButtons.indexOf(button)];
	if (ind >= 0 && ind < 4) {
		switch (MiningGames.get(chat_id).move(ind+1)) {
			case 1:
				Planets.get(chat_id).money += MiningGames.get(chat_id).pl.money;
				let finishMsg = "Вы выбрались из подземелья!\n";
				finishMsg +="Денег собрано:";
				finishMsg +=`${MiningGames.get(chat_id).pl.money}`;
				finishMsg += "💰";
			Telegram.edit(chat_id, msg_id, finishMsg);
			break;
			case 2:
				let deathMsg ="Ты пал в бою\n";
				deathMsg += "Ты потерял ресурсов: ";
				deathMsg += `${MiningGames.get(chat_id).pl.money}`;
				deathMsg += "💰";
				Telegram.edit(chat_id, msg_id, deathMsg);
			break;
			case 0:
			Telegram.edit(chat_id, msg_id, "Подземелье.\n" + MiningGames.get(chat_id).show(), miningButtons, 3);
			break;
		}
	}
	if (ind == 4) {
		MiningGames.get(chat_id).blow();
	}
}

function navy_info(chat_id) {
	Planets.get(chat_id).navyInfo();
}

function my_stock(chat_id) {
	const m = Planets.get(chat_id).stock.info(true);
	Telegram.sendButtons(chat_id, "Мои заявки:\n" + m.msg, m.buttons);
}

function new_stock(chat_id) {
	StockTasks.set(chat_id, {});
	Telegram.sendButtons(chat_id, "Создание заявки:", ["Купить", "Продать"], 2);
}
function processStockRemove(chat_id, msg_id, button) {
	Planets.get(chat_id).removeStockTask(button);
	const m = Planets.get(chat_id).stock.info(true);
	Telegram.edit(chat_id, msg_id, "Мои заявки:\n" + m.msg, m.buttons);
}

function processStockAdd(chat_id, msg_id, button) {
	let t = StockTasks.get(chat_id);
	let nbuttons = Resources_desc;
	let msg = "Создание заявки:\n";
	if (button == "Купить") t.sell = false;
	if (button == "Продать") t.sell = true;
	const rind = Resources_desc.indexOf(button);
	if (rind >= 0) {
		t.res = rind;
		t.cnt = 10;
		t.price = 100;
		t.step = 1;
	}
	if (button == "Дальше") {
		if (t.sell) {
			if (t.cnt > Planets.get(chat_id).resourceCount(t.res)) {
				Telegram.edit(chat_id, msg_id, "Недостаточно ресурсов");
				return;
			}
		}
		t.step = 2;
	}
	if (button == "Готово") {
		if(Planets.get(chat_id).addStockTask(t.sell, t.res, t.cnt, t.price))
			Telegram.edit(chat_id, msg_id, "Заявка создана");
		return;
	}
	const bs = t.sell ? "Продажа" : "Покупка";
	msg += `${bs}`;

	const cind = stockCountButtons.indexOf(button);
	if (cind >= 0) {
		if (t.step == 1) t.cnt += Number.parseInt(button);
		if (t.step == 2) t.price += Number.parseInt(button);
		if (t.cnt <= 0) t.cnt = 1;
		if (t.sell && t.step == 1) {
			const avres = Planets.get(chat_id).resourceCount(t.res);
			if (t.cnt > avres) t.cnt = avres;
		}
		if (t.price <=0 ) t.price = 1;
		if (!t.sell && t.step == 2) {
			const avm = Planets.get(chat_id).money - Planets.get(chat_id).stock.money();
			if (t.cnt * t.price > avm) t.price = Math.floor(avm/t.cnt);
		}
	}
	if (t.step == 1) {
		nbuttons = stockCountButtons.concat(["Дальше"]);
	}
	if (t.step == 2) {
		nbuttons = stockCountButtons.concat(["Готово"]);
	}
	StockTasks.set(chat_id, t);
	if (t.res >= 0) {
		msg += `  ${Resources_desc[t.res]}\n ${getResourceCount(t.res, t.cnt)}`
		if (t.step == 2) {
			msg += ` за ${money2text(t.cnt*t.price)}\n`;
			msg += `(cтоимость 1${Resources_icons[t.res]} - ${money2text(t.price)})`
		}
	}
	Telegram.edit(chat_id, msg_id, msg, nbuttons, 2);
}

function show_stock(chat_id) {
	let msg = "Биржа:\n";
	msg += GlobalMarket.info(chat_id);
	Telegram.send(chat_id, msg);
}

function help_stock(chat_id) {
	let msg = "Справка о бирже:\n";
	msg += "На бирже можно размешать заказы на покупку или продажу ресурсов.\n";
	msg += "При создании заказа автоматически резервируются средства и ресурсы для его выполнения.\n";
	msg += "Заказ можно отменить если ещё никто не принял его и не отправил свои корабли.\n";
	msg += "За создание или удаление заказа расходуется энергия из аккумуляторов в количестве 50🔋.\n";
	Telegram.send(chat_id, msg);
}

function help_ships(chat_id) {
	let msg = "Справка о кораблях:\n";
	msg += "Каждый тип корабля имеет свои характеристики: объём 📦трюма, расход 🔋энергии и т.п.\n";
	msg += "Постройка корабля осуществляется исключительно за ресурсы " + Resources_desc + "\n";
	msg += "Максимальное количество кораблей ограничено и зависит от уровня Ангара, а также 🏢Базы и 🏗Верфи .\n";
	Telegram.send(chat_id, msg);
}

function processTradeNPC() {
	//print("NPC update", NPCstock.length);
	for(let j=0; j<NPCstock.length; j++) {
		let a = new Array();
		for (const v of NPCstock[j].sell) {
			if (v.client != 0) a.push(v);
			else GlobalMarket.removeItem(v.id)
		}
		NPCstock[j].sell = a;
		let b = new Array();
		for (const v of NPCstock[j].buy) {
			if (v.client != 0) b.push(v);
			else GlobalMarket.removeItem(v.id);
		}
		NPCstock[j].buy = b;
		while (NPCstock[j].sell.length < 4) {
			NPCstock[j].add(true, getRandom(Resources.length), (2*j*j+1)*(getRandom(10)+1), 50+getRandom(100));
		}
		while (NPCstock[j].buy.length < 4) {
			NPCstock[j].add(false, getRandom(Resources.length), (2*j*j+1)*(getRandom(10)+1), 50+getRandom(100));
		}
		//print(NPCstock[j].info().msg);
	}
}

function processExpedition(chat_id, msg_id, button) {
	Planets.get(chat_id).prepareExpedition(msg_id, button);
}

function navy_unload(chat_id) {
	Planets.get(chat_id).navyUnload();
}

function ship_price(chat_id) {
	Telegram.send(chat_id, Planets.get(chat_id).infoResources() + ShipsDescription);
}
