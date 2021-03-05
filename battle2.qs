include("navy2.qs")

const battle_timeout = 60;
const battle_mapsize = 11;
const battle_maxnvsize = 9;
const battle_layouts = {
	left : {i: 0, desc : "на лево"},
	right : {i: 1, desc : "на право"},
	backward : {i: 2, desc : "позади"},
	front : {i: 3, desc : "спереди"},
	center : {i: 4, desc : "в центр"},
	flang : {i: 5, desc : "по флангам"},
	};

const battle_attacks = {
	left : {i: 0, desc : "лево"},
	right : {i: 1, desc : "право"},
	back : {i: 2, desc : "зад"},
	front : {i: 3, desc : "перед"},
	center : {i: 4, desc : "центр"},
	};

class BattlePlayer {
	constructor(nv) {
		this.msg_id = 0;
		this.nv = nv;
		this.move = 2;
		this.attack = 2;
		this.step = 0;
		if (nv.chat_id == 1) this.msg_id = 1;
	}
	
	chat_id() {return this.nv.chat_id;}
}

class Battle {
	constructor(nv1, nv2) {
		this.players = [];
		this.players.push(new BattlePlayer(nv1));
		this.players.push(new BattlePlayer(nv2));
		this.lastAction = "";
		this.log = "";
		this.mode = -2;
		this.cp = 0;
		this.round = 0;
		this.timeout = 0;
	}
	
	setID(id) {this.players.forEach(p => p.nv.battle_id = id);}
	
	curPlayer() {return this.players[this.cp];}
	
	updateMsg(chat_id, msg_id) {
		this.players.forEach(p => {if (chat_id == p.chat_id()) p.msg_id = msg_id});
	}
	
	info(chat_id) {
		const n1 = this.players[0].nv.infoBattle().filter(word => word.length > 0);
		const n2 = this.players[1].nv.infoBattle().filter(word => word.length > 0);
		let msg = "<b>Сражение:";
		if (this.round > 0) msg += ` ${this.round} раунд`;
		msg += "</b>\n\n";
		let map = new Array(battle_mapsize * battle_mapsize * 2);
		map.fill("✖️");
		const cur_id = this.curPlayer().chat_id();
		this.players.forEach(p => {
			if (cur_id == chat_id || chat_id == p.chat_id())
				this.movePrint(map,
						Math.min(Math.ceil(p.nv.size()/10), battle_maxnvsize),
						chat_id == p.chat_id(), p.move);
			});

		msg += "Противник:\n"
		if (chat_id != this.players[0].chat_id()) msg += n1.join("\n");
		else msg += n2.join("\n");
		msg += "\n";
		for(let i=0; i<battle_mapsize*2; i++) {
			for(let j=0; j<battle_mapsize; j++) {
				msg += map[i*battle_mapsize+j];
			}
			msg += "\n";
		}
		msg += "Ты:\n"
		if (chat_id == this.players[0].chat_id()) msg += n1.join("\n");
		else msg += n2.join("\n");
		msg += "\n";
		/*const sz = Math.max(n1.length, n2.length);
		for(let j=0; j<sz; j++) {
			msg += "<code>"
			if (n1.length > j) msg += "🟢"+n1[j];
			else msg += "⚪️------------";
			//msg += "⏹  ";
			if (n2.length > j) msg += "🟠"+n2[j];
			else msg += "⚪️------------";
			msg += "</code>\n\n";
		}*/
		msg += this.lastAction + "\n";
		if (cur_id == chat_id) {
			//if (this.mode == -2) msg += "Ты ходишь первым";
//			if (this.mode == -1) msg += "Выбери отряд";
			//if (this.mode == -1) 
			msg += "Твой ход";
		} else msg += "Ждём ход противника...";
		return msg;
	}
	
	movePrint(map, sz, you, move) {
		//print(you, sz);
		switch(move) {
			case battle_layouts.left.i : this.layoutSide(map, sz, you, true); break;
			case battle_layouts.right.i : this.layoutSide(map, sz, you, false); break;
			case battle_layouts.backward.i : this.layoutBack(map, sz, you); break;
			case battle_layouts.front.i : this.layoutFront(map, sz, you); break;
			case battle_layouts.center.i : this.layoutCenter(map, sz, you); break;
			case battle_layouts.flang.i : this.layoutFlang(map, sz, you); break;
		}
	}
	
	layoutBack(map, sz, you) {
		const st = you ? battle_mapsize*2-1 : 0; 
		const ex = you ? i => i>battle_mapsize : i => i<battle_mapsize; 
		const s = you ? "🟢" : "🔴";
		for(let i=st; ex(i) && sz>0; you ? i-- : i++) {
			for(let j=0; j<battle_mapsize/2; j++) {
				map[i*battle_mapsize+Math.floor(battle_mapsize/2)+j] = s;
				sz--;
				if(sz == 0) break;
				if (j == 0) continue;
				map[i*battle_mapsize+Math.floor(battle_mapsize/2)-j] = s;
				sz--;
				if(sz == 0) break;
			}
		}
	}
	
