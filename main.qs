include("building.qs")
include("storage.qs")
include("facility.qs")
include("plant.qs")
include("planet.qs")

buttonLoad["clicked()"].connect(on_buttonLoad_clicked);
buttonSave["clicked()"].connect(on_buttonSave_clicked);
buttonReset["clicked()"].connect(on_buttonReset_clicked);
let save_timer = new QTimer();
save_timer["timeout"].connect(on_buttonSave_clicked);

Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("🌌Сканер планет", "map_info");
Telegram.addCommand("Поискать 💰", "find_money");
Telegram.addCommand("🌍Планета", "planet_info");
Telegram.addCommand("🌍Планета/🔍Исследования", "research");
Telegram.addCommand("🌍Планета/🛠Строительство/Инфо", "planet_info");
Telegram.addCommand("🌍Планета/🛠Строительство/Строить ⛏Шахту", "build_plant");
Telegram.addCommand("🌍Планета/🛠Строительство/Строить 📦Хранилище", "build_storage");
Telegram.addCommand("🌍Планета/🛠Строительство/Строить 🏢Базу", "build_facility");

Telegram["receiveCommand"].connect(function(id, cmd, script) {this[script](id);});
Telegram["receiveMessage"].connect(received);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
Telegram.start("1248527509:AAHQhKqMWjtApOdUYFXmMCzEBpJeyc1sY-c");


// Исследования
let research_base = ["⛏Добыча", "🛠Стройтехника"];
 // Здесь вся БД
let Users = loadUsers();

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
	for (var value of Users.values()) {
		value.step();
	}
	on_buttonSave_clicked();
}

function received(chat_id, msg) {
	//print(msg);
	if (!Users.has(chat_id)) {
		Users.set(chat_id, new Planet(chat_id));
		Telegram.send(chat_id, "Добро пожаловать на свою планету\n для начала нужно построить шахту...");
	}
	if (msg == "отмена") {
		Telegram.send(chat_id, "Принято");
	}
	if (research_base.indexOf(msg) >= 0) {
		Telegram.send(chat_id, "В разработке...");
	}
}

function planet_info(chat_id) {
	Users.get(chat_id).info();
}

function buildSomething(chat_id, bl) {
	let p = Users.get(chat_id);
	if (p.isBuilding()) {
		Telegram.send(chat_id, "Строители заняты");
	} else {
		p.money = p[bl].build(p.money);
		Users.set(chat_id, p);
	}
}

function build_plant(chat_id) {
	buildSomething(chat_id, "plant");
}

function build_storage(chat_id) {
	buildSomething(chat_id, "storage");
}

function build_facility(chat_id) {
	buildSomething(chat_id, "facility");
}

function getRandom(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function find_money(chat_id) {
	let p = Users.get(chat_id);
	let pr = getRandom(3);
	pr *= p.facility.level*p.facility.level+1;
	pr += getRandom(3);
	p.money += pr;
	if (p.money > p.storage.capacity(p.storage.level)) {
		p.money = p.storage.capacity(p.storage.level);
		Telegram.send(chat_id, "Хранилище заполнено");
	}
	Users.set(chat_id, p);
	Telegram.send(chat_id, `Ты заработал ${pr}💰`);
}

function research(chat_id) {
	let p = Users.get(chat_id);
	if (p.facility.level > 1) {
		Telegram.sendButtons(chat_id, "Доступные исследования", research_base.concat(["отмена"]));
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 2 уровня");
	}
}


function map_info(chat_id) {
	let p = Users.get(chat_id);
	if (p.facility.level > 0) {
		let msg = "Список планет:\n";
		for (var [key, value] of Users) {
			if (key == chat_id) msg += "Ты: ";
			msg += `Планета №${key}: ${value.money}💰, ${value.plant.level}⛏, ${value.facility.level}🏢\n`;
		}
		Telegram.send(chat_id, msg);
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 1 уровня");
	}
}

function on_buttonSave_clicked() {
	let a = [];
	for (var value of Users.values()) {
		a.push(value);
	}
	SHS.save(1, JSON.stringify(a));
	//print(SHS.load(1));
}

function loadUsers() {
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
	Users = loadUsers();
}

// очистить всё, полный сброс
function on_buttonReset_clicked() {
	Users = new Map();
}
