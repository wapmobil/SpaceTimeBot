include("building.qs")

class Solar extends Building {
	name() {
		return "⚡Электростанция";
	}
	cost() {
		return ((this.level*this.level)*200+80);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    энергия ${-this.level*this.consumption()}⚡\n`;
		msg += `    🛠${this.level+1}:  энергия +${-this.consumption()}⚡ `;
		return msg + this.infoFooter();
	}
	consumption() {
		return -15;
	}
}
