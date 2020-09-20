include("building.qs")
// Шахта
class Factory extends Building {
	name() {
		return "🏭Завод";
	}
	cost() {
		return (this.level+1)*2000000;
	}
	info() {
		let msg = this.infoHeader();
		//msg += `    Доход +${this.level}💰\n`;
		//msg += `    🛠${this.level+1}:  доход +${this.level+1}💰 `;
		return msg + this.infoFooter();
	}
	consumption() {
		return 25;
	}
}
