import 'package:btree/btree.dart';

void main() {
  print("Start!");
  BTree bTree = BTree(degree: 1000);

  print("\nInsert data...");
  watchTimer(() {
    for (int i = 0; i < 1000; i++) {
      bTree.insert("key$i", "value$i");
    }
  });

  print("\nSearch data...");
  watchTimer(() {
    print(bTree.search("key999"));
  });

  print("\nUpdate data...");
  watchTimer(() {
    bTree.update("key999", "value0");
  });

  print("\nSearch data...");
  watchTimer(() {
    print(bTree.search("key999"));
  });

  print("\nDelete data..");
  watchTimer(() {
    bTree.delete("key999");
  });

  print("\nSearch data...");
  watchTimer(() {
    print(bTree.search("key999"));
  });
}

void watchTimer(void Function() callback) {
  Stopwatch stopwatch = Stopwatch()..start();
  callback();
  stopwatch.stop();
  print("Lead time: ${stopwatch.elapsed}");
}
