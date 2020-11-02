var timer_statistic = new QTimer();
timer_statistic["timeout()"].connect(statisticStep);
timer_statistic.start(5 * 60 * 1000);

var Statistica = {
	messages      : 0,
	mining        : 0,
	expeditions   : 1,
	stock_items   : 2,
	active_players: 3
	};

var PlanetStats = new Map();

function statisticStep() {
	players = Planets.size;
	for (const key in Statistica) {
		this[key] = Statistica[key];
		Statistica[key] = 0;
	}
	PlanetStats = new Map();
}
