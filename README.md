B+Tree Implementation on Dart.

- Free software: _GPL v3_.0

<h4>Note</h4>
This project has not been tested in any way. Use at your own risk.

<h4>Documentation</h4>
This data structure is intended to be used as a key-value.

**Constructor**

```dart
 BTree bTree = BTree(degree: 1000); // degree - How many keys can a node contain
```

**Insert**

```dart
btree.insert("key1", "value1");
```

**Update**

```dart
btree.update("key1", "value0");
```

**Search**

```dart
btree.search("key1"); // return "value0"
```

**Delete**

```dart
btree.delete("key1"); // Deleting key key1. The next search will result in null
```
