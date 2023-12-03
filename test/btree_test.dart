import 'package:btreedart/btreedart.dart';

void main() {
  print("Start!");
  BTree bTree = BTree(degree: 50000);

  print("Insert data");
  watchTimer("Lead time to insert", () {
    for (int i = 0; i < 50000; i++) {
      bTree.insert("key$i", "value$i");
    }
  });

  print("\nUpdate data");
  watchTimer("Lead time to update", () {
    for (int i = 0; i < 50000; i++) {
      bTree.update("key$i", "value${i - 1}");
    }
  });

  print("\nSearch data");
  watchTimer("Lead time to search", () {
    for (int i = 0; i < 50000; i++) {
      bTree.search("key$i");
    }
  });

  print("\nDelete data");
  watchTimer("Lead time to delete", () {
    for (int i = 0; i < 50000; i++) {
      bTree.delete("key$i");
    }
  });
}

void watchTimer(String message, void Function() callback) {
  Stopwatch stopwatch = Stopwatch()..start();
  callback();
  stopwatch.stop();
  print("$message: ${stopwatch.elapsed}");
}
