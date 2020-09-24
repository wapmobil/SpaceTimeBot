include("building.qs")

class Storage extends Building {
	name() {return "📦Хранилище";}
	icon() {return "📦";}
	description() {return "Обеспечивает хранение 💰 и ресурсов, если достигнут максимум вместимости, то дальнейшее производство прекращается";}
	capacity(lvl) {
		if (lvl < 9) return (Math.pow(2, lvl)*1000);
		else return lvl*60000*(lvl-8);
	}
	capacityProd(lvl) {
		return lvl*10;
	}
	cost() {
		return (this.level*this.level+1)*100;
	}
	info() {
		let msg = this.infoHeader();
		msg += `    Вместимость ${money2text(this.capacity(this.level))}, ${this.capacityProd(this.level)}📦\n`;
		msg += `    🛠${this.level+1}:  вместимость ${money2text(this.capacity(this.level+1))}, ${this.capacityProd(this.level+1)}📦 `;
		return msg + this.infoFooter();
	}
	consumption() {return 0;}
}
