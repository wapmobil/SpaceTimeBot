// Базовый класс строения
class Building {
	name() {
		return "";
	}
	constructor(id){
		this.level = 0;
		this.build_progress = 0;
		this.chat_id = id;
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
	step(bs) { // эта функция вызывается каждый timerDone
		if (this.build_progress > 0) {
			this.build_progress -= bs;
			//print(`build=${this.build_progress}`)
			if (this.build_progress <= 0) {
				this.level += 1;
				this.build_progress = 0;
				Telegram.send(this.chat_id, this.name() + " - строительство завершено");
			}
		}
	}
	build(money) {
		if (money >= this.cost()) {
			if (this.build_progress == 0) {
				money -= this.cost();
				this.build_progress = this.buildTime();
				Telegram.send(this.chat_id, "Строительство началось");
			} else {
				Telegram.send(this.chat_id, `Строительство ещё в процессе, осталось - ${this.build_progress}🛠`);
			}
		} else {
			Telegram.send(this.chat_id, "Недостаточно денег");
		}
		return money;
	}
	buildTime() {
		return Math.floor((this.level+2*Math.pow(Math.sin(this.level), 3))*100+10);
	}
	cost() {
		return 0;
	}
	isBuilding() {
		return this.build_progress != 0;
	}
	infoHeader() {
		return `${this.name()} ур. ${this.level}\n`;
	}
	infoFooter() {
		let msg = `(${this.cost()}💰 ${this.buildTime()}⏳)\n`;
		if (this.build_progress > 0) msg += `    Идёт строительство, осталось ${this.build_progress}⏳\n`;
		return msg;
	}
}
// Хранилище
class Storage extends Building {
	name() {
		return "📦Хранилище";
	}
	capacity(lvl) {
		return (Math.pow(2, lvl)*1000);
	}
	cost() {
		return (this.level*this.level+1)*100;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${this.capacity(this.level)}💰\n`;
		msg += `    След. ур. ${this.level+1}:  вместимость ${this.capacity(this.level+1)}💰 `;
		return msg + this.infoFooter();
	}
}

// Шахта
class Plant extends Building {
	name() {
		return "⛏Шахта";
	}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Доход +${this.level}💰\n`;
		msg += `    След. ур. ${this.level+1}:  доход +${this.level+1}💰 `;
		return msg + this.infoFooter();
	}
}

// База
class Facility extends Building {
	name() {
		return "🏢База";
	}
	cost() {
		return Math.pow(10, (this.level+3));
	}
	info() {
		let msg = this.infoHeader();
		msg += `    След. ур. ${this.level+1} `;
		return msg + this.infoFooter();
		return msg;
	}
}

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


///==========================================================
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