	layoutFront(map, sz, you) {
		const st = you ? battle_mapsize : battle_mapsize-1; 
		const ex = you ? i => i<battle_mapsize*2 : i => i>=0; 
		const s = you ? "🟢" : "🔴";
		for(let i=st; ex(i) && sz>0; you ? i++ : i--) {
			for(let j=0; j<battle_mapsize/2; j++) {
				map[i*battle_mapsize+Math.floor(battle_mapsize/2)+j] = s;
				sz--;
				if(sz == 0) break;
				if (j == 0) continue;
				map[i*battle_mapsize+Math.floor(battle_mapsize/2)-j] = s;
				sz--;
				if(sz == 0) break;
			}
		}
	}
	
	layoutSide(map, sz, you, side) {
		const st = you ? battle_mapsize*2-1 : 0;
		const lr = you ? side : !side;
		const st2 = lr ? 0 : battle_mapsize-1; 
		const ex = you ? i => i>=battle_mapsize : i => i<battle_mapsize; 
		const ex2 = lr ? i => i<battle_mapsize : i => i>=0; 
		const s = you ? "🟢" : "🔴";
		for(let j=st2; ex2(j) && sz>0; lr ? j++ : j--) {
			for(let i=st; ex(i) && sz>0; you ? i-- : i++) {
				map[i*battle_mapsize+j] = s;
				sz--;
			}
		}
	}
	
	layoutCenter(map, sz, you) {
		const st = you ? battle_mapsize : 0;
		const s = you ? "🟢" : "🔴";
		const ind1 = i => (st+Math.floor(battle_mapsize/2)-i)
		const ind2 = i => (st+Math.floor(battle_mapsize/2)+i)
		for(let j=0; j<battle_mapsize/2 && sz>0; j++) {
			for(let i=0; i<battle_mapsize/2 && sz>0; i++) {
				map[ind1(i)*battle_mapsize+j+Math.floor(battle_mapsize/2)] = s;
				sz--;
				if(sz == 0) break;
				if (i != 0) {
					map[ind2(i)*battle_mapsize+j+Math.floor(battle_mapsize/2)] = s;
					sz--;
				}
				if(sz == 0) break;
				if (j == 0) continue;
				map[ind1(i)*battle_mapsize-j+Math.floor(battle_mapsize/2)] = s;
				sz--;
				if(sz == 0) break;
				if (i == 0) continue;
				map[ind2(i)*battle_mapsize-j+Math.floor(battle_mapsize/2)] = s;
				sz--;
				if(sz == 0) break;
			}
		}
	}

	layoutFlang(map, sz, you) {
		const st = you ? battle_mapsize : battle_mapsize-1; 
		const ex = you ? i => i<battle_mapsize*2 : i => i>=0;
		const s = you ? "🟢" : "🔴";
		for(let j=0; j<battle_mapsize/2 && sz>0; j++) {
			for(let i=st; ex(i) && sz>0; you ? i++ : i--) {
				map[i*battle_mapsize+j] = s;
				sz--;
				if(sz == 0) break;
				if (j == Math.floor(battle_mapsize/2)) continue;
				map[i*battle_mapsize+battle_mapsize-j-1] = s;
				sz--;
				if(sz == 0) break;
			}
		}
	}
		
