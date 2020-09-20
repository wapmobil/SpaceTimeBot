include("planet.qs")

buttonLoad["clicked()"].connect(on_buttonLoad_clicked);
buttonSave["clicked()"].connect(on_buttonSave_clicked);
buttonReset["clicked()"].connect(on_buttonReset_clicked);
pushButton["clicked()"].connect(on_pushButton_clicked);
let save_timer = new QTimer();
save_timer["timeout"].connect(on_buttonSave_clicked);
buttonReset.enabled = true;

Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("🌌Сканер планет", "map_info");
Telegram.addCommand("Поискать 💰", "find_money");
Telegram.addCommand("🔍Исследования", "research");
Telegram.addCommand("📖Инфо/🌍Планета", "planet_info");
Telegram.addCommand("📖Инфо/💻Дерево исследований", "research_map");
//Telegram.addCommand("🛠Строительство", "planet_info");
Telegram.addCommand("🛠Строительство/⛏Шахта", "info_plant");
Telegram.addCommand("🛠Строительство/⛏Шахта/🛠Cтроить", "build_plant");
Telegram.addCommand("🛠Строительство/⚡️Электростанция", "info_solar");
Telegram.addCommand("🛠Строительство/⚡️Электростанция/🛠Cтроить", "build_solar");
Telegram.addCommand("🛠Строительство/🔋Аккумулятор", "info_accum");
Telegram.addCommand("🛠Строительство/🔋Аккумулятор/🛠Cтроить", "build_accum");
Telegram.addCommand("🛠Строительство/📦Хранилище", "info_storage");
Telegram.addCommand("🛠Строительство/📦Хранилище/🛠Cтроить", "build_storage");
Telegram.addCommand("🛠Строительство/🏢База", "info_facility");
Telegram.addCommand("🛠Строительство/🏢База/🛠Cтроить", "build_facility");
Telegram.addCommand("🛠Строительство/🏭Завод", "info_factory");
Telegram.addCommand("🛠Строительство/🏭Завод/🛠Cтроить", "build_factory");

Telegram["receiveCommand"].connect(function(id, cmd, script) {this[script](id);});
Telegram["receiveMessage"].connect(received);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
Telegram.start("733272349:AAH9YTSyy3RmGV4A6OWKz1b3CeKnPI2ROd8");


 // Здесь вся БД
let Planets = loadPlanets();

//Старт
let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);
save_timer.start(timer.interval*10);



function telegramConnect() {
	Telegram.sendAll("Server started");
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
	if (!Planets.has(chat_id)) {
		Planets.set(chat_id, new Planet(chat_id));
		Telegram.send(chat_id,
		 "Поздравляю с успешным приземлением!\n" +
		 "Добро пожаловать на свою собственную планету.\n" +
		 "Тебе крупно повезло и планета пригодна для жизни,\n" +
		 "теперь у тебя есть шанс создать свой флот и развитую экономику.\n" +
		 "Для начала неплохо бы построить электростанцию а потом и шахту..."
		 );
		Telegram.cancelCommand();
		return;
	}
	if (msg == "отмена") {
		Telegram.send(chat_id, "Принято");
		//Telegram.cancelCommand();
		return;
	}
	//print(msg.substring(0,2));
	if (msg.substring(0,2) == "🔍" && msg != "🔍Исследования") {
		let research_list = Planets.get(chat_id).sienceList();
		print(research_list);
		if (research_list.indexOf(msg) >= 0) {
			Planets.get(chat_id).sienceStart(msg);
			Telegram.send(chat_id, "Исследование началось");
		} else {
			Telegram.send(chat_id, "Исследование недоступно");
		}
	}
}

function planet_info(chat_id) {
	Planets.get(chat_id).info();
}

function infoSomething(chat_id, bl) {
	Telegram.send(chat_id, Planets.get(chat_id)[bl].info());
}
function info_plant(chat_id) {infoSomething(chat_id, "plant");}
function info_storage(chat_id) {infoSomething(chat_id, "storage");}
function info_facility(chat_id) {infoSomething(chat_id, "facility");}
function info_factory(chat_id) {infoSomething(chat_id, "factory");}
function info_accum(chat_id) {infoSomething(chat_id, "accum");}
function info_solar(chat_id) {infoSomething(chat_id, "solar");}

function buildSomething(chat_id, bl) {
	//let p = Planets.get(chat_id);
	if (Planets.get(chat_id).isBuilding()) {
		Telegram.send(chat_id, "Строители заняты");
	} else {
		Planets.get(chat_id).money = Planets.get(chat_id)[bl].build(Planets.get(chat_id).money, Planets.get(chat_id).energy());
		//Planets.set(chat_id, p);
	}
}
function build_plant(chat_id) {buildSomething(chat_id, "plant");}
function build_storage(chat_id) {buildSomething(chat_id, "storage");}
function build_facility(chat_id) {buildSomething(chat_id, "facility");}
function build_factory(chat_id) {buildSomething(chat_id, "factory");}
function build_accum(chat_id) {buildSomething(chat_id, "accum");}
function build_solar(chat_id) {buildSomething(chat_id, "solar");}

function getRandom(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function find_money(chat_id) {
	let p = Planets.get(chat_id);
	let pr = getRandom(3);
	pr *= p.facility.level*p.facility.level+1;
	pr += getRandom(3);
	p.money += pr;
	if (p.money > p.storage.capacity(p.storage.level)) {
		p.money = p.storage.capacity(p.storage.level);
		Telegram.send(chat_id, "Хранилище заполнено");
	}
	Planets.set(chat_id, p);
	Telegram.send(chat_id, `Ты заработал ${pr}💰`);
}

function research(chat_id) {
	let p = Planets.get(chat_id);
	//if (p.facility.level > 1) {
		Telegram.sendButtons(chat_id, "Доступные исследования", p.sienceList().concat(["отмена"]));
	//} else {
	//	Telegram.send(chat_id, "Требуется 🏢База 2 уровня");
	//}
}


function map_info(chat_id) {
	let p = Planets.get(chat_id);
	if (p.facility.level > 0) {
		let msg = "Список планет:\n";
		for (var [key, value] of Planets) {
			if (key == chat_id) msg += "Ты: ";
			msg += `Планета №${key}: ${value.money}💰, ${value.plant.level}⛏, ${value.facility.level}🏢\n`;
		}
		Telegram.send(chat_id, msg);
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 1 уровня");
	}
}

function research_map(chat_id) {
	//print("vsfdvfsdvf");
	//let p = Planets.get(chat_id);
	//print(Planets.get(chat_id).sienceInfo());
	Telegram.send(chat_id, Planets.get(chat_id).sienceInfo());
}

function on_buttonSave_clicked() {
	let a = [];
	for (var value of Planets.values()) {
		a.push(value);
	}
	SHS.save(1, JSON.stringify(a));
	//print(SHS.load(1));
}

function loadPlanets() {
	let data = SHS.load(1);
	//print(data);
	let m = new Map();
	if (typeof data == 'string') {
		const arr = JSON.parse(data);
		arr.forEach(function(item) {
			let p = new Planet(item.chat_id);
			p.load(item);
	  		m.set(item.chat_id, p);
		});
	}
	return m;
}

function on_buttonLoad_clicked() {
	Planets = loadPlanets();
}

// очистить всё, полный сброс
function on_buttonReset_clicked() {
	Planets = new Map();
}

function on_pushButton_clicked() {
	Telegram.sendAll(lineEdit.text);
}
