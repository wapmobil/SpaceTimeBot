// Базовый класс строения
class Building {
	name() {
		return "";
	}
	constructor(id){
		this.level = 0;
		this.build_progress = 0;
		this.chat_id = id;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object') {
				this[key].load(value);
			} else {
				this[key] = value;
			}
		}
	}
	step(bs) { // эта функция вызывается каждый timerDone
		if (this.build_progress > 0) {
			this.build_progress -= bs;
			//print(`build=${this.build_progress}`)
			if (this.build_progress <= 0) {
				this.level += 1;
				this.build_progress = 0;
				Telegram.send(this.chat_id, this.name() + " - строительство завершено");
			}
		}
	}
	build(money) {
		if (money >= this.cost()) {
			if (this.build_progress == 0) {
				money -= this.cost();
				this.build_progress = this.buildTime();
				Telegram.send(this.chat_id, "Строительство началось");
			} else {
				Telegram.send(this.chat_id, `Строительство ещё в процессе, осталось - ${this.build_progress}🛠`);
			}
		} else {
			Telegram.send(this.chat_id, "Недостаточно денег");
		}
		return money;
	}
	buildTime() {
		return Math.floor((this.level+2*Math.pow(Math.sin(this.level), 3))*100+10);
	}
	cost() {
		return 0;
	}
	isBuilding() {
		return this.build_progress != 0;
	}
	infoHeader() {
		return `${this.name()} ур. ${this.level}\n`;
	}
	infoFooter() {
		let msg = `(${this.cost()}💰 ${this.buildTime()}⏳)\n`;
		if (this.build_progress > 0) msg += `    Идёт 🛠строительство, осталось ${this.build_progress}⏳\n`;
		return msg;
	}
}
