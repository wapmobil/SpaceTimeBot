var Ratings = {
	money     : [],
	food      : [],
	ships     : [],
	buildings : [],
	resources : [],
};


function ratingCalc(on) {
	if (on) {
		var funcs = [v => v.money,
					 v => v.food,
					 v => v.totalShipsSize(),
					 v => v.totalBuildings(),
					 v => v.totalResources(),
					 ];
		let i = 0;
		for (const [rk, rv] of Object.entries(Ratings)) {
			var arr = new Array();
			for (var [key, value] of Planets) {
				arr.push({id: key, v: funcs[i](value)});
			}
			arr.sort(function(a, b) {
				if (a.v < b.v) return 1;
				if (a.v > b.v) return -1;
				return 0;
			});
			Ratings[rk] = arr;
			i++;
		}
	}
}
