// Базовый класс строения
class Building {
	constructor(id){
		this.level = 0;
		this.build_progress = 0;
		this.chat_id = id;
		this.locked = false;
	}
	name() {return "";}
	icon() {return "";}
	description() {return "";}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (typeof value == 'object' && !Array.isArray(value)) {
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
	build(food, energy) {
		if (this.locked) {
			Telegram.send(this.chat_id, "Необходимо исследование");
			return food;
		}
		if (energy < this.consumption() && this.consumption() > 0) {
			Telegram.send(this.chat_id, `Недостаточно ⚡электроэнергии,\n нужно больше электростанций (требуется ещё ${this.consumption() - energy}⚡)`);
			return food;
		}
		if (food < this.cost()) {
			Telegram.send(this.chat_id, "Недостаточно 🍍, необходимо ещё "+food2text(this.cost()-food));
			return food;
		}
		if (this.build_progress != 0) {
			Telegram.send(this.chat_id, `Строительство ещё в процессе, осталось ${time2text(this.build_progress)}`);
			return food;
		}
		food -= this.cost();
		this.build_progress = this.buildTime();
		Telegram.send(this.chat_id, "Строительство началось");
		return food;
	}
	buildTime() {
		return Math.floor((this.level+2*Math.pow(Math.sin(this.level), 3))*100+10) + this.buildTimeAdd();
	}
	cost() {
		return 0;
	}
	isBuilding() {
		return this.build_progress != 0;
	}
	infoHeader() {
		let z = this.consumption() > 0 ? `${this.consumption()*this.level}⚡️` : "";
		if (this.consumption() == 0 || this.level == 0) z = "";
		return `<b>${this.name()} ур. ${this.level}:</b> ${z}`;
	}
	infoFooter() {
		let z = this.consumption() > 0 ? `${this.consumption()}⚡️` : "";
		let msg = `\n    └Требуется: ${food2text(this.cost())} ${time2text(this.buildTime())} ${z}\n`;
		if (this.build_progress > 0) msg += `  ➡️Идёт 🛠строительство, осталось ${time2text(this.build_progress)}\n`;
		return msg;
	}
	consumption() {
		return 0;
	}
	buildTimeAdd() {return 0;}
}
