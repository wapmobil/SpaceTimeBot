class Node {
  constructor (value = 0, children = []) {
    this.value = value;
    this.children = children;
  }

  clone () {
    let that = Object.assign(new Node(), this);
    that.children = this.children.map(n => n.clone());
    return that;
  }
  
  add (...children) {
    for (let child of children) {
      this.children.push(child);
    }
    return this;
  }

  traverse (callback, traversal = Node.Traversal.BreadthFirst) {
    traversal.call(this, callback);
    return this;
  }

  reduce (callback, initial, mode) {
    let acc = initial;
    this.traverse(n => acc = callback(acc, n), mode);
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

Node.Traversal = {
    BreadthFirst: function(callback) {
        let nodes = [this];
        while (nodes.length > 0) {
            const current = nodes.shift();
            callback(current);
            nodes = nodes.concat(current.children);
        }      
    },
    DepthFirst: function(callback) {
        callback(this);
        this.children.forEach(n => n.traverse(callback,  Node.Traversal.DepthFirst));
    }
};
