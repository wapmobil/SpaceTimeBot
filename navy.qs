include("ships.qs")

class Navy {
	constructor(id) {
		this.chat_id = id;
		this.arrived = 0;
		this.dst = 0;
		this.m = new Array();
		this.m.push(new TradeShip());
	}
	info(detail) {
		let msg = "<b>*** Флот ***</b>\n";
		let cap = 0;
		let energy = 0;
		for (const value of this.m) {
			cap += value.capacity()*value.count;
			energy += value.energy()*value.count;
		}
		msg += `  вместимость: ${cap}📦\n`;
		msg += `  энергия пуска: ${energy}🔋\n`;
		for (const value of this.m) msg += value.info(false);
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
}
