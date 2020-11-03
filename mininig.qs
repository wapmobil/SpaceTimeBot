
class MiningPlayer {
	
	constructor(x,y){
		this.x=x;
		this.y=y;
		this.hp=4;
		this.bombs=1;
		this.money = 0;
		
	}
	
	MiningPlayerinfo(){
		let info = "Здоровье: ";
		info+=`${this.pl.hp}`;
		info+="Бомбы: ";
		info+=`${this.pl.bombs}`;
		info+="Денежки: ";
		info+=`${this.pl.money}`;
		return info;
  	}
}

class MiningCell {
	constructor(name,icon,spawnrate,value,health){// icons , spawn rate 1/spawnrate 
		// value of mob(hp) or resources(qauntity)
		this.name = name;
		this.icon = icon;
		this.spawnrate = spawnrate;
		this.number = getRandom(spawnrate); //random number in spawnrate range
		this.value = value + Math.floor(getRandom(value) / 2) - Math.floor(getRandom(value) / 2);
		this.health = health;
	}
}

const spawnMiningCells = [
		new MiningCell ("empty"       , "▫️" , 0, 0, 0),
		new MiningCell ("wall"        , "⬛️", 0, 0, 0),
		new MiningCell ("home"        , "🚪", 0, 0, 0),
		new MiningCell ("MiningPlayer", "🤠", 0, 0, 0),
		new MiningCell ("heart"       , "❤️" , 20, 1, 0),
		new MiningCell ("bomb"        , "🧨", 40, 1, 0),
		new MiningCell ("money"       , "💰", 5, 5, 0),
		new MiningCell ("bigmoney"    , "💵", 400, 100, 0),
		new MiningCell ("rat"         , "🐀", 15, 3, 1),
		new MiningCell ("spider"      , "🦇", 25, 5, 2),
		new MiningCell ("alien"       , "👽", 50, 10, 3)
		];
		
class MiningLabyrinth {
	
	constructor(mapsize) {
		this.mapsize = mapsize;
		
		let mapg = new Array(mapsize);
		for(let i = 0; i < mapsize; i++) {
			mapg[i] = new Array(mapsize);
			for(let j = 0; j < mapsize; j++) {
				//mapg[i][j] = new Array(3);
				if((i % 2 == 0) || (j % 2 == 0)) {
					mapg[i][j] = (getRandom(10) > 9 && i > 1 && j > 1 && i < mapsize - 1 && j < mapsize - 1) ? 0 : 1;
					//mapg[i][j][1] = 1;
				} else {
					mapg[i][j] = 0;
					//mapg[i][j][1] = 0;
				}
			}
		}
		this.map = mapg;
		this.tractor();
		this.spawnres();
		this.dig(this.mapsize - 2, this.mapsize - 1, 2);
		//print("map created");
	}
	
	show() { //(return map in String)
		let msg = "";
		for (let line of this.map) {
			for (let point of line) {
				msg += `${spawnMiningCells[point].icon}`;
			} 
			msg += "\n";
		}
		return msg;
	}
	
	dig(x, y, symb) {
		this.map[x][y] = symb;
	}
	
	inBounds(x, y) {
		return ((x < this.mapsize-1) && (y < this.mapsize-1) && (x >= 1) && (y >= 1)) ||
				(x == this.mapsize - 2 && y == this.mapsize - 1);
	}
	
	isWall(x, y) {
		return (this.map[x][y] == 1);
	}
	
	indofMiningCell(x,y){
		return this.map[x][y];
		}
	
	spawnres() { 
		for (let i = 1; i < this.mapsize - 1; i++){
			for (let j= 1; j < this.mapsize - 1; j++){
				if (!this.isWall(i,j)){
					this.map[i][j] = 0;
					for (let r = 4; r < spawnMiningCells.length; r++) {
						let rnd = getRandom(spawnMiningCells[r].spawnrate);
						if (rnd == spawnMiningCells[r].number) {
							this.map[i][j] = r;
							//print(c.name, c.icon);
						};
					}
					//var map = this.map;
					// this.spawnMiningCells.forEach(c => {
					//	let rnd = getRandom(c.spawnrate);
					//	//print(c.name, c.number, rnd);
					//	if (rnd == c.number) {
					//		map[i][j] = c;
					//		//print(c.name, c.icon);
					//	}
					//});
					//this.map = map;
				}
			}
		}
	}
	
	isEmpty(x, y) {
		if(this.inBounds(x, y) && (this.map[x][y] == 0)) {
			return true;
		} else return false;
	}
	
	isrdytoMove(x, y) {
		if((this.isEmpty(x + 2, y)) || (this.isEmpty(x - 2, y)) || (this.isEmpty(x, y + 2)) || (this.isEmpty(x, y - 2))) {
			return true;
		} else {
			return false;
		}
	}
	
