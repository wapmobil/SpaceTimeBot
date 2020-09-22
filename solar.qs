include("building.qs")

class Solar extends Building {
	name() {return "⚡Электростанция";}
	icon() {return "⚡";}
	description() {return "Производит ⚡электричество, необходимое для работы других зданий, а также для накопления в аккумуляторах🔋";}
	cost() {
		return ((this.level*this.level)*200+80);
	}
	info() {
		let msg = this.infoHeader();
		msg += `    энергия ${-this.level*this.consumption()}⚡\n`;
		msg += `    🛠${this.level+1}:  энергия ${-(this.level+1)*this.consumption()}⚡(+${-this.consumption()}⚡) `;
		return msg + this.infoFooter();
	}
	consumption() {
		return -15;
	}
}
