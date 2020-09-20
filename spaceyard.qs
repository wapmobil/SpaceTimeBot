include("building.qs")

class Spaceyard extends Building {
	name() {
		return "🏗Верфь";
	}
	cost() {
		return Math.pow(7, (this.level+7));
	}
	info() {
		let msg = this.infoHeader();
		msg += `    🛠${this.level+1} `;
		return msg + this.infoFooter();
		return msg;
	}
	consumption() {
		return 0;
	}
}
