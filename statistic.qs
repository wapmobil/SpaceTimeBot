var timer_statistic = new QTimer();
timer_statistic["timeout()"].connect(statisticStep);
timer_statistic.start(5 * 60 * 1000);

var Statistica = {
	messages         : 0,
	mining           : 0,
	expeditions      : 0,
	stock_items      : 0,
	active_players   : 0,
	mining_fail      : 0,
	mining_ok        : 0,
	mining_money_all : 0,
	mining_money_max : 0
	};

var PlanetStats = new Map();

function statisticStep() {
	players = Planets.size;
	stock_items_all = GlobalMarket.items.size;
	for (const key in Statistica) {
		this[key] = Statistica[key];
		Statistica[key] = 0;
	}
	PlanetStats = new Map();
}
