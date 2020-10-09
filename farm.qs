include("building.qs")

class Farm extends Building {
	name() {return "🍍Ферма";}
	icon() {return "🍍";}
	description() {return "Производит 🍍 - основной ресурс для строительства зданий, требует ⚡ для работы";}
	cost() {
		return (this.level*this.level*this.level*20 + 100);
	}
	info() {
		let msg = this.infoHeader()+"\n";
		msg += `    Доход ${food2text(this.level)}\n`;
		msg += `    🛠${this.level+1}:  доход ${food2text(this.level+1)}(+1🍍) `;
		return msg + this.infoFooter();
	}
	consumption() {return 10;}
}
