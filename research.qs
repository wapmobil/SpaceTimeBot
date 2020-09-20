class Research {
	constructor (name, func, time, cost, children = [], locked = false) {
		this.name = name;
		this.locked = locked;
		this.func = func;
		this.children = children;
		this.time = time;
		this.cost = cost;
		this.active = false;
	}
	
	start() {
		this.active = true;
	}
	
	step(st) {
		if (this.active) {
			this.time -= st;
			if (this.time <= 0) {
				this.time = 0;
				this.active = false;
				return this.func;
			}
		}
		return undefined;
	}

	clone () {
		let that = Object.assign(new Research(), this);
		that.children = this.children.map(n => n.clone());
		return that;
	}

	load(o) {
		for (const [key, value] of Object.entries(o)) {
			//print(key, value);
			if (key == 'children') {
				for (let i = 0; i < this.children.length; i++) {
					for (let child of value) {
						if (this.children[i].name == child.name) {
							this.children[i].load(child);
						}
					}
				}
			} else {
				this[key] = value;
			}
		}
	}

  add (...children) {
    for (let child of children) {
      this.children.push(child);
    }
    return this;
  }

  addNext (child) {
    this.children.push(child);
    return this.children[this.children.length-1];
  }

  traverse (callback, traversal = Research.Traversal.DepthFirst, depth = 0) {
    traversal.call(this, callback, depth);
    return this;
  }

  reduce (callback, initial, mode) {
    let acc = initial;
    let depth = 0;
    this.traverse((n,d) => {acc = callback(acc, n, d)}, mode, depth);
    //print("reduce->", acc);
    return acc;
  }

  every (callback) {
    return this.reduce((a, n) => a && callback(n), true);
  }

  some (callback) {
    return this.reduce((a, n) => a || callback(n), false);
  }

  find (callback, mode) {
    return this.reduce((a, n) => a || (callback(n)? n: false), false, mode);
  }

  includes (value) {
    return this.some(n => n.value === value);
  }
  
}

Research.Traversal = {
    BreadthFirst: function(callback) {
        let nodes = [this];
        while (nodes.length > 0) {
            const current = nodes.shift();
            callback(current);
            nodes = nodes.concat(current.children,  Research.Traversal.BreadthFirst);
        }      
    },
    DepthFirst: function(callback, depth = 0) {
        callback(this, depth);
        this.children.forEach(n => n.traverse(callback, Research.Traversal.DepthFirst, depth+1));
    },
    Actual: function(callback, depth = 0) {
        if (this.time > 0) {
          callback(this, depth);
        } else {
          let nodes = this.children.filter(v => !v.locked);
          nodes.forEach(n => n.traverse(callback, Research.Traversal.Actual, depth+1));
        }
    }
};


//sience_tree.children[0].children[1].addNext(new Research('H', "")).addNext(new Research('I', ""))


const sienceTree = function(a, r, d) {
	//print(a, r, d);
	for (var i = 0; i < d; i++) a += "--"; 
	a += `+${r.name}`;
	a += r.locked ? "[-]" : (r.time > 0  ? "[ ]" : "[x]");
	a += '\n';
	for (var i = 0; i < d; i++) a += "  ";
	a += `   => ${r.time}⏳ ${r.cost}💰`;
	if (r.active) a += " - исследуется";
	a += "\n";
	//print("=====",a);
	return a;
}

const sienceArray = function(a, r) {
	a.push(r.name);
	return a;
}

function createSienceTree() {
	let s = new Research("🔍🌍Разведка планеты", "survey", 10, 250000);
	s.addNext(new Research("🔍🔋Аккумуляторы", "accum", 50, 1000000)).addNext(new Research("🔍🔌Экономия энергии", "eco_power", 100, 2000000));
	s.addNext(new Research("🔍🛠Быстрое строительство", "fastbuild", 40, 3000000));
	s.addNext(new Research("🔍🚀Корабли", "enable_ships", 20, 400000)).addNext(new Research("🔍💸Торговля", "eco_power", 60, 700000));
	return s;
}

