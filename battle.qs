include("navy.qs")

class Crew {
	constructor(nv) {
		this.ships = nv;
	}
}

class Battle {
	constructor(nv1, nv2) {
		this.nv1 = nv1;
		this.nv2 = nv2;
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
			msg += "⚔️ ";
			if (a2.length > j) msg += "🟠"+a2[j];
			else msg += "⚪️------------";
			msg += "</code>\n";
		}
		return msg;
	}
}


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
