include("resources.qs")

class StockItem {
	constructor(id, chat, res, count, price) {
		this.id = id;
		this.owner = chat;
		this.client = 0;
		this.res = res;
		this.count = count;
		this.price = price;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
}

class Marketplace {
	constructor() {
		this.gid = 1;
		this.items = new Map();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == 'gid') this.gid = value;
			if (key == 'items') {
				for (const [k, v] of value) {
					let si = new StockItem();
					si.load(v);
					this.items.set(k, si);
				}
			}
		}
	}
}

class Stock {
	constructor(id) {
		this.chat_id = id;
		this.sell = new Array();
		this.buy = new Array();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
	info(my) {
		let msg = "";
		let cnt = 0;
		let buttons = [];
		for (const v of this.sell) {
			cnt++;
			if (my) msg += `<b>Продам ${cnt}:</b>` 
			else msg += `<b>Продаёт:</b>`; 
			msg += getResourceInfo(v.res, v.count) + ` за ${money2text(v.price*v.count)} - ${this.infoFooter(v.client)}\n`;
			if (my) buttons.push(`Удалить ${cnt}`);
		}
		for (const v of this.buy) {
			cnt++;
			if (my) msg += `<b>Куплю ${cnt}:</b>`;
			else msg += `<b>Покупает:</b>`; 
			msg += getResourceInfo(v.res, v.count) + ` за ${money2text(v.price*v.count)} - ${this.infoFooter(v.client)}\n`;
			if (my) buttons.push(`Удалить ${cnt}`);
		}
		return {msg, buttons};
	}
	add(sell, res, count, price) {
		let arr;
		if (sell) arr = this.sell;
		else arr = this.buy;
		if (arr.length >= 5) {
			Telegram.send(this.chat_id, "Достигнуто максимальное число заявок");
		} else {
			arr.push({res, count, price, client: 0});
		}
	}
	infoFooter(client) {
		return client == 0 ? "🔘" : "🔒"
	}
	remove(index) {
		if (index >=0) {
			if (index < this.sell.length) {
				if (this.sell[index].client == 0) {
					this.sell.splice(index, 1);
				} else {
					Telegram.send(this.chat_id, "Нельзя удалить, сделка уже идёт");
				}
			} else {
				const bind = index - this.sell.length;
				if (this.buy[bind].client == 0) {
					this.buy.splice(bind, 1);
				} else {
					Telegram.send(this.chat_id, "Нельзя удалить, сделка уже идёт");
				}
			}
		}
	}
	reserved(res) {
		let cnt = 0;
		for (const v of this.sell) {
			if (v.res == res) cnt += v.count;
		}
		return cnt;
	}
	money() {
		let m = 0;
		for (const v of this.buy) m += v.price * v.count;
		return m;
	}
}

function createStockCountButtons() {
	let arr = [];
	for(let j=0; j<4; j++) {
		arr.push(`-${Math.pow(10, j)}`);
		arr.push(`+${Math.pow(10, j)}`);
	}
	return arr;
}
const stockCountButtons = createStockCountButtons();
