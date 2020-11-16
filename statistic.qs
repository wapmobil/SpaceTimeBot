var timer_statistic = new QTimer();
timer_statistic["timeout()"].connect(statisticStep);
timer_statistic.start(5 * 60 * 1000);

var Statistica = {
	messages         : 0,
	mining           : 0,
	expeditions_total: 0,
	stock_items      : 0,
	active_players   : 0,
	mining_fail      : 0,
	mining_ok        : 0,
	mining_money_all : 0,
	mining_money_max : 0
	};

var PlanetStats = new Map();
var globalThis = this;

function statisticStep() {
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
	PlanetStats = new Map();
}
