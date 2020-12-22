
pushButton_2["clicked()"].connect(on_pushButton_2_clicked);
sliderInfo["valueChanged"].connect(on_sliderInfo_valueChanged);
console.clear();

include("statistic.qs")
include("planet.qs")
include("mininig.qs")
include("helps.qs")


const isProduction = false;
const NPC_count = isProduction ? 2 : 3;
const npc_delay = 5;

buttonLoad["clicked()"].connect(on_buttonLoad_clicked);
buttonSave["clicked()"].connect(on_buttonSave_clicked);
buttonReset["clicked()"].connect(on_buttonReset_clicked);
pushButton["clicked()"].connect(on_pushButton_clicked);
let save_timer = new QTimer();
save_timer["timeout"].connect(on_buttonSave_clicked);

Cron.removeAll();
Cron.addSchedule("*/10 * * * * *", "processTradeNPC")
Cron.addSchedule("*/5 * * * * *", "statisticStep")
Cron.addSchedule("0 6 * * * *", "statisticDayStep")

Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("Подземелье/🤠Отправиться", "find_money");
Telegram.addCommand("Подземелье/ℹ️Справка", "mining_info");
Telegram.addCommand("🔍Исследования", "research");
Telegram.addCommand("💸Торговля/Купить 🍍", "buy_food");
Telegram.addCommand("💸Торговля/Продать ресурсы", "sell_resources");
Telegram.addCommand("💸Торговля/📖Мои ресурсы", "info_resources");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/📗️Мои заявки", "my_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/✳️Создать заявку", "new_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/✳️Создать 🔐скрытую заявку", "new_stock_priv");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/ℹ️Cправка", "help_stock");
Telegram.addCommand("💸Торговля/📈Биржа ресурсов/🖥Смотреть заявки", "show_stock");
Telegram.addCommand("📖Инфоцентр/🌍Планета", "planet_info");
Telegram.addCommand("📖Инфоцентр/💻Дерево исследований", "research_map");
Telegram.addCommand("📖Инфоцентр/Статистика", "stat_info");
Telegram.addCommand("📖Инфоцентр/Тест сражения", "battle_test");
Telegram.addCommand("✈️Флот", "navy_info");
Telegram.addCommand("✈️Флот/📖Инфо", "navy_info");
Telegram.addCommand("✈️Флот/📤Разгрузить", "navy_unload");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей", "ship_info");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей/📖Инфо", "ship_info");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей/⚖Сравнение моделей️", "ship_models");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей/🏗Cтроить", "ship_create");
Telegram.addCommand("✈️Флот/🏗Строительство ✈Кораблей/♻️Разобрать", "ship_reclaim");
Telegram.addCommand("✈️Флот/ℹ️Cправка", "help_ships");
Telegram.addCommand("✈️Флот/👣️Экспедиции/ℹ️Cправка", "help_expeditions");
Telegram.addCommand("✈️Флот/👣️Экспедиции/📖Инфо", "info_expeditions");
Telegram.addCommand("✈️Флот/👣️Экспедиции/👣Отправить экспедицию", "expedition_start");
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
Telegram.addCommand("🛠Строительство/🏗Верфь/🏗Строительство ✈Кораблей", "ship_info");
Telegram.addCommand("🛠Строительство/🏗Верфь/🏗Строительство ✈Кораблей/📖Инфо", "ship_info");
Telegram.addCommand("🛠Строительство/🏗Верфь/🏗Строительство ✈Кораблей/⚖Сравнение моделей️", "ship_models");
Telegram.addCommand("🛠Строительство/🏗Верфь/🏗Строительство ✈Кораблей/🏗Cтроить", "ship_create");

Telegram["receiveMessage"].connect(received);
Telegram["receiveSpecialMessage"].connect(receivedSpecial);
//Telegram["buttonPressed"].connect(telegramButton);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
//Telegram["messageSent"].connect(telegramSent);

if (isProduction) {
	Telegram.start(SHS.load(77));
	buttonReset.enabled = false;
	buttonLoad.enabled = false;
} else {
	buttonReset.enabled = true;
	Telegram.start("733272349:AAEHpMUGv0sV1JRcVS1aR8fWXIH5HpPapAQ");
}



 // Здесь вся БД
