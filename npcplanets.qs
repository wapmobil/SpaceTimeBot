include("battle.qs")

class NPCPlanet {
	constructor(id, owner) {
		this.id = id;
		this.owner = owner;
		this.ships = new Navy(1);
		this.ships.type = 1;
		this.ships.m = enemyShips();
		this.ships.dst = id;
		this.type = 0;
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
	}
	generate(x) {
		Statistica.expeditions_rs++;
		this.type = getRandom(20);
		//if (this.type < 1) return;
		let rnd = Math.floor(this.type / 5) + 1;
		let crnd = 1;
		if (this.type >= 5) crnd += 10;
		if (this.type >= 10) crnd += 10;
		if (this.type >= 11) {
			this.ships.m[0].count = getRandom(this.type);
		}
		if (this.type >= 15) {
			//crnd = 0;
			rnd += 1;
		}
		if (this.type == 16) {
			rnd = 0;
			this.ships.m[1].count = getRandom(this.type);
		}
		if (this.type >= 17) {
			this.ships.m[0].count = getRandom((this.type - 8)*5);
		}
		if (this.type == 18) {
			rnd += 2;
			this.ships.m[1].count += Math.floor(this.ships.m[0].count / 10);
		}
		for(let i=0; i<rnd; i++)
			this[Resources[getRandom(Resources_base)].name] += getRandom(this.type)*2 + crnd*2;
		if (this.type >= 19) {
			this[Resources[getRandom(Resources_base)].name] += 100 + getRandom(50);
			this.ships.m[0].count += Math.floor(this.totalResources()/2);
			this.ships.m[1].count += this.type;
		}
		if (this.type == 20) {
			this.ino_tech += 6 + getRandom(4);
			this.ships.m[0].count += this.ino_tech*2;
			this.ships.m[1].count += 5;
			this.ships.m[2].count += 1;
			if (getRandom(2) == 0) {
				for(let i=0; i<Resources_base; i++) this[Resources[i].name] += 500 + getRandom(500);
				this.ships.m[2].count += 10 + getRandom(10);
			}
		}
		if (this.ships.countAll() > 0) this.ships.money +=
				this.ships.countAll()*100 +
				getRandom(this.ships.countAll()*100) +
				this.ships.m[1].count*1000 +
				this.ships.m[2].count*10000;
		//print(this.type, rnd);
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == "ships") this.ships.load(value);
			else this[key] = value;
		}
		this.ships.dst = this.id;
	}
	totalResources() {
		let total_res = 0;
		for(let i=0; i<Resources.length; i++) total_res += this[Resources[i].name];
		return total_res;
	}
	info(first) { // отобразить текущее состояние планеты
		let msg = "";
		let pn = "";
		if (this.type < 2) {msg += "Вы обнаружили заброшенную станцию"; pn = "Заброшенная станция";}
		else if (this.type < 8) {msg += "Найдены обломки"; pn = "Обломки";}
		else if (this.type < 10) {msg += "Обнаружен космический мусор"; pn = "Космический мусор";}
		else if (this.type < 15) {msg += "Вы обнаружили астероид"; pn = "Астероид";}
		else {msg += "Ура! Неизвестная планета!"; pn = "Неизвестная планета";}
		if (!first) msg = "<b>"+pn+"</b>";
		msg += "\n координаты: /eh_" + this.owner + "x" + this.id + "\n";
		if (this.totalResources() == 0) {
			msg += "Здесь нет ничего полезного\n";
		} else {
			for(let i=0; i<Resources.length; i++) {
				if (this[Resources[i].name] > 0) {
					msg += getResourceInfo(i, this[Resources[i].name]) + "\n";
				}
			}
		}
		if (this.ships.countAll() > 0) {
			msg += this.ships.info("Инопланетяне");
		}
		return msg;
	}
}

class NPCPlanets {
	constructor() {
		this.gid = 1;
		this.planets = new Map();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == 'planets') {
				if (Array.isArray(value)) {
					for (const v of value) {
						let si = new NPCPlanet();
						si.load(v);
						this.planets.set(si.id, si);
					}
				}
			} else {
				this[key] = value;
			}
		}
		//print(this.planets.size);
	}
	save() {
		let arr = [];
		for (const i of this.planets.values()) {
			arr.push(i);
		}
		return {gid: this.gid, planets : arr};
	}
	newPlanet(chat_id) {
		this.gid += 1;
		let p = new NPCPlanet(this.gid, chat_id);
		p.generate();
		this.planets.set(this.gid, p);
		return p;
	}
	getPlanet(id) {
		return this.planets.get(id);
	}
	forgetPlanet(id) {
		this.planets.delete(id);
	}
	fix() {
		for (var [key, value] of this.planets) {
			value.ships.battle_id = 0;
		}
	}
}
