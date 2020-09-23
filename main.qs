include("planet.qs")

const isProduction = false;

buttonLoad["clicked()"].connect(on_buttonLoad_clicked);
buttonSave["clicked()"].connect(on_buttonSave_clicked);
buttonReset["clicked()"].connect(on_buttonReset_clicked);
pushButton["clicked()"].connect(on_pushButton_clicked);
let save_timer = new QTimer();
save_timer["timeout"].connect(on_buttonSave_clicked);


Telegram.clearCommands();
Telegram.disablePassword();
Telegram.addCommand("Поискать 💰", "find_money");
Telegram.addCommand("🔍Исследования", "research");
Telegram.addCommand("📖Инфо/🌍Планета", "planet_info");
Telegram.addCommand("📖Инфо/💻Дерево исследований", "research_map");
Telegram.addCommand("📖Инфо/🌌Сканер планет", "map_info");
Telegram.addCommand("🛠Строительство/📖Инфо", "planet_info");
Telegram.addCommand("🛠Строительство/⛏Шахта", "info_plant");
Telegram.addCommand("🛠Строительство/⛏Шахта/📖Инфо", "info_plant");
Telegram.addCommand("🛠Строительство/⛏Шахта/🛠Cтроить ⛏Шахту", "build_plant");
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
Telegram["buttonPressed"].connect(telegramButton);
Telegram["connected"].connect(telegramConnect);
Telegram["disconnected"].connect(telegramDisconnect);
Telegram["messageSent"].connect(telegramSent);

if (isProduction) {
	Telegram.start(SHS.load(77));
	label.hide();
} else {
	buttonReset.enabled = true;
	Telegram.start("733272349:AAH9YTSyy3RmGV4A6OWKz1b3CeKnPI2ROd8");
}


 // Здесь вся БД
let Planets = loadPlanets();

//Старт
let timer = new QTimer();
timer["timeout"].connect(timerDone);
timer.start(1000);
save_timer.start(timer.interval*10);



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
}

function telegramSent(chat_id, msg_id, msg) {
	print("messageSended:" + msg);
}

function planet_info(chat_id) {
	Planets.get(chat_id).info();
}

function infoSomething(chat_id, bl) {
	let p = Planets.get(chat_id);
	if (p[bl].locked) Telegram.send(chat_id, "Требуется исследование");
	else Telegram.send(chat_id, p.infoResources(false) + p[bl].description() + '\n' + p[bl].info());
}
function info_plant(chat_id) {infoSomething(chat_id, "plant");}
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
		Planets.get(chat_id).money = Planets.get(chat_id)[bl].build(Planets.get(chat_id).money, Planets.get(chat_id).energy());
		//Planets.set(chat_id, p);
	}
}
function build_plant(chat_id)     {buildSomething(chat_id, "plant");}
function build_storage(chat_id)   {buildSomething(chat_id, "storage");}
function build_facility(chat_id)  {buildSomething(chat_id, "facility");}
function build_factory(chat_id)   {buildSomething(chat_id, "factory");}
function build_accum(chat_id)     {buildSomething(chat_id, "accum");}
function build_solar(chat_id)     {buildSomething(chat_id, "solar");}
function build_spaceyard(chat_id) {buildSomething(chat_id, "spaceyard");}

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
	Telegram.send(chat_id, `Ты заработал ${money2text(pr)}`);
}

function research(chat_id) {
	Planets.get(chat_id).checkSience();
	let p = Planets.get(chat_id);
	if (p.facility.level > 1) {
		Telegram.sendButtons(chat_id, "Доступные исследования:\n" + p.sienceListExt(), p.sienceList());
	} else {
		Telegram.send(chat_id, "Требуется 🏢База 2 уровня");
	}
}


function map_info(chat_id) {
	let p = Planets.get(chat_id);
	if (p.facility.level >= 1) {
		let msg = "Список планет:\n";
		for (var [key, value] of Planets) {
			if (key == chat_id) msg += "Ты: ";
			msg += `<b>Планета №${key}:</b> ${value.facility.level}🏢\n`
			msg += `    ${money2text(value.money)}`;
			if (p.facility.level >= 2) {
				for(let i=0; i<Resources.length; i++)
					msg += `|${getResourceCount(i, value[Resources[i].name])}`;
			}
			if (p.facility.level >= 4) {
				msg += '\n    ';
				let bds = value.getBuildings();
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
	Planets.get(chat_id).checkSience();
	Telegram.send(chat_id, Planets.get(chat_id).sienceInfo());
}

function on_buttonSave_clicked() {
	let a = [];
	for (var value of Planets.values()) {
		a.push(value);
	}
	SHS.save(isProduction ? 1 : 101, JSON.stringify(a));
	//print(SHS.load(1));
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

function money2text(m) {
	let s = `${m}`, ret = "", dc = Math.floor((s.length - 1) / 3), of = s.length - (dc*3);
	for (let j = 0; j <= dc; ++j) {
		if (j == 0) ret += s.substring(0, of);
		else {
			ret += "\'" + s.substr(of + (3*(j-1)), 3);
		}
	}
	return ret + "💰";
}

function time2text(t) {
	function num2g(v, align) {
		let ret = `${v}`
		if (align && ret.length < 2)
			ret = `0${ret}`;
		return ret;
	}
	let h = Math.floor(t / 3600);
	t -= h * 3600;
	let m = Math.floor(t / 60);
	t -= m * 60;
	let ret = "";
	if (h > 0) ret += `${h}:`;
	if (h > 0 || m > 0) ret += num2g(m, h > 0) + ":";
	ret += num2g(t, h > 0 || m > 0);
	return ret + "⏳";
}
