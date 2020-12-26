include("building.qs")

class Comcenter extends Building {
	name() {return "🏪Командный центр";}
	icon() {return "🏪";}
	description() {
		let msg  = "Открывает высокотехнологичные исследования, требует ⚡ для работы.\n";
		return msg;
	}
	cost() {
		return 10000000 * this.level;
	}
	info() {
		let msg = this.infoHeader()+`\n`;
		msg += `    🛠${this.level+1}`;
		return msg + this.infoFooter();
	}
	consumption() {return 100;}
	buildTimeAdd() {return 10000;}
}
