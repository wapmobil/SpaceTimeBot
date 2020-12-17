
class NPCPlanet {
	constructor(id, owner) {
		this.id = id;
		this.owner = owner;
		this.ships = new Navy(1);
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			this[key] = value;
		}
	}
}

class NPCPlanets {
	constructor() {
		this.gid = 1;
		this.planets = new Map();
	}
	load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == 'planets') {
				if (Array.isArray(value)) {
					for (const v of value) {
						let si = new NPCPlanet();
						si.load(v);
						this.planets.set(si.id, si);
					}
				}
			} else {
				this[key] = value;
			}
		}
	}
	save() {
		let arr = []
		for (const i of this.planets.values()) {
			arr.push(i);
		}
		return {gid: this.gid, planets : arr};
	}
}
