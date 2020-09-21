include("building.qs")

class Spaceyard extends Building {
	name() {return "🏗Верфь";}
	icon() {return "🏗";}
	description() {return "Здесь можно будет строить космические корабли. В разработке....";}
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
		return 16;
	}
	buildTimeAdd() {return 3000;}
}
