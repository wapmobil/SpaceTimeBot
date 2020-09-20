include("building.qs")

class Solar extends Building {
	name() {
		return "⚡Электростанция";
	}
	cost() {
		return ((this.level*this.level*this.level+1)*100);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    энергия +${-this.level*this.consumption()}⚡\n`;
		msg += `    🛠${this.level+1}:  энергия +${-(this.level+1)*this.consumption()}⚡ `;
		return msg + this.infoFooter();
	}
	consumption() {
		return -15;
	}
}
