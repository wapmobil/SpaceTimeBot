include("ships.qs")

class Navy {
	constructor(id) {
		this.chat_id = id;
		this.arrived = 0;
		this.dst = 0;
		this.type = 0; // 0 - торговля, 1 - атака
		this.aim = 0; // id заявки для торговли
		for(let i=0; i<Resources.length; i++)
			this[Resources[i].name] = 0;
		this.money = 0;
		this.m = new Array();
		this.m.push(new TradeShip());
	}
	info(desc) {
		let msg = `<b>*** ${desc} ***</b>\n`;
		msg += `  Энергия пуска: ${this.energy()}🔋\n`;
		msg += `  Груз: ${this.totalResources()}/${this.capacity()}📦\n`;
		for(let i=0; i<Resources.length; i++) {
			msg += getResourceInfo(i, this.resourceCount(i)) + "\n";
		}
		msg += `  Деньги: ${money2text(this.money)}\n`
		for (const value of this.m) {
			if (value.count > 0) msg += value.info(false);
		}
		return msg;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == "m") {
				for (var i=0; i<this.m.length; i++) this.m[i].load(value[i]);
			} else {
				this[key] = value;
			}
		}
	}
	buttons() {
		let b = [];
		for (const v of this.m) {
			if (v.count > 0) {
				b.push(`${v.name()} -1`);
				b.push(`${v.name()} +1`);
			}
		}
		return b;
	}
	indexes() {
		let b = [];
		for(let j=0; j<this.m.length; j++) {
			if (this.m[j].count > 0) {
				b.push([j, -1]);
				b.push([j, +1]);
			}
		}
		return b;
	}
	add(index, cnt) {
		this.m[index].count += cnt;
	}
	remove(index, cnt) {
		this.m[index].count -= cnt;
		if (this.m[index] < 0) {
			this.m[index].count = 0;
			return false;
		}
		return true;
	}
	count(index) {
		return this.m[index].count;
	}
	split(nv) {
		for(let j=0; j<this.m.length; j++) {
			this.m[j].count -= nv.m[j].count;
		}
	}
	join(nv) {
		for(let j=0; j<this.m.length; j++) {
			this.m[j].count += nv.m[j].count;
		}
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
}
