include("building.qs")

class Storage extends Building {
	name() {return "📦Хранилище";}
	icon() {return "📦";}
	description() {return "Обеспечивает хранение 💰, если достигнут максимум вместимости, то дальнейшее накопление 💰 прекращается";}
	capacity(lvl) {
		if (lvl < 10) return (Math.pow(2, lvl)*1000);
		else return lvl*1000000;
	}
	cost() {
		return (this.level*this.level+1)*100;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${money2text(this.capacity(this.level))}\n`;
		msg += `    🛠${this.level+1}:  вместимость ${money2text(this.capacity(this.level+1))} `;
		return msg + this.infoFooter();
	}
	consumption() {return 0;}
}
