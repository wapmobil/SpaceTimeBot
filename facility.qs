// База
class Facility extends Building {
	name() {
		return "🏢База";
	}
	cost() {
		return Math.pow(10, (this.level+3));
	}
	info() {
		let msg = this.infoHeader();
		msg += `    След. ур. ${this.level+1} `;
		return msg + this.infoFooter();
		return msg;
	}
}