let GlobalMarket = loadMarket();
let NPCstock = loadNPC();
let GlobalNPCPlanets = loadNPCPlanets();
let Planets = loadPlanets();
let tmpNavy = new Map();
let MiningGames = new Map();
let StockTasks = new Map();
let Battles = loadBattles();

//Старт
let npc_delay_cnt = npc_delay;
let expedition_cnt = 0;
let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);
save_timer.start(timer.interval*100);
processTradeNPC(true);
//statisticStep();

function telegramConnect() {
	Telegram.sendAll("Server <b>started</b>");
	print("telegram bot connected");
}

function telegramDisconnect() {
	print("warning, telegram bot disconnected");
}

function timerDone() {
	expedition_cnt++;
	if (expedition_cnt >= (isProduction ? 60 : 3)) {
		expedition_cnt = 0;
	}
	for (var value of Planets.values()) {
		value.step();
		if(expedition_cnt == 0) value.expeditionStep();
	}
	npc_delay_cnt--;
	if (npc_delay_cnt == 0) {
		Battles.stepNPC();
		npc_delay_cnt = npc_delay;
	}
}

function received(chat_id, msg) {
	//print(msg);
	Statistica.messages++;
	if(!PlanetStats.has(chat_id)) {
		PlanetStats.set(chat_id, 0);
	}
	if(!PlanetStatsDay.has(chat_id)) {
		PlanetStatsDay.set(chat_id, 0);
	}
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
	if (msg == "📈Биржа ресурсов") {
		if (!Planets.get(chat_id).trading) {
			Telegram.send(chat_id, "Требуется исследование - 💸Торговля");
			Telegram.cancelCommand();
		}
		return;
	}
	if (msg == "👣️Экспедиции") {
		if (Planets.get(chat_id).enabled_exp == 0) {
			Telegram.send(chat_id, "Требуется исследование - 👣️Экспедиции");
			Telegram.cancelCommand();
		}
		return;
	}
}

function receivedSpecial(chat_id, msg) {
	if (Planets.has(chat_id)) {
		let s = "";
		s = "/go_";
		if (msg.substring(0, s.length) == s) {
			const id = parseInt(msg.match(/\/go_(\d+)/i)[1]);
			Planets.get(chat_id).initTradeExpedition(GlobalMarket.get(id));
			return;
		}
		s = "/commande_";
		if (msg.substring(0, s.length) == s) {
			const id = parseInt(msg.match(/\/commande_(\d+)/i)[1]);
			processExpeditionCommand(chat_id, 0, id);
			return;
		}
		s = "/e_";
		if (msg.substring(0, s.length) == s) {
			let cd = msg.match(/\/e_(\d+)x(\d+)/i);
			//print(cd[1], cd[2]);
			//const id = parseInt([1]);
			Planets.get(chat_id).expeditionSupport(parseInt(cd[1]), parseInt(cd[2]));
			return;
		}
	}
}

