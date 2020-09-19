class Research {
  constructor (name, func, children = [], lock = false) {
    this.name = name;
    this.locked = lock;
    this.done = false;
    this.func = func;
    this.children = children; 
  }

  clone () {
    let that = Object.assign(new Research(), this);
    that.children = this.children.map(n => n.clone());
    return that;
  }
  
  load(o) {
		for (const [key, value] of Object.entries(o)) {
			if (key == 'children') {
        for (let child of value) {
          let n = new Research("","");
          n.load(child);
				  this.children.push(n);
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
    this.traverse((n,d) => acc = callback(acc, n, d), mode, depth);
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
        if (!this.done) {
          callback(this, depth);
        } else {
          let nodes = this.children.filter(v => !v.locked);
          nodes.forEach(n => n.traverse(callback, Research.Traversal.Actual, depth+1));
        }
    }
};


var sience_tree =
  new Research('A', "", [
    new Research('B', "", [
      new Research('D', ""),
      new Research('E', "", [
        new Research('G', "", []),
      ], true),
      new Research('F', "", [])
    ]),
    new Research('C', "", []) 
  ]
)
sience_tree.children[0].children[1].addNext(new Research('H', "")).addNext(new Research('I', ""))


const sienceLog = function(a, r, d) {
  for (var i = 0; i < d; i++) a += "-"; 
  a += `+${r.name}`;
  a += r.locked ? "[o]" : (r.done ? "[x]" : "[ ]");
  a += "\n";
  return a;
}

