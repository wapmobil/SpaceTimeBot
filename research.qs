class ResearchBase {
	constructor (id, name, desc, func, time, cost, money) {
		this.id = id;
		this.name = name;
		this.desc = desc;
		this.func = func;
		this.time = time;
		this.cost = cost;
		this.money = money;
		this.children = [];
	}

	add (...children) {
		for (let child of children) {
			this.children.push(child);
		}
		return this;
	}

	addNext (child) {
		this.children.push(child);
		return this.children[this.children.length-1];
	}

	traverse (callback, traversal = ResearchBase.Traversal.DepthFirst, cursience = [], prefix = "") {
		traversal.call(this, callback, cursience, prefix);
		return this;
	}

	reduce (callback, initial, mode, cursience = []) {
		let acc = initial;
		this.traverse((n, p) => {acc = callback(acc, n, cursience, p)}, mode, cursience);
		return acc;
	}

	every (callback) {
		return this.reduce((a, n) => a && callback(n), true);
	}

	some (callback) {
		return this.reduce((a, n) => a || callback(n), false);
	}

	find (callback, mode) {
		return this.reduce((a, n) => a || (callback(n)? n: false), false, mode);
	}

	includes (value) {
		return this.some(n => n.value === value);
	}
	info() {
		return "";
	}
	
}

class Research extends ResearchBase {
	moneyCost() {
		return this.money > 0 ? money2text(this.money) : "";
	}
	info() {
		return `${food2text(this.cost)} ${this.moneyCost()} ${time2text(this.time)}`;
	}
}

class Research2 extends ResearchBase {
	info() {
		return `${getResourceCount(3, this.cost)} ${time2text(this.time)}`;
	}
}

ResearchBase.Traversal = {
	//BreadthFirst: function(callback) {
	//	let nodes = [this];
	//	while (nodes.length > 0) {
	//		const current = nodes.shift();
	//		callback(current);
	//		nodes = nodes.concat(current.children,  ResearchBase.Traversal.BreadthFirst);
	//	}
	//},
	DepthFirst: function(callback, cursience, prefix = "") {
		callback(this, prefix);
		if (prefix.length >= 1) {
			if (prefix[prefix.length - 1] == "├") prefix = prefix.slice(0, -1) + "│";
			if (prefix[prefix.length - 1] == "└") prefix = prefix.slice(0, -1) + " ";
		}
		for (let i = 0; i < this.children.length; i++) {
			let pref = prefix;
			if (i == this.children.length-1) pref += " └";
			else pref += " ├"
			this.children[i].traverse(callback, ResearchBase.Traversal.DepthFirst, cursience, pref);
		}
	},
	Actual: function(callback, cursience, prefix = "") {
		const er = cursience.find(cr => cr.id == this.id);
		if (!er) {
			callback(this, prefix);
		} else if (er.time == 0) {
			prefix += "x";
			this.children.forEach(n => n.traverse(callback, ResearchBase.Traversal.Actual, cursience, prefix));
		} else callback(this, prefix);
	}
};


const printSienceTree = function(ret, res, cursience, prefix) {
	const with_price = false;
	let pref_main = prefix;
	if (with_price)
		if (pref_main.length >= 1)
			pref_main = pref_main.slice(0, -1) + "├";
		
	ret += "<code>" + pref_main;
	const er = cursience.find(cr => cr.id == res.id);
	if (er) ret += er.time > 0 ? "⏳" : "✅";
	else ret += "🔘";
	//ret += res.time > 0 ? (res.active ? "⏳" : "🔘") : "✅";
	ret += "</code>";
	ret += `${res.name}`;
	ret += '\n';
	if (with_price){
		let pref_price = "<code>" + prefix;
		if (pref_price.length >= 1) {
			if (pref_price[pref_price.length - 1] == "├") pref_price = pref_price.slice(0, -1) + "│";
		} else
			pref_price = " │";
		ret += pref_price + "   ";
		ret += "  ";
		ret += "</code>" + res.info();
		ret += '\n';
	}
	return ret;
}

const getSienceButtons = function(a, r) {
	a.push({button: r.name, data: r.id, script: "processResearch"});
	return a;
}

const getSienceButtons2 = function(a, r) {
	a.push({button: r.name, data: r.id, script: "processResearch2"});
	return a;
}

const getSienceRank = function(a, r, cursience, prefix) {
	a.push({id: r.id, rank: prefix.length});
	return a;
}

