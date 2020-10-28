include("resources.qs")

class StockItem {
	constructor(id, chat, res, count, price, is_sell) {
		this.id = id;
		this.owner = chat;
		this.client = 0;
		this.res = res;
		this.count = count;
		this.price = price;
		this.is_sell = is_sell;
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
	infoFooter() {
		return this.client == 0 ? "🔘" : "🔒"
	}
	info() {
		let msg = "";
		if(this.is_sell) msg = `<b>Продаю:</b>\n`;
		else msg = `<b>Куплю:</b>\n`;
		msg += `    ${getResourceInfo(this.res, this.count)} за ${money2text(this.price*this.count)} - ${this.infoFooter()}\n`;
		return msg;
	}

}

class Marketplace {
	constructor() {
		this.gid = 1;
		this.items = new Map();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == 'items') {
				if (Array.isArray(value)) {
					for (const v of value) {
						let si = new StockItem();
						si.load(v);
						this.items.set(si.id, si);
					}
				}
			} else {
				this[key] = value;
			}
		}
	}
	save() {
		let arr = []
		for (const i of this.items.values()) {
			arr.push(i);
		}
		return {gid: this.gid, items : arr};
	}
	addItem(chat, res, count, price, is_sell) {
		this.gid += 1;
		const si = new StockItem(this.gid, chat, res, count, price, is_sell);
		this.items.set(si.id, si);
		return si;
	}
	removeItem(id) {
		if (this.items.has(id)) {
			const si = this.items.get(id);
			if (si.client != 0) {
				Telegram.send(si.chat, "Нельзя удалить, сделка уже идёт");
				return false;
			} else {
				this.items.delete(id);
				return true;
			}
		} else return true;
	}
	info() {
		let msg = "";
		for (const v of this.items.values()) {
			msg += `<b>№${v.id}:</b> ${v.info()}`
			if (v.client == 0) msg += `    Отправить -> /go_${v.id}\n`;
		}
		return msg;
	}
	get(id) {
		return this.items.get(id);
	}
	start(id, client) {
		if (this.items.has(id)) {
			if (this.items.get(id).client != 0) return false;
			this.items.get(id).client = client;
			return true;
		} else return false;
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
			if (key == 'sell' || key == 'buy') {
				for (const v of value) {
					let si = new StockItem();
					si.load(v);
					this[key].push(si);
				}
			} else {
				this[key] = value;
			}
		}
	}
	info() {
		let is = this.fillInfo(this.sell);
		let ib = this.fillInfo(this.buy);
		return {msg: is.msg + ib.msg, buttons: is.buttons.concat(ib.buttons)};
	}
	fillInfo(arr) {
		let msg = "";
		let buttons = [];
		for (const v of arr) {
			msg += `<b>№${v.id}:</b> ${v.info()}` 
			if (v.client == 0) buttons.push(`Удалить ${v.id}`);
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
			arr.push(GlobalMarket.addItem(this.chat_id, res, count, price, sell));
		}
	}
	remove(bt) {
		const id = parseInt(bt.match(/.*(\d+)/i)[1]);
		if (GlobalMarket.removeItem(id)) {
			const is = this.sell.findIndex(r => r.id == id);
			if (is >= 0) {
				this.sell.splice(is, 1);
				return true;
			}
			const ib = this.buy.findIndex(r => r.id == id);
			if (ib >= 0) {
				this.buy.splice(ib, 1);
				return true;
			}
		}
		return false;
	}
	delete(id) {
		GlobalMarket.items.delete(id);
		const is = this.sell.findIndex(r => r.id == id);
		if (is >= 0) this.sell.splice(is, 1);
		const ib = this.buy.findIndex(r => r.id == id);
		if (ib >= 0) this.buy.splice(ib, 1);
	}
	reserved(res) {
		let cnt = 0;
		for (const v of this.sell) {
			if (v.res == res) cnt += v.count;
		}
		return cnt;
	}
	reservedStorage() {
		let cnt = 0;
		for (const v of this.buy) {
			cnt += v.count;
		}
		return cnt;
	}
	money() {
		let m = 0;
		for (const v of this.buy) m += v.price * v.count;
		return m;
	}
	start(id, client) {
		const is = this.sell.findIndex(r => r.id == id);
		if (is >= 0) {
			//print(this.sell[is].info(), this.sell[is].client, client);
			if (this.sell[is].client == client) return true;
			if (this.sell[is].client != 0) return false;
			this.sell[is].client = client;
			return true;
		}
		const ib = this.buy.findIndex(r => r.id == id);
		if (ib >= 0) {
			//print(this.buy[ib].info(), this.buy[ib].client, client);
			if (this.buy[ib].client == client) return true;
			if (this.buy[ib].client != 0) return false;
			this.buy[ib].client = client;
			return true;
		}
		print("fail", is, ib, id, client);
		print(this.info().msg);
		return false;
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