function telegramButton(chat_id, msg_id, button, msg) {
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
function build_facility(chat_id)  {
	const p = Planets.get(chat_id);
	if (p.facility.level >= p.farm.level) {
		Telegram.send(chat_id, `Для строительства базы требуется 🍍Ферма ${p.facility.level+1} уровня`);
	} else {
		buildSomething(chat_id, "facility");
	}
}
function build_factory(chat_id)   {buildSomething(chat_id, "factory");}
function build_accum(chat_id)     {buildSomething(chat_id, "accum");}
function build_solar(chat_id)     {buildSomething(chat_id, "solar");}
function build_spaceyard(chat_id) {buildSomething(chat_id, "spaceyard");}

function getRandom(max) {
	return Math.floor(Math.random() * Math.floor(max));
}

function processShipCreate(chat_id, msg_id, data) {
	Planets.get(chat_id).createShip(parseInt(data), msg_id);
}

function ship_create(chat_id) {
	const l = Planets.get(chat_id).spaceyard.level;
	if (l == 0) {
		Telegram.send(this.chat_id, msg_id, "Требуется построить 🏗Верфь");
		return;
	}
	let btns = [];
	let sm = ShipModels();
	for(let i=0; i<sm.length; i++) {
		if (l >= sm[i].level()) {
			btns.push({button: sm[i].name(), script: "processShipCreate", data: i});
		}
	}
	btns.push({button: "Отмена", script: "processShipCreate", data: -1});
	Telegram.send(chat_id, "Выберите корабль для постройки", btns);
}

function processShipReclaim(chat_id, msg_id, data) {
	Planets.get(chat_id).reclaimShip(parseInt(data), msg_id);
}

function ship_reclaim(chat_id) {
	const l = Planets.get(chat_id).spaceyard.level;
	if (l == 0) {
		Telegram.send(this.chat_id, "Требуется построить 🏗Верфь");
		return;
	}
	let btns = [];
	let sm = ShipModels();
	for(let i=0; i<sm.length; i++) {
		if (Planets.get(chat_id).ships.m[i].count > 0) {
			btns.push({button: sm[i].name(), script: "processShipReclaim", data: i});
		}
	}
	btns.push({button: "Отмена", script: "processShipReclaim", data: -1});
	Telegram.send(chat_id, "Выберите корабль который нужно ♻️Разобрать", btns);
}

function find_money(chat_id) {
	Statistica.mining++;
	MiningGames.set(chat_id, new MiningGame(chat_id));
	Telegram.send(chat_id, "Подземелье.\n" + MiningGames.get(chat_id).show(), miningButtons);
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
		Telegram.send(chat_id, "Доступные исследования:\n" + p.sienceListExt(), p.isSienceActive() ? [] : p.sienceList());
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 2 уровня");
	}
}

function processResearch(chat_id, msg_id, data) {
	Planets.get(chat_id).sienceStart(parseInt(data), msg_id);
}

