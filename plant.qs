include("building.qs")

class Plant extends Building {
	name() {return "⛏Шахта";}
	icon() {return "⛏";}
	description() {return "Производит 💰 - основной ресурс, требует ⚡ для работы";}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Доход +${money2text(this.level)}\n`;
		msg += `    🛠${this.level+1}:  доход +${money2text(this.level+1)} `;
		return msg + this.infoFooter();
	}
	consumption() {return 10;}
}
