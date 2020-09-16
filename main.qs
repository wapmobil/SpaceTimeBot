Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("планета/инфа", "planet_info");
Telegram.addCommand("планета/строить шахту", "build_plant");
Telegram.addCommand("карта", "map_info");

Telegram["receiveCommand"].connect(function(id, cmd, script) {this[script](id);});
//Telegram["receiveMessage"].connect(received);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
Telegram.start("733272349:AAFUM4UUYlKepYilMt2q3s27g5L5sAoEmVE");

let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);

let Users = new Map(); // Здесь вся БД

// Шахта
class Plant {
	constructor(id){
		this.level = 0;
		this.build_progress = 0;
		this.chat_id = id;
	}
	build() {
		if (this.build_progress == 0) {
			this.build_progress = 10*(this.level*this.level+1);
			return true;
		} else {
			return false;
		}
	}
	step() { // эта функция вызывается каждый timerDone
		if (this.build_progress > 0) {
			this.build_progress -= 1;
			//print(`build=${this.build_progress}`)
			if (this.build_progress == 0) {
				this.level += 1;
				Telegram.send(this.chat_id, `Шахта построена`);
			}
		}
	}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
}

// Планета
class Planet {
	constructor(id){
		this.money = 200;
		this.plant = new Plant(id);
		this.chat_id = id;
	}
	info() { // отобразить текущее состояние планеты
		let msg =  `Деньги = ${this.money}💰\n`;
		msg += `Шахта: доход +${this.plant.level}💰)\n`;
		msg += `Следующий уровень: доход +${this.plant.level+1}💰)\n`;
		msg += `Стоимость постройки: ${this.plant.cost()}💰\n`;
		if (this.plant.build_progress > 0) msg += `Идёт строительство, осталось - ${this.plant.build_progress}🛠`;
		Telegram.send(this.chat_id, msg);
	}
	step() { // эта функция вызывается каждый timerDone
		this.plant.step();
		this.money += this.plant.level;
	}
	buildPlant() { // построить шахту
		if (this.money >= this.plant.cost()) {
			if (this.plant.build()) {
				this.money -= this.plant.cost();
				Telegram.send(this.chat_id, "Строительство началось");
			} else {
				Telegram.send(this.chat_id, `Строительство ещё в процессе, осталось - ${this.plant.build_progress}🛠`);
			}
		} else {
			Telegram.send(this.chat_id, "Недостаточно денег");
		}
	}
}

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
}

//function received(chat_id, msg) { // сюда приходят сообщения, не содержащиеся в фиксированном меню
//	print(`message:\"${msg}\" from ${chat_id}`);
//}

function planet_info(chat_id) {
	if (!Users.has(chat_id)) {
		Users.set(chat_id, new Planet(chat_id));
	}
	Users.get(chat_id).info();
}

function build_plant(chat_id) {
	let p = Users.get(chat_id);
	p.buildPlant();
	Users.set(chat_id, p);
}

function map_info(chat_id) {
	let i = 10;
	let msg = "Другие планеты:\n";
	for (var [key, value] of Users) {
		msg += `Планета №${key}: деньги ${value.money}, шахта ${value.plant.level}\n`;
	}
	Telegram.send(chat_id, msg);
}
	