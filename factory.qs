include("building.qs")

class Factory extends Building {
	name() {
		return "🏭Завод";
	}
	cost() {
		return (this.level*2+1)*1000000;
	}
	info() {
		let msg = this.infoHeader();
		const p = "";
		
		msg += `    Доход +1${Resources[this.type].icon} за ${time2text(this.incomingTime(this.level))}\n`;
		msg += `    🛠${this.level+1}:  доход +1${Resources[this.type].icon} за ${time2text(this.incomingTime(this.level+1))}`;
		return msg + this.infoFooter();
	}
	consumption() {
		return 25;
	}
	productivity(l) {
		if (l > 0) return 10 + l;
		else return 0;
	}
	incomingTime(l) {
		if (l > 0)
			return Math.floor(this.period()/this.productivity(l));
		else return 0;
	}
	period() {
		if (isProduction) return 6000;
		else return 60;
	}
	product() {
		if (this.level > 0) {
			this.prod_cnt += this.productivity(this.level);
			if (this.prod_cnt >= this.period()) {
				this.prod_cnt = 0;
				return 1;
			}
		}
		return 0;
	}
}