const printSienceDetail = function(a, r, cursience) {
	a += `<b>${r.name}</b> - ${r.info()}\n`;
	const er = cursience.find(cr => cr.id == r.id);
	if (er) {
		if (er.time > 0)
			a += `    ➡️ исследуется, осталось ${time2text(er.time)}\n`;
	}
	a += ``;
	a += `    ${r.desc}\n`;
	return a;
}


const SieceTree = function () {
	let s = new Research(1, "🌍Разведка планеты", "Исследует планету на наличие полезных ресурсов, открывает доступ к строительству 🏭Завода", "enable_factory", 1000, 100000, 0);
	s.addNext(new Research(2, "🔋Аккумуляторы", "Открывает доступ к строительству 🔋Аккумуляторов", "enable_accum", 1000, 120000, 0)).
	  addNext(new Research(3, "🔌Экономия энергии", "На 10% сокращает потребление электричества", "eco_power", 10000, 1500000, 1000)).
	  //add(new Research(4, "Налоги", "Добавляет +2💰 за каждый уровень базы", "more_taxes", 80000, 1300000)).
	  addNext(new Research(5, "🔌Экономия энергии 2", "На 10% сокращает потребление электричества", "eco_power", 10000, 1800000, 3000)).
	  addNext(new Research(6, "🔌Экономия энергии 3", "На 10% сокращает потребление электричества", "eco_power", 10000, 2000000, 10000)).
	  addNext(new Research(7, "🔌Экономия энергии 4", "На 10% сокращает потребление электричества", "eco_power", 10000, 2200000, 40000));
	s.children[0].addNext(new Research(10,"💸Торговля", "Открывает доступ к 📈Бирже", "enable_trading", 2000, 200000, 0)).
	  addNext(new Research(20,"💵Торговые связи", "Увеличивает количество заявок на бирже до 5", "increase_market", 50000, 0, 120000));
	s.children[0].addNext(new Research(9, "🚀Корабли", "Открывет доступ к постройке 🏗Верфь", "enable_ships", 2000,300000, 1000)).
	  addNext(new Research(8, "🔋Улучшеные аккумуляторы", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 5000, 100000, 4000)).
	  addNext(new Research(17, "🔋Улучшеные аккумуляторы 2", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 15000, 100000, 12000)).
	  addNext(new Research(18, "🔋Улучшеные аккумуляторы 3", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 15000, 100000, 32000));
	s.addNext(new Research(11, "🛠Быстрое строительство", "В 2 раза ускоряет постройку зданий", "fastbuild", 4000, 1000000, 5000)).
	  add(new Research(12, "📦Компактное хранение", "Увеличивает объём хранилища в 2 раза", "upgrade_capacity", 5000, 2000000, 20000)).
	  addNext(new Research(13, "🛠Быстрое строительство 2", "На 50% ускоряет постройку зданий", "fastbuild", 10000, 2000000, 10000)).
	  add(new Research(14, "📦Компактное хранение 2", "Увеличивает объём хранилища в 2 раза", "upgrade_capacity", 15000, 4000000, 50000)).
	  addNext(new Research(15, "🛠Быстрое строительство 3", "На 30% ускоряет постройку зданий", "fastbuild", 18000, 4000000, 15000)).
	  add(new Research(16, "📦Компактное хранение 3", "Увеличивает объём хранилища в 2 раза", "upgrade_capacity", 20000, 8000000, 120000));
	s.children[0].children[2].addNext(new Research(19, "👣️Экспедиции", "Открывает возможность отправлять экспедиции", "enable_expeditions", 10000, 12345, 25000)).
	  addNext(new Research(21, "🏪Командный центр", "Открывает доступ к строительству 🏪Командного центра", "enable_сommcenter", 100000, 10000000, 50000));
	return s;
}();

const InoTechTree = function () {
	let s = new Research2(1, "📟Инопланетные технологиии", "Открывет доступ к улучшениям за 📟Технологии", "upgrage_inotech", 100, 1);
	s.add(new Research2(2, "👣️Дополнительная экспедиция", "Позволяет отправлять 2 экспедиции", "upgrage_max_expeditions", 12345, 20)).
	  addNext(new Research2(3, "🔋Супер аккумуляторы 1", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 1234, 5)).
	  addNext(new Research2(4, "🔋Супер аккумуляторы 2", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 2000, 10)).
	  addNext(new Research2(5, "🔋Супер аккумуляторы 3", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 3000, 20)).
	  addNext(new Research2(6, "🔋Супер аккумуляторы 4", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 4000, 30)).
	  addNext(new Research2(7, "🔋Супер аккумуляторы 5", "Увеличивает ёмкость аккумуляторов на 20%", "upgrade_accum", 5000, 40));
	return s;
}();