	tractor() {
		for(let x = 1; x < this.mapsize - 1; x += 2) {
			for(let y = 1; y < this.mapsize - 1; y += 2) {
				let way = true;
				let i = x;
				let j = y;
				this.map[i][j] = 3;
				while(this.map[i][j] == 3) { //  2-где были 3 - где находимся
					while(way) {
						let delwall = getRandom(4);
						switch(delwall) {
							case 0:
								if(this.isEmpty(i + 2, j)) {
									this.map[i + 1][j] = 2;
									this.map[i][j] = 2;
									this.map[i + 2][j] = 3;
									way = false;
									i += 2;
								} else this.map[i][j] = 2;
								break;
							case 1:
								if(this.isEmpty(i - 2, j)) {
									this.map[i - 1][j] = 2;
									this.map[i][j] = 2;
									this.map[i - 2][j] = 3;
									way = false;
									i -= 2;
								} else this.map[i][j] = 2;
								break;
							case 2:
								if(this.isEmpty(i, j + 2)) {
									this.map[i][j + 1] = 2;
									this.map[i][j] = 2;
									this.map[i][j + 2] = 3;
									way = false;
									j += 2;
								} else this.map[i][j] = 2;
								break;
							case 3:
								if(this.isEmpty(i, j - 2)) {
									this.map[i][j - 1] = 2;
									this.map[i][j] = 2;
									this.map[i][j - 2] = 3;
									way = false;
									j -= 2;
								} else this.map[i][j] = 2;
								break;
						}
						way = this.isrdytoMove(i, j);
					}
					this.map[i][j] = 2;
				}
			}
		}
	//print("MiningLabyrinth generated");
	}
}


class MiningGame {
	constructor() {
		let mapSize = 13;
		this.pl = new MiningPlayer(1,1);
		this.plMap = new MiningLabyrinth(mapSize);
		this.plMap.dig(this.pl.x,this.pl.y,3);
		this.active_bomb = false;
		
	}


	blow(){
		this.active_bomb = this.pl.bombs > 0;
		//if (plMap.isWall(Pos)&&(this.pl.bombs!=0)){
		//	this.plMap.dig(Pos.x,Pos.y,"⬜️");
		//	return true;
		//} else return false;
	}

	MiningPlayerinfo(){
		let info = "Здоровье: ";
		for (let i = 0; i < this.pl.hp; i++) info += "❤️";
		info += "\nБомбы: ";
		for (let i = 0; i < this.pl.bombs; i++) info += "🧨";
		info += "\nДенежки: ";
		info += `${this.pl.money}`;
		return info + "\n";

	}

	move(way) {// 0-stay 1-up 2-down 3-left 4 - right
		let x = this.pl.x;
		let y = this.pl.y;
		switch (way) {
		case 1:
//			let nx = 0;
//			for (nx = x - 1; nx > 0; nx--) {
//				if (this.plMap.inBounds(nx, y) || this.plMap.isWall(nx, y) || (this.plMap.indofMiningCell(nx, y) >= 8)) {
//					nx++;
//					break;
//				}
//			}
//			print(x, nx);
//			x = nx;
			x -= 1;
			break;
		case 2:
			y -= 1;
			break;
		case 3:
			x += 1;
			break;
		case 4:
			y += 1;
			break;
		}
		
		switch(this.plMap.indofMiningCell(x,y)) {
		case 4:
			this.pl.hp++;
			break;
		case 5:
			this.pl.bombs++;
			break;
		case 6:
			this.pl.money += spawnMiningCells[this.plMap.map[x][y]].value;
			break;
		case 7:
			this.pl.money += spawnMiningCells[this.plMap.map[x][y]].value;
			break;
		case 8:
		case 9:
		case 10:
			this.pl.hp    -= spawnMiningCells[this.plMap.map[x][y]].health;
			this.pl.money += spawnMiningCells[this.plMap.map[x][y]].value;
			break;
		}
		if (x == this.plMap.mapsize - 2 && y == this.plMap.mapsize - 1) {
			return 1; // - end of journey
		}
		if (this.pl.hp <= 0) {
			return 2;
		}
		if (this.plMap.inBounds(x, y) && (!this.plMap.isWall(x, y) || this.active_bomb)) { // делать все действия до перехода
			this.plMap.dig(this.pl.x, this.pl.y, 0);
			this.pl.x = x;
			this.pl.y = y;
			this.plMap.dig(this.pl.x, this.pl.y, 3);
		}
		if (this.active_bomb) {
			this.active_bomb = false;
			this.pl.bombs -= 1;
		}
		return 0;
	}
	show() {
		return this.MiningPlayerinfo() + this.plMap.show();
	}
}

var miningButtons	  = [" ", "↑" , " ",
						 "←", "🧨", "→",
						 " ", "↓" , " "];
var miningButtonsRole = [-1,  0, -1,
						  1,  4,  3,
						 -1,  2, -1];
