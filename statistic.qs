var Statistica = {
	messages         : 0,
	mining           : 0,
	expeditions_trade: 0,
	stock_items      : 0,
	mining_fail      : 0,
	mining_ok        : 0,
	mining_money_all : 0,
	mining_money_max : 0,
	battle_win       : 0,
	battle_lose      : 0,
	battle_rounds    : 0,
	expeditions_rs   : 0
	};

var StatisticaDay = {
	expeditions : 0
};

var PlanetStats = new Map();
var PlanetStatsDay = new Map();
var globalThis = this;

function statisticStep(on) {
	if (on) {
		players = Planets.size;
		stock_items_all = GlobalMarket.items.size;
		for (const [key, value] of Object.entries(Statistica)) {
			globalThis[key] = Statistica[key];
			Statistica[key] = 0;
		}
		let arr = new Array();
		let money = 0;
		for(let i=0; i<Resources.length; i++) arr.push(0);
		for (var [key, value] of Planets) {
			for(let i=0; i<Resources.length; i++) arr[i] += value[Resources[i].name];
			money += value.money;
		}
		money_total = money;
		active_players = PlanetStats.size;
		dayly_players = PlanetStatsDay.size;
		battle_active = Battles.b.size;
		resource1 = arr[0];
		resource2 = arr[1];
		resource3 = arr[2];
		resource4 = arr[3];
		PlanetStats = new Map();
	}
}

function statisticDayStep(on) {
	if (on) {
		for (const [key, value] of Object.entries(StatisticaDay)) {
			globalThis[key] = StatisticaDay[key];
			StatisticaDay[key] = 0;
		}
		dayly_players = PlanetStatsDay.size;
		PlanetStatsDay = new Map();
	}
}
