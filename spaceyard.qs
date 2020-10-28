include("building.qs")

class Spaceyard extends Building {
	name() {return "🏗Верфь";}
	icon() {return "🏗";}
	description() {return "Открывает возможность строить космические корабли.";}
	cost() {
		return Math.pow(7, (this.level+7));
	}
	info() {
		let msg = this.infoHeader()+"\n";
		msg += `    🛠${this.level+1} `;
		return msg + this.infoFooter();
		return msg;
	}
	consumption() {return 16;}
	buildTimeAdd() {return 3000;}
	shipsBuildSpeed(l) {return l;}
}
