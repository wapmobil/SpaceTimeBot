include("ships2.qs")

class Navy {
	constructor(id) {
		this.chat_id = id;
		this.arrived = 0;
		this.dst = 0;
		this.type = 0; // 0 - торговля, 1 - атака, 2 - исследование, 3 - ожидание, 4 - помощь/доставка
		this.aim = 0; // id заявки для торговли
		this.battle_id = 0;
		for (let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
		this.money = 0;
		this.m = ShipModels();
	}
	info(desc, inf) {
		let msg = `<b>*** ${desc} ***</b>\n`;
		if (inf) msg += inf + "\n";
		msg += `  Энергия: ${Math.round(this.energy())}🔋\n`;
		msg += `  Груз: ${this.totalResources()}/${this.capacity()}📦\n`;
		for (let i=0; i<Resources.length; i++) {
			if (this.resourceCount(i) > 0) msg += "  " + getResourceInfo(i, this.resourceCount(i)) + "\n";
		}
		if (this.money > 0) msg += `  Деньги: ${money2text(this.money)}\n`;
		for (const value of this.m) {
			if (value.count > 0) msg += value.info(false);
		}
		return msg + "\n";
	}
	infoBattle(bt) {
		let arr = [];
		for (let j=0; j<this.m.length; j++) {
			if (this.m[j].count > 0) {
				arr.push(this.m[j].infoBattle(bt));
			} else arr.push("");
		}
		return arr;
	}
	battleList() {
		let arr = [];
		for (let j=0; j<this.m.length; j++) {
			if (this.m[j].count > 0 && !this.m[j].peaceful()) {
				arr.push(0);
			} else arr.push(-1);
		}
		return arr;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == "m") {
				for (var i=0; i<Math.min(this.m.length, value.length); i++) this.m[i].load(value[i]);
			} else {
				this[key] = value;
			}
		}
	}
	buttons(scr, all) {
		let b = [];
		for (let j=0; j<this.m.length; j++) {
			if (this.m[j].count > 0 || all) {
				b.push([{button: `-10`, data: `${j} -10`, script: scr},
						{button: `${this.m[j].shortName()} -1`, data: `${j} -1`, script: scr},
						{button: `${this.m[j].shortName()} +1`, data: `${j} +1`, script: scr},
						{button: `+10`, data: `${j} +10`, script: scr}]);
			}
		}
		return b;
	}
	add(index, cnt) {
		this.m[index].count += cnt;
	}
	remove(index, cnt) {
		this.m[index].count -= cnt;
		if (this.m[index].count < 0) {
			this.m[index].count = 0;
			return false;
		}
		return true;
	}
	count(index) {
		return this.m[index].count;
	}
	countAll() {
		let cnt = 0;
		for (let j=0; j<this.m.length; j++) cnt += this.m[j].count;
		return cnt;
	}
	size() {
		let cnt = 0;
		for (let j=0; j<this.m.length; j++) cnt += this.m[j].count * this.m[j].size();
		return cnt;
	}
	check(nv) {
		for (let j=0; j<this.m.length; j++) {
			if (this.m[j].count < nv.m[j].count) return false;
		}
		return true;
	}
	split(nv) {
		for (let j=0; j<this.m.length; j++) {
			this.m[j].count -= nv.m[j].count;
		}
	}
	join(nv) {
		for (let j=0; j<this.m.length; j++) {
			this.m[j].count += nv.m[j].count;
		}
		for (let i=0; i<Resources.length; i++) {
			this[Resources[i].name] += nv[Resources[i].name];
		}
		this.money += nv.money;
	}
	capacity() {
		let cap = 0;
		for (const value of this.m) cap += value.capacity()*value.count;
		return cap;
	}
	freeStorage() {
		return this.capacity() - this.totalResources();
	}
	energy() {
		let e = 0;
		for (const value of this.m) e += value.energy()*value.count;
		if (this.type == 2) e = e * this.arrived / 360;
		return e;
	}
	resourceCount(res) {
		return this[Resources[res].name];
	}
	totalResources() {
		let total_res = 0;
		for(let i=0; i<Resources.length; i++) total_res += this[Resources[i].name];
		return total_res;
	}
	peaceful() {
		let ps = 0;
		for (const value of this.m) {
			if (value.peaceful()) ps += value.count;
		}
		return this.countAll() == ps ? true : false;
	}
	damage(hit, max_dmg) {
		let dmg = 0;
		for (const value of this.m) dmg += value.damage();
		return Math.min(hit*dmg, max_dmg);
	}
	maxDefeat(hit, sz) {
		let h = 0;
		for (const value of this.m) h += value.cur_health()+value.count*value.armor();
		return Math.floor(h*hit/Math.max(sz,1));
	}
	applyDamage(dmg) {
		let h = 0;
		let msg = "";
		for (const value of this.m) h += value.cur_health();
		for (const value of this.m) {
			if (value.count == 0) continue;
			let cd = Math.round(dmg*value.cur_health()/h);
			let killed = 0;
			while (cd > 0) {
				let cdam = Math.min(cd, value.hp + value.armor());
				cd -= cdam;
				cdam = Math.max(0, cdam - value.armor());
				value.hp -= cdam;
				if (value.hp <= 0) {
					value.count--;
					killed++;
					if (value.count <= 0) {
						value.count = 0;
						break;
					}
					value.hp = value.health();
				}
			}
			//print("убито", killed, value.name());
			if (killed > 0) msg += `убито ${killed} ${value.name()}\n`;
		}
		return msg;
	}
}
