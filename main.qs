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
	step() { // эта функция вызывается каждый timerDone
		if (this.build_progress > 0) {
			this.build_progress -= 1;
			//print(`build=${this.build_progress}`)
			if (this.build_progress == 0) {
				this.level += 1;
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
		return 0;
	}
	cost() {
		return 0;
	}
	isBuilding() {
		return this.build_progress != 0;
	}
}
// Хранилище
class Storage extends Building {
	name() {
		return "Хранилище";
	}
	buildTime() {
		return 10*(this.level*this.level*this.level+1);
	}
	capacity(lvl) {
		return (Math.pow(2, lvl)*1000);
	}
	cost() {
		return ((this.level*this.level+1)*1000);
	}
	info() {
		let msg = `${this.name()}:\n`;
		msg += `  Хранилище: вместимость ${this.capacity(this.level)}💰\n`;
		msg += `  Следующий: вместимость ${this.capacity(this.level+1)}💰\n`;
		msg += `  Стоимость: ${this.cost()}💰\n`;
		msg += `  Время: ${this.buildTime()}⏳\n`;
		if (this.build_progress > 0) msg += `  Идёт строительство, осталось - ${this.build_progress}🛠\n`;
		return msg;
	}
}

// Шахта
class Plant extends Building {
	name() {
		return "Шахта";
	}
	buildTime() {
		return 10*(this.level*this.level+1);
	}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = `${this.name()}:\n`;
		msg += `  Доход +${this.level}💰\n`;
		msg += `  Следующий: доход +${this.level+1}💰\n`;
		msg += `  Стоимость: ${this.cost()}💰\n`;
		msg += `  Время: ${this.buildTime()}⏳\n`;
		if (this.build_progress > 0) msg += `  Идёт строительство, осталось - ${this.build_progress}🛠\n`;
		return msg;
	}
}

// База
class Facility extends Building {
	name() {
		return "База";
	}
	buildTime() {
		return this.cost();
	}
	cost() {
		return Math.pow(10, (this.level+3));
	}
	info() {
		let msg = `${this.name()}:\n`;
		msg += `  Уровень базы ${this.level}🏢\n`;
		msg += `  Стоимость: ${this.cost()}💰\n`;
		msg += `  Время: ${this.buildTime()}⏳\n`;
		if (this.build_progress > 0) msg += `  Идёт строительство, осталось - ${this.build_progress}🛠\n`;
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
		let msg = `Деньги = ${this.money}💰\n`;
		msg += this.plant.info();
		msg += this.storage.info();
		msg += this.facility.info();
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.plant.step();
		this.storage.step();
		this.facility.step();
		if (this.money < this.storage.capacity(this.storage.level)) {
			this.money += this.plant.level;
			if (this.money > this.storage.capacity(this.storage.level)) {
				this.money = this.storage.capacity(this.storage.level);
				Telegram.send(this.chat_id, "Хранилище заполнено");
			}
		}
	}
	buildPlant() { // построить шахту
		this.money = this.plant.build(this.money);
	}
	buildStorage() { // построить шахту
		this.money = this.storage.build(this.money);
	}
	buildFacility() { // построить шахту
		this.money = this.facility.build(this.money);
	}
	researchMining() {
		Telegram.send(this.chat_id, "В разработке...");
	}
	researchBuilding() {
		Telegram.send(this.chat_id, "В разработке...");
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
Telegram.addCommand("карта🌌", "map_info");
Telegram.addCommand("поискать 💰", "find_money");
Telegram.addCommand("планета🌍/инфа🏙", "planet_info");
Telegram.addCommand("планета🌍/исследования🔍", "research");
Telegram.addCommand("планета🌍/строительство🛠", "planet_info");
Telegram.addCommand("планета🌍/строительство🛠/строить шахту⛏", "build_plant");
Telegram.addCommand("планета🌍/строительство🛠/строить хранилище📦", "build_storage");
Telegram.addCommand("планета🌍/строительство🛠/строить базу🏢", "build_facility");

Telegram["receiveCommand"].connect(function(id, cmd, script) {this[script](id);});
Telegram["receiveMessage"].connect(received);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
Telegram.start("733272349:AAFUM4UUYlKepYilMt2q3s27g5L5sAoEmVE");

let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);


// Исследования
let research_base = ["добыча", "строительство"];
 // Здесь вся БД
let Users = loadUsers();
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
}

function planet_info(chat_id) {
	Users.get(chat_id).info();
}

function build_plant(chat_id) {
	let p = Users.get(chat_id);
	p.buildPlant();
	Users.set(chat_id, p);
}

function build_storage(chat_id) {
	let p = Users.get(chat_id);
	p.buildStorage();
	Users.set(chat_id, p);
}

function build_facility(chat_id) {
	let p = Users.get(chat_id);
	p.buildFacility();
	Users.set(chat_id, p);
}

function getRandom(max) {
  return Math.floor(Math.random() * Math.floor(max));
}

function find_money(chat_id) {
	let p = Users.get(chat_id);
	let pr = getRandom(3);
	p.money += pr * (p.facility.level*2+1);
	Users.set(chat_id, p);
	Telegram.send(chat_id, `Ты заработал ${pr}💰`);
}

function research(chat_id) {
	let p = Users.get(chat_id);
	if (p.facility.level > 1) {
		Telegram.sendButtons(chat_id, "Доступные исследования", research_base.concat(["отмена"]));
	} else {
		Telegram.send(chat_id, "Требуется база 2🏢 уровня");
	}
}


function map_info(chat_id) {
	let i = 10;
	let msg = "Другие планеты:\n";
	for (var [key, value] of Users) {
		msg += `Планета №${key}: деньги ${value.money}, шахта ${value.plant.level}, база ${value.facility.level}\n`;
	}
	Telegram.send(chat_id, msg);
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

function on_buttonReset_clicked() {
	Users = new Map();
}
