include("building.qs")

class Facility extends Building {
	name() {return "🏢База";}
	icon() {return "🏢";}
	description() {
		let msg  = "Главное строение, открывает доступ к 🔍исследованиям, от уровня базы зависит количество слотов кораблей, требует ⚡ для работы, и потребляет 🍍\n";
	 	    //msg += "1 ур - доступен сканер планет\n";
	 	    msg += "2 ур - доступна 🔍исследовательская лаборатория\n";
	 	    //msg += "3 ур - сканер планет показывает все ресурсы\n";
	 	    //msg += "4 ур - сканер планет показывает уровни построек\n";
		return msg;
	}
	cost() {
		return Math.pow(10, (this.level+3));
	}
	info() {
		let msg = this.infoHeader()+`(-${food2text(this.eat_food(this.level))})\n`;
		msg += `    🛠${this.level+1} (-${food2text(this.taxes)})`;
		return msg + this.infoFooter();
	}
	consumption() {return 20;}
	buildTimeAdd() {return 100;}
	eat_food(l) {return this.taxes*l;}
}
