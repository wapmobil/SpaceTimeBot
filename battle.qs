include("navy.qs")


function testCombat() {
	for (const s of ShipModels()) {
		print(s.name(), s.hp);
	}
	let sh = new CruiserShip(), sh2 = new InterceptorShip();
	sh.count = 1;
	sh2.count = 4;
	for (let z = 0; z < 10; ++z)
		sh.hitTo(sh2);
}


class Battle {
	constructor(nv1, nv2) {
		this.nv1 = nv1;
		this.nv2 = nv2;
		this.lastAction = "";
		this.mode = 0;
	}
	info(chat_id) {
		if (chat_id == this.nv1.chat_id) {
			const a1 = this.nv1.infoBattle();
			const a2 = this.nv2.infoBattle();
			return this.infoBattle(a1, a2);
		}
		if (chat_id == this.nv2.chat_id) {
			const a1 = this.nv2.infoBattle();
			const a2 = this.nv1.infoBattle();
			return this.infoBattle(a1, a2);
		}
	}
	infoBattle(a1, a2) {
		let msg = "Битва: \n";
		const sz = Math.max(a1.length, a2.length);
		for(let j=0; j<sz; j++) {
			msg += "<code>"
			if (a1.length > j) msg += "🟢"+a1[j];
			else msg += "⚪️------------";
			msg += "⏹  ";
			if (a2.length > j) msg += "🟠"+a2[j];
			else msg += "⚪️------------";
			msg += "</code>\n\n";
		}
		msg += this.lastAction + "\n";
		switch(this.mode) {
			case 0: msg += "Выбери отряд"; break;
			case 1: msg += "Выбери действие"; break;
			case 2: msg += "Выбери противника"; break;
		}
		return msg;
	}
	buttons(chat_id) {
		let a = [];
		let bt = [];
		if (chat_id == this.nv1.chat_id) {
			a = this.nv1.infoBattle(true);
		}
		if (chat_id == this.nv2.chat_id) {
			a = this.nv2.infoBattle(true);
		}
		for(let j=0; j<a.length; j++) {
			bt.push({button: a[j], script: "battle_step", data: `${j},0`});
		}
		return bt;
	}
}


class BattleList {
	constructor() {
		this.gid = 1;
		this.b = new Map();
	}
	addBattle(bt) {
		this.gid += 1;
		this.b.set(this.gid, bt);
		return this.gid;
	}
}
