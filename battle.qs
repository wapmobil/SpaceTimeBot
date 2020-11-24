include("navy.qs")

class Battle {
	constructor(nv1, nv2) {
		this.nv1 = nv1;
		this.nv2 = nv2;
		this.lastAction = "";
		this.mode = -99;
		this.cur_id = this.nv1.chat_id;
		this.list = this.nv1.battleList();
		this.msg_id1 = 0;
		this.msg_id2 = 0;
		this.round = 0;
		if (this.nv1.chat_id == 1) this.msg_id1 = 1;
		if (this.nv2.chat_id == 1) this.msg_id2 = 1;
	}
	info(chat_id) {
		if (chat_id == this.nv1.chat_id) {
			return this.infoBattle(this.nv1.infoBattle(), this.nv2.infoBattle(), this.cur_id == chat_id);
		}
		if (chat_id == this.nv2.chat_id) {
			return this.infoBattle(this.nv2.infoBattle(), this.nv1.infoBattle(), this.cur_id == chat_id);
		}
	}
	infoBattle(a1, a2, your) {
		let msg = "Битва: \n";
		const n1 = a1.filter(word => word.length > 0);
		const n2 = a2.filter(word => word.length > 0);
		const sz = Math.max(n1.length, n2.length);
		for(let j=0; j<sz; j++) {
			msg += "<code>"
			if (n1.length > j) msg += "🟢"+n1[j];
			else msg += "⚪️------------";
			msg += "⏹  ";
			if (n2.length > j) msg += "🟠"+n2[j];
			else msg += "⚪️------------";
			msg += "</code>\n\n";
		}
		msg += this.lastAction + "\n";
		if (your) {
			if (this.mode == -99) msg += "Ты ходишь первым";
			else if (this.mode < 0) msg += "Выбери отряд";
			else if (this.mode >= 0) msg += "Выбери действие";
		} else msg += "Ждём ход противника...";
		return msg;
	}
	buttons(chat_id) {
		if (this.mode == -99) return [{button: "Начать сражение!", script: "battle_start", data: 0}];
		let a = [];
		let bt = [];
		if (chat_id != this.cur_id) return bt;
		if (this.cur_id == this.nv1.chat_id) {
			if (this.mode < 0) a = this.nv1.infoBattle(true);
			if (this.mode >= 0) a = this.nv2.infoBattle(true);
		}
		if (this.cur_id == this.nv2.chat_id) {
			if (this.mode < 0) a = this.nv2.infoBattle(true);
			if (this.mode >= 0) a = this.nv1.infoBattle(true);
		}
		for(let j=0; j<a.length; j++) { 
			//print("=== ", a[j].length);
			if (a[j].length == 0) continue;
			if (this.mode < 0) {
				if (this.list[j] == 0)
					bt.push({button: a[j], script: "battle_step", data: j});
			} else {
				bt.push({button: `атаковать ${a[j]}`, script: "battle_step", data: j});
			}
		}
		if (this.mode >= 0 && chat_id > 1) {
			bt.push({button: "защищаться", script: "battle_step", data: "skip"});
			bt.push({button: "назад к выбору отряда", script: "battle_step", data: "back"});
		}
		return bt;
	}
	start(chat_id, msg_id) {
		if (chat_id == this.nv1.chat_id) this.msg_id1 = msg_id;
		if (chat_id == this.nv2.chat_id) this.msg_id2 = msg_id;
		if (this.msg_id1 > 0 && this.msg_id2 > 0) this.mode = -1;
	}
	step(chat_id, data) {
		if (chat_id != this.cur_id) return;
		if (this.mode >= 0) {
			if (data == "skip") {
				this.list[this.mode] = 1;
			} else if (data != "back") {
				const oi = parseInt(data);
				let sz = 0;
				if (this.cur_id == this.nv1.chat_id) sz = this.nv2.m.length
				else sz = this.nv1.m.length
				if (oi >=0 && oi < sz) {
					this.list[this.mode] = 1;
					if (this.cur_id == this.nv1.chat_id) {
						this.attack(this.nv1.m[this.mode], this.nv2.m[oi]);
					} else {
						this.attack(this.nv2.m[this.mode], this.nv1.m[oi]);
					}
					if (!this.nv2.battleList().some(e => e == 0)) {this.finish(1); return;}
					if (!this.nv1.battleList().some(e => e == 0)) {this.finish(2); return;}
				} else print(oi, sz);
			}
			this.mode = -1;
			if (!this.list.some(e => e == 0)) {
				if (this.cur_id == this.nv1.chat_id) {
					this.cur_id = this.nv2.chat_id;
					this.list = this.nv2.battleList();
				} else {
					this.cur_id = this.nv1.chat_id;
					this.list = this.nv1.battleList();
				}
			}
		} else {
			const oi = parseInt(data);
			let sz = 0;
			if (this.cur_id == this.nv1.chat_id) sz = this.nv1.m.length
			else sz = this.nv2.m.length
			if (oi >=0 && oi < sz) this.mode = oi;
		}
		if (this.nv1.chat_id > 1)
			Telegram.edit(this.nv1.chat_id, this.msg_id1, this.info(this.nv1.chat_id), this.buttons(this.nv1.chat_id));
		if (this.nv2.chat_id > 1)
			Telegram.edit(this.nv2.chat_id, this.msg_id2, this.info(this.nv2.chat_id), this.buttons(this.nv2.chat_id));
	}
	finish(side) {
		print("finish");
		let msg = this.lastAction + "\n<b>Сражение завершено</b>\n";
		let msg1 = msg + "<b>Вы победили</b>😀\n";
		let msg2 = msg + "<b>Вы проиграли</b>😒\n"; 
		if (side == 1) {
			msg1 += this.nv1.info("Оставшиеся корабли");
			if (this.nv1.chat_id > 1)
				Telegram.edit(this.nv1.chat_id, this.msg_id1, msg1);
			if (this.nv2.chat_id > 1)
				Telegram.edit(this.nv2.chat_id, this.msg_id2, msg2);
		}
		if (side == 2) {
			msg1 += this.nv2.info("Оставшиеся корабли");
			if (this.nv1.chat_id > 1)
				Telegram.edit(this.nv1.chat_id, this.msg_id1, msg2);
			if (this.nv2.chat_id > 1)
				Telegram.edit(this.nv2.chat_id, this.msg_id2, msg1);
		}
	}
	attack(s1, s2) {
		let res_1_hit_2 = s1.hitTo(s2);
		let res_2_hit_1 = s2.hitTo(s1);
		this.lastAction = `${res_1_hit_2.msg}\n${res_2_hit_1.msg}\n${res_1_hit_2.msgf}${res_2_hit_1.msgf}\n`;
		s2.applyHit(res_1_hit_2);
		s1.applyHit(res_2_hit_1);
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
	stepNPC() {
		for (var [key, value] of this.b) {
			if (value.cur_id == 1) {
				const bts = value.buttons(1);
				value.step(1, bts[getRandom(bts.length)].data);
			}
		}
	}
}












