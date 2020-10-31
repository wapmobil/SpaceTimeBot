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
		msg += `    производительность ${this.shipsBuildSpeed(this.level)}x\n`;
		msg += `    🛠${this.level+1}: производительность ${this.shipsBuildSpeed(this.level+1)}x`;
		return msg + this.infoFooter();
	}
	consumption() {return 16;}
	buildTimeAdd() {return 3000;}
	shipsBuildSpeed(l) {return l;}
	buildShip() {
		if (this.ship_id >=0 && this.ship_bt > 0) {
			this.ship_bt -= this.shipsBuildSpeed(this.level);
			if (this.ship_bt <= 0) {
				return this.ship_id;
			}
		}
		return -1;
	}
}