	buttons(chat_id, cont) {
		if (this.mode == -2) return [{button: "Начать сражение!", script: "battle_start", data: `${this.players[0].nv.battle_id} 0`}, {button: "сбежать", script: "battle_start", data: `${this.players[0].nv.battle_id} 1`}];
		if (cont) return [{button: "Продолжить сражение!", script: "battle_start", data: `${this.players[0].nv.battle_id} 0`}, {button: "сбежать", script: "battle_start", data: `${this.players[0].nv.battle_id} 1`}];
		let a = [];
		let bt = [];
		if (chat_id != this.curPlayer().chat_id()) return bt;
		const rows = 2;
		bt.push([]);
		let i = 0;
		let n = 0;
		let xx = Object.entries(battle_layouts);
		if (this.curPlayer().step == 1) xx = Object.entries(battle_attacks);
		for (const [key, value] of xx) {
			bt[n].push({button: `${value.desc}`, script: "battle_step", data: `${this.curPlayer().nv.battle_id} ${value.i}`});
			i++; if (i == rows) {i = 0; n++; bt.push([]);}
		}
		if (this.mode >= 0 && chat_id > 1 && this.timeout < battle_timeout) {
			//bt.push({button: "защищаться", script: "battle_step", data: `${this.players[0].nv.battle_id} skip`});
			//bt.push({button: "назад к выбору отряда", script: "battle_step", data: `${this.players[0].nv.battle_id} back`});
			bt.push({button: "сбежать", script: "battle_start", data: `${this.curPlayer().nv.battle_id} 1`});
		}
		return bt;
	}
	start(chat_id, msg_id) {
		this.updateMsg(chat_id, msg_id);
		const ready = this.players.every(p => p.msg_id > 0);
		if (ready && this.mode == -2) {
			this.newRound();
		}
	}
	step(chat_id, data) {
		const cur_id = this.curPlayer().chat_id();
		if (chat_id != cur_id) return;
		this.timeout = 0;
		this.lastAction = "";
		const oi = parseInt(data);
		switch (this.curPlayer().step) {
			case 0: this.curPlayer().move = oi;
			case 1: this.curPlayer().attack = oi;
		}
		this.curPlayer().step++;
		if (this.curPlayer().step == 2) this.cp++;
		if (this.cp == this.players.length) this.newRound();
		this.players.forEach(p => { if (p.chat_id() > 1)
				Telegram.edit(p.chat_id(),
				 p.msg_id,
				 this.info(p.chat_id()),
				 this.buttons(p.chat_id()));
			}
		);
	}
	checkFinish() {
		if (!this.players[1].nv.battleList().some(e => e == 0)) {this.finish(1); return true;}
		if (!this.players[0].nv.battleList().some(e => e == 0)) {this.finish(2); return true;}
		return false;
	}
	newRound() {
		//print("new round");
		this.mode = -1;
		this.cp = 0;
		this.round++;
		//this.lastAction += `<b>Начался раунд ${this.round}</b>\n`;
		Statistica.battle_rounds++;
	}
	finish(side) {
		//print("finish");
		this.timeout = 0;
		let msg = this.log + "\n<b>Сражение завершено</b>\n";
		msg += "Прошло раундов: "+this.round+"\n";
		let msg1 = msg + "<b>Вы победили</b>😀\n";
		let msg2 = msg + "<b>Вы проиграли</b>😒\n"; 
		if (side == 1) {
			Statistica.battle_win++;
			this.players[0].nv.money += this.players[1].nv.money;
			this.players[1].nv.money = 0;
			msg1 += this.players[0].nv.info("Оставшиеся корабли");
			if (this.players[0].nv.chat_id > 1)
				Telegram.edit(this.players[0].chat_id(), this.players[0].msg_id, msg1);
			if (this.players[1].nv.chat_id > 1)
				Telegram.edit(this.players[1].chat_id(), this.players[1].msg_id, msg2);
		}
		if (side == 2) {
			Statistica.battle_lose++;
			this.players[1].nv.money += this.players[0].nv.money;
			this.players[0].nv.money = 0;
			msg1 += this.players[1].nv.info("Оставшиеся корабли");
			if (this.players[0].nv.chat_id > 1)
				Telegram.edit(this.players[0].chat_id(), this.players[0].msg_id, msg2);
			if (this.players[1].nv.chat_id > 1)
				Telegram.edit(this.players[1].chat_id(), this.players[1].msg_id, msg1);
		}
		this.players[0].nv.battle_id = 0;
		this.players[1].nv.battle_id = 0;
		this.mode = -3;
	}
	attack(s1, s2, npc_id) {
		let res_1_hit_2 = s1.hitTo(s2);
		let res_2_hit_1 = s2.hitTo(s1);
		//this.lastAction = `${res_1_hit_2.msg}\n${res_1_hit_2.msgf}\n`;
		this.lastAction = `${res_1_hit_2.msg}\n${res_2_hit_1.msg}\n${res_1_hit_2.msgf}${res_2_hit_1.msgf}\n`;
		this.log += this.lastAction;
//		/print(npc_id);
		if (npc_id > 0) {
			let npc = GlobalNPCPlanets.getPlanet(npc_id);
			//print(res_1_hit_2.parts, res_2_hit_1.parts);
			if (res_1_hit_2.parts > 0) {
				if (res_1_hit_2.enemy) npc.ino_tech += res_1_hit_2.parts;
				else {
					for(let i=0; i<Resources_base; i++) npc[Resources[i].name] += res_1_hit_2.parts;
				}
			}
			if (res_2_hit_1.parts > 0) {
				if (res_2_hit_1.enemy) npc.ino_tech += res_2_hit_1.parts;
				else {
					for(let i=0; i<Resources_base; i++) npc[Resources[i].name] += res_2_hit_1.parts;
				}
			}
		}
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
		StatisticaDay.battles_day++;
		this.gid += 1;
		this.b.set(this.gid, bt);
		bt.setID(this.gid);
		return this.gid;
	}
	stepNPC() {
		//print("...", this.b.size);
		let del = [];
		for (var [key, value] of this.b) {
			//print("battle", this.cur_id, this.msg_id1, this. msg_id2);
			if (value.cur_id == 1 || value.timeout > battle_timeout) {
				const bts = value.buttons(value.cur_id).reduce((acc, val) => acc.concat(val), []);
				let rb = getRandom(bts.length);
				if (rb >= bts.length) rb = bts.length -1;
				if (rb < 0) print("invalid battle buttons", bts);
				//print("step", value.cur_id, bts.length, rb);
				value.step(value.cur_id, bts[rb].data.split(" ")[1]);
			}
			if (value.mode == -3) del.push(key);
			if (value.mode >= -1) value.timeout++;
			//print(value.timeout);
		}
		for (var k of del) this.b.delete(k);
	}
}