function map_info(chat_id) {
	const p = Planets.get(chat_id);
	if (p.facility.level >= 1) {
		let msg = "Список планет:\n";
		for (var [key, value] of Planets) {
			if (value.facility.level == 0) continue;
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

function stat_info(chat_id) {
	let msg = `Всего планет ${Planets.size}\n`;
	msg += `Заявок в маркете ${GlobalMarket.items.size}\n`;
	let arr = new Array();
	let money = 0;
	let exps = 0;
	for(let i=0; i<Resources.length; i++) arr.push(0);
	for (var [key, value] of Planets) {
		for(let i=0; i<Resources.length; i++) arr[i] += value[Resources[i].name];
		money += value.money;
		exps += value.expeditions.length;
	}
	msg += "Всего ресурсов:\n";
	for(let i=0; i<Resources.length; i++) msg += getResourceInfo(i, arr[i]) + "\n";
	msg += `Деньги: ${money2text(money)}\n`;
	msg += `Экспедиций в процессе ${exps}\n`;
	Telegram.send(chat_id, msg);
}

function research_map(chat_id) {
	Telegram.send(chat_id, Planets.get(chat_id).sienceInfo());
}

function on_buttonSave_clicked() {
	let a = [];
	for (const value of Planets.values()) {
		a.push(value);
	}
	spinPlayers.setValue(a.length);
	SHS.save(isProduction ? 1 : 101, JSON.stringify(a));
	SHS.save(isProduction ? 2 : 102, JSON.stringify(GlobalMarket.save()));
	SHS.save(isProduction ? 3 : 103, JSON.stringify(NPCstock));
	SHS.save(isProduction ? 4 : 104, JSON.stringify(GlobalNPCPlanets.save()));
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
	spinPlayers.setValue(m.size);
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

function loadBattles() {
	let b = new BattleList();
	return b;
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

function loadNPCPlanets() {
	let m = new NPCPlanets();
	let data = SHS.load(isProduction ? 4 : 104);
	if (typeof data == 'string') {
		m.load(JSON.parse(data));
	}
	return m;
}

function on_buttonLoad_clicked() {
	GlobalMarket = loadMarket();
	NPCstock = loadNPC();
	GlobalNPCPlanets = loadNPCPlanets();
	Planets = loadPlanets();
	Battles = loadBattles();
}

// очистить всё, полный сброс
function on_buttonReset_clicked() {
	if (isProduction) return;
	Planets = new Map();
	GlobalMarket = new Marketplace();
	GlobalNPCPlanets = new NPCPlanets();
	Battles = new BattleList();
	//NPCstock = new Array();
	//for(let j=0; j<NPC_count; j++) NPCstock.push(new Stock(j+1));
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

function buy_food(chat_id) {
	Telegram.send(chat_id, "Покупка 🍍еды:\n" + Planets.get(chat_id).infoResources(false) + buyFoodFooter, TradeFoodButtons);
}

function sell_resources(chat_id) {
	Telegram.send(chat_id, "Продажа ресурсов:\n" + Planets.get(chat_id).infoResources(true) + sellResFooter, TradeButtons);
}

const TradeFoodButtons = function() {
	let arr = [];
	for(let j=2; j<7; j++) {
		arr.push({button: `${food2text(Math.pow(10, j))} за ${money2text(Math.pow(10, j-2))}`, data:`${Math.pow(10, j)}`, script: "processBuyFood"});
	}
	return arr;
}();

function processBuyFood(chat_id, msg_id, data) {
	Planets.get(chat_id).buyFood(parseInt(data));
	Telegram.edit(chat_id, msg_id, "Покупка 🍍еды:\n" + Planets.get(chat_id).infoResources(false) + buyFoodFooter, TradeFoodButtons);
}

const TradeButtons = function() {
	let arr = [];
	for(let j=0; j<3; j++) {
		let a = [];
		for(let i=0; i<Resources_base; i++) {
			a.push({button: `${Math.pow(10, j)} ${Resources_icons[i]}`, data: `${i} ${Math.pow(10, j)}`, script: "processSellResources"});
		}
		arr.push(a);
	}
	return arr;
}();

function processSellResources(chat_id, msg_id, data) {
	const rbi = data.split(" ");
	if (rbi.length == 2) {
		Planets.get(chat_id).sellResources(parseInt(rbi[0]), parseInt(rbi[1]));
		Telegram.edit(chat_id, msg_id, "Продажа ресурсов:\n" + Planets.get(chat_id).infoResources(true) + sellResFooter, TradeButtons);
	}
}

const buyFoodFooter = `\nСтоимость покупки: 100🍍 -> 1💰`;
const sellResFooter = `\nСтоимость продажи: 1 ресурс -> 1💰`;

function processMiningButton(chat_id, msg_id, data) {
	if (!MiningGames.has(chat_id)) return;
	let ind = parseInt(data);
	let cont = false;
	if (ind >= 10) {
		ind -= 10;
		cont = true;
	}
	if (ind >= 0 && ind < 4) {
		switch (MiningGames.get(chat_id).move(ind + 1, cont)) {
			case 1:
				Planets.get(chat_id).money += MiningGames.get(chat_id).pl.money;
				Statistica.mining_ok++;
				Statistica.mining_money_all += MiningGames.get(chat_id).pl.money;
				Statistica.mining_money_max = Math.max(Statistica.mining_money_max, MiningGames.get(chat_id).pl.money);
				let finishMsg = "Вы выбрались из подземелья!\n";
				finishMsg +="Денег собрано:";
				finishMsg +=`${MiningGames.get(chat_id).pl.money}`;
				finishMsg += "💰";
				Telegram.edit(chat_id, msg_id, finishMsg);
				MiningGames.delete(chat_id);
			break;
			case 2:
				let deathMsg ="Ты пал в бою\n";
				deathMsg += "Ты потерял ресурсов: ";
				deathMsg += `${MiningGames.get(chat_id).pl.money}`;
				deathMsg += "💰";
				Telegram.edit(chat_id, msg_id, deathMsg);
				MiningGames.delete(chat_id);
				Statistica.mining_fail++;
			break;
			case 0:
			Telegram.edit(chat_id, msg_id, "Подземелье.\n" + MiningGames.get(chat_id).show(), miningButtons);
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
	Telegram.send(chat_id, "Мои заявки:\n" + m.msg, m.buttons);
}

function processStockRemove(chat_id, msg_id, data) {
	Planets.get(chat_id).removeStockTask(parseInt(data));
	const m = Planets.get(chat_id).stock.info(true);
	Telegram.edit(chat_id, msg_id, "Мои заявки:\n" + m.msg, m.buttons);
}

function new_stock(chat_id) {
	StockTasks.set(chat_id, {});
	Telegram.send(chat_id, "Создание заявки:", [[{button: "Купить", script: "processStockAdd"}, {button: "Продать", script: "processStockAdd"}]]);
}

function new_stock_priv(chat_id) {
	StockTasks.set(chat_id, {priv: true});
	Telegram.send(chat_id, "Создание заявки:", [[{button: "Купить", script: "processStockAdd"}, {button: "Продать", script: "processStockAdd"}]]);
}

function processStockAdd(chat_id, msg_id, data) {
	let t = StockTasks.get(chat_id);
	let nbuttons = [];
	let msg = "Создание заявки:\n";
	if (data == "Купить")  {t.sell = false; t.step = 0;}
	if (data == "Продать") {t.sell = true;  t.step = 0;}
	const rind = Resources_desc.indexOf(data);
	if (rind >= 0) {
		t.res = rind;
		t.cnt = 10;
		t.price = 100;
		t.step = 1;
		const avres = Planets.get(chat_id).resourceCount(t.res);
		if (avres <= 0 && t.sell) {
			Telegram.edit(chat_id, msg_id, `Нет в наличии ${Resources_desc[t.res]}`);
			return;
		}
	}
	if (t.step == 0) {
		for (let i=0; i<Resources_desc.length; i++) {
			nbuttons.push({button: Resources_desc[i], script: "processStockAdd"});
		}
	}
	if (data == "Дальше") {
		if (t.sell) {
			if (t.cnt > Planets.get(chat_id).resourceCount(t.res)) {
				Telegram.edit(chat_id, msg_id, "Недостаточно ресурсов");
				return;
			}
		}
		t.step = 2;
	}
	if (data == "Готово") {
		if(Planets.get(chat_id).addStockTask(t.sell, t.res, t.cnt, t.price, t.priv))
			Telegram.edit(chat_id, msg_id, "Заявка создана");
		return;
	}
	const bs = t.sell ? "Продажа" : "Покупка";
	msg += `${bs}`;

	const cind = stockCountButtons.indexOf(data);
	//print(data, cind);
	if (cind >= 0) {
		if (t.step == 1) t.cnt += parseInt(data);
		if (t.step == 2) t.price += parseInt(data);
		if (t.sell && t.step == 1) {
			const avres = Planets.get(chat_id).resourceCount(t.res);
			if (t.cnt > avres) t.cnt = avres;
		}
		if (t.cnt <= 0) t.cnt = 1;
		if (t.price <=0 ) t.price = 1;
		if (!t.sell && t.step == 2) {
			const avm = Planets.get(chat_id).money - Planets.get(chat_id).stock.money();
			if (t.cnt * t.price > avm) t.price = Math.floor(avm/t.cnt);
		}
	}
	if (nbuttons.length == 0) {
		for (let i=0; i<stockCountButtons.length; i+=2) {
			nbuttons.push([{button: stockCountButtons[i  ], script: "processStockAdd"},
						   {button: stockCountButtons[i+1], script: "processStockAdd"}]);
		}
	}
	if (t.step == 1) {
		nbuttons.push({button: "Дальше", script: "processStockAdd"});
	}
	if (t.step == 2) {
		nbuttons.push({button: "Готово", script: "processStockAdd"});
	}
	StockTasks.set(chat_id, t);
	if (t.res >= 0) {
		msg += `  ${Resources_desc[t.res]}\n ${getResourceCount(t.res, t.cnt)}`
		if (t.step == 2) {
			msg += ` за ${money2text(t.cnt*t.price)}\n`;
			msg += `(cтоимость 1${Resources_icons[t.res]} - ${money2text(t.price)})`
		}
	}
	Telegram.edit(chat_id, msg_id, msg, nbuttons);
}

function show_stock(chat_id) {
	let msg = "Биржа:\n";
	msg += "Выберите тип заявки"; //GlobalMarket.info(chat_id);
	Telegram.send(chat_id, msg, stockFilterButtons);
}

function processStockFilter(chat_id, msg_id, button) {
	let msg = "Биржа:\n";
	msg += GlobalMarket.info(chat_id, button);
	Telegram.edit(chat_id, msg_id, msg, stockFilterButtons);
}

function processTradeNPC(on) {
	if (on) {
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
				NPCstock[j].add(true, getRandom(Resources_base), (2*j*j+1)*(getRandom(20)+1), 100+getRandom(100));
			}
			while (NPCstock[j].buy.length < 4) {
				NPCstock[j].add(false, getRandom(Resources_base), (2*j*j+1)*(getRandom(20)+1), 50+getRandom(100));
			}
			//print(NPCstock[j].info().msg);
		}
	}
}

function processTradeExpedition(chat_id, msg_id, data) {
	Planets.get(chat_id).prepareTradeExpedition(msg_id, data);
}

function navy_unload(chat_id) {
	Planets.get(chat_id).navyUnload();
}

function ship_info(chat_id) {
	Telegram.send(chat_id, Planets.get(chat_id).buildShipInfo());
}

function ship_models(chat_id) {
	Telegram.send(chat_id, ShipsDescription);
}


function createTestBattle(chat_id) {
	let enemy = new Navy(1);
	enemy.type = 1;
	enemy.m = enemyShips();
	enemy.m[0].count = 60;
	enemy.m[1].count = 30;
	enemy.m[2].count = 3;
	let nv = new Navy(chat_id);
	nv.type = 1;
	nv.m[1].count = 200;
	nv.m[2].count = 20;
	nv.m[3].count = 7;
	//nv.m[4].count = 5;
	nv.m[5].count = 4;
	return new Battle(nv, enemy);
}

function battle_test(chat_id) {
	let btid = Planets.get(chat_id).battle;
	//if (!Battles.b.has(btid)) {
		btid = Battles.addBattle(createTestBattle(chat_id));
		Planets.get(chat_id).battle = btid;
	//}
	const b = Battles.b.get(btid);
	Telegram.send(chat_id, b.info(chat_id), b.buttons(chat_id));
}

function battle_start(chat_id, msg_id, data) {
	let btid = Planets.get(chat_id).battle;
	if (Battles.b.has(btid)) {
		Battles.b.get(btid).start(chat_id, msg_id);
		const b = Battles.b.get(btid);
		Telegram.edit(chat_id, msg_id, b.info(chat_id), b.buttons(chat_id));
	}
}

function battle_step(chat_id, msg_id, data) {
	let btid = Planets.get(chat_id).battle;
	if (Battles.b.has(btid)) {
		Battles.b.get(btid).step(chat_id, data);
	}
}

function on_sliderInfo_valueChanged(val) {
	let ks = Planets.keys();
	let index = 0;
	for (const key of ks) {
		if (index == val) {
			labelPlayerInfo.setText(`Планета №${key}\n`+Planets.get(key).shipsCountInfo() + Planets.get(key).info(true));
			return;
		}
		index++;
	}
	labelPlayerInfo.setText("Игрока не существует");
}

function on_pushButton_2_clicked() {
	Telegram.sendAll(pushButton_2.text);
}

function expedition_start(chat_id) {
	Planets.get(chat_id).initExpeditionRS(2);
}

function processExpeditionRS(chat_id, msg_id, data) {
	Planets.get(chat_id).prepareExpeditionRS(msg_id, data);
}

function info_expeditions(chat_id) {
	Planets.get(chat_id).navyInfo(true);
	//Telegram.send(chat_id, `Обнаруженные планеты: ${GlobalNPCPlanets.planets.size}`);
}

function processExpeditionCommand(chat_id, msg_id, data) {
	let npc = GlobalNPCPlanets.getPlanet(parseInt(data));
	if (npc) {
		Planets.get(chat_id).expeditionCommand(npc, msg_id);
	} else {
		Telegram.send(chat_id, "Ошибка, координаты потеряны или корабли уже покинули это место");
	}
}

function processExpeditionCommand2(chat_id, msg_id, data) {
	const sid = data.split(" ");
	if (sid.length != 2)  {
		print(sid,  data);
		Telegram.edit(chat_id, msg_id, "Ошибка");
		return;
	}
	Planets.get(chat_id).expeditionProcessCommand(msg_id, parseInt(sid[0]), parseInt(sid[1]));
}
