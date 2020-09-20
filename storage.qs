include("building.qs")

class Storage extends Building {
	name() {
		return "📦Хранилище";
	}
	capacity(lvl) {
		return (Math.pow(2, lvl)*1000);
	}
	cost() {
		return (this.level*this.level+1)*100;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${this.capacity(this.level)}💰\n`;
		msg += `    🛠${this.level+1}:  вместимость ${this.capacity(this.level+1)}💰 `;
		return msg + this.infoFooter();
	}
	consumption() {
		return 2;
	}
}
