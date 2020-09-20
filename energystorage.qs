include("building.qs")

class EnergyStorage extends Building {
	name() {
		return "🔋Аккумуляторы";
	}
	capacity(lvl) {
		return (lvl*1000);
	}
	cost() {
		return (Math.floor(Math.sqrt((this.level+1)*10)))*100000;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${this.capacity(this.level)}⚡\n`;
		msg += `    След. ур. ${this.level+1}:  вместимость ${this.capacity(this.level+1)}⚡ `;
		return msg + this.infoFooter();
	}
	consumption() {
		return 2;
	}
}