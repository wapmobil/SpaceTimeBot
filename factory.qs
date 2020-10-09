include("building.qs")

class Factory extends Building {
	name() {return "🏭Завод";}
	icon() {return "🏭";}
	description() {return `Производит ${Resources[this.type].icon}${Resources[this.type].desc} - один из ресурсов для постройки кораблей, требует ⚡ для работы`;}
	cost() {
		return (this.level*2+1)*100000;
	}
	info() {
		let msg = this.infoHeader()+"\n";
		if (this.level > 0) msg += `    Доход +1${Resources[this.type].icon} за ${time2text(this.incomingTime(this.level))}\n`;
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
		if (isProduction) return 10000;
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
	buildTimeAdd() {return 1000;}
}
