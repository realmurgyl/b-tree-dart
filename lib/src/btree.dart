class Node {
  late List keys = [];
  late dynamic values = leaf ? [] : null;
  late List children = [];
  late bool leaf;

  Node({bool tLeaf = true}) {
    leaf = tLeaf;
  }
}

class BTree {
  late Node _root;
  late int _degree;
  late final Map<String, dynamic> _cache = {};

  BTree({required int degree}) {
    _root = Node();
    _degree = degree;
  }

  Map<String, dynamic> get cache => _cache;

  void insert(String key, dynamic value) {
    _cache.remove(key);
    Node node = _root;
    if (node.keys.contains(key)) {
      node.values[node.keys.indexOf(key)] = value;
    } else {
      if (node.keys.length == 2 * _degree - 1) {
        Node newNode = Node(tLeaf: false);
        newNode.children.add(node);
        _splitChild(node, 0);
        _insertNonFull(newNode, key, value);
        _root = newNode;
      } else {
        _insertNonFull(node, key, value);
      }
    }
  }

  void update(String key, dynamic value) {
    _updateNode(_root, key, value);
  }

  dynamic search(String key) {
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      dynamic result = _searchNode(_root, key);
      if (result != null) {
        _cache[key] = result;
      }
      return result;
    }
  }

  void delete(String key) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
      _deleteNode(_root, key);
      if (_root.keys.isEmpty && !_root.leaf) {
        _root = _root.children.first;
      }
    } else {
      throw Exception("Key not found");
    }
  }

  void _deleteNode(Node node, String key) {
    int index = 0;
    while (index < node.keys.length && key.compareTo(node.keys[index]) > 0) {
      index++;
    }
    if (index < node.keys.length && key.compareTo(node.keys[index]) == 0) {
      if (node.leaf) {
        node.keys.removeAt(index);
        node.values.removeAt(index);
      } else {
        if (node.children[index].keys.length >= _degree) {
          String predecessorKey = _getPredecessorKey(node, index);
          node.keys[index] = predecessorKey;
          _deleteNode(node.children[index], predecessorKey);
        } else if (node.children[index + 1].keys.length >= _degree) {
          String successorKey = _getSuccessorKey(node, index);
          node.keys[index] = successorKey;
          _deleteNode(node.children[index + 1], successorKey);
        } else {
          _mergeChildNodes(node, index);
          _deleteNode(node.children[index], key);
        }
      }
    } else {
      if (node.leaf) {
        return;
      }
      if (node.children[index].keys.length < _degree) {
        if (index > 0 && node.children[index - 1].keys.length >= _degree) {
          _borrowFromPrevious(node, index);
        } else if (index < node.keys.length &&
            node.children[index + 1].keys.length >= _degree) {
          _borrowFromNext(node, index);
        } else {
          if (index < node.keys.length) {
            _mergeChildNodes(node, index);
          } else {
            _mergeChildNodes(node, index - 1);
          }
        }
      }
      _deleteNode(node.children[index], key);
    }
  }

  String _getPredecessorKey(Node node, int index) {
    Node current = _getLeftMostChild(node.children[index]);
    return current.keys[current.keys.length - 1];
  }

  String _getSuccessorKey(Node node, int index) {
    Node current = _getRightMostChild(node.children[index + 1]);
    return current.keys[0];
  }

  Node _getRightMostChild(Node node) {
    while (!node.leaf) {
      node = node.children[node.children.length - 1];
    }
    return node;
  }

  Node _getLeftMostChild(Node node) {
    while (!node.leaf) {
      node = node.children[0];
    }
    return node;
  }

  void _mergeChildNodes(Node node, int index) {
    Node child = node.children[index];
    Node sibling = node.children[index + 1];

    child.keys.addAll([node.keys[index], ...sibling.keys]);
    if (!child.leaf) {
      child.children.addAll(sibling.children);
    }

    node.keys.removeAt(index);
    node.children.removeAt(index + 1);
  }

  void _borrowFromPrevious(Node node, int index) {
    Node child = node.children[index];
    Node sibling = node.children[index - 1];

    child.keys.insert(0, node.keys[index - 1]);
    if (!child.leaf) {
      child.children.insert(0, sibling.children.removeLast());
    }

    node.keys[index - 1] = sibling.keys.removeLast();
  }

  void _borrowFromNext(Node node, int index) {
    Node child = node.children[index];
    Node sibling = node.children[index + 1];

    child.keys.add(node.keys[index]);
    if (!child.leaf) {
      child.children.add(sibling.children.removeAt(0));
    }

    node.keys[index] = sibling.keys.removeAt(0);
  }

  void _updateNode(Node node, String key, dynamic value) {
    int index = 0;
    while (index < node.keys.length && key.compareTo(node.keys[index]) > 0) {
      index++;
    }

    if (index < node.keys.length && key.compareTo(node.keys[index]) == 0) {
      _cache[key] = value;
      node.values[index] = value;
    } else {
      if (!node.leaf) {
        _updateNode(node.children[index], key, value);
      }
    }
  }

  dynamic _searchNode(Node node, String key) {
    int i = 0;
    while (i < node.keys.length && key.compareTo(node.keys[i]) > 0) {
      i++;
    }
    if (i < node.keys.length && key.compareTo(node.keys[i]) == 0) {
      return node.values[i];
    }
    if (node.leaf) {
      return null;
    }
    return _searchNode(node.children[i], key);
  }

  void _insertNonFull(Node node, String key, dynamic value) {
    int i = node.keys.length - 1;

    if (node.leaf) {
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      node.keys.insert(i + 1, key);
      node.values.insert(i + 1, value);
    } else {
      while (i >= 0 && key.compareTo(node.keys[i]) < 0) {
        i--;
      }
      i++;
      if (node.children[i].keys.length == (2 * _degree) - 1) {
        _splitChild(node, i);
        if (key.compareTo(node.keys[i]) > 0) {
          i++;
        }
      } else if (node.children[i].keys.length > _degree - 1) {
        _insertNonFull(node.children[i], key, value);
      } else {
        _lazySplitChild(node, i);
        _insertNonFull(node.children[i], key, value);
      }
    }
  }

  void _lazySplitChild(Node parentNode, int i) {
    Node child = parentNode.children[i];
    if (child.keys.length == (2 * _degree) - 1) {
      _splitChild(parentNode, i);
    }
  }

  void _splitChild(Node node, int i) {
    Node child = node.children[i];
    Node newChild = Node(tLeaf: child.leaf);
    newChild.keys = child.keys.sublist(_degree, 2 * _degree - 1);
    if (!child.leaf) {
      newChild.children = child.children.sublist(_degree, 2 * _degree);
      child.children = child.children.sublist(0, _degree);
    }
    child.keys = child.keys.sublist(0, _degree - 1);
    node.keys.insert(i, child.keys[_degree - 1]);
    node.children.insert(i + 1, newChild);
  }
}
