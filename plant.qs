include("building.qs")
// Шахта
class Plant extends Building {
	name() {
		return "⛏Шахта";
	}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Доход +${this.level}💰\n`;
		msg += `    🛠${this.level+1}:  доход +${this.level+1}💰 `;
		return msg + this.infoFooter();
	}
	consumption() {
		return 10;
	}
}
