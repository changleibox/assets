import 'dart:io';

import 'package:assets/assets.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('resolve', () {
    final fileMap = <String, List<String>>{
      'images': ['image1.png', 'image2.png', 'image3.png'],
    };
    final keys = fileMap.keys;
    for (var key in keys) {
      var subPaths = fileMap[key];
      for (var subPath in subPaths) {
        final file = File(path.join('assets', key, subPath));
        if (file.existsSync()) {
          continue;
        }
        file.createSync(recursive: true);
      }
    }
    resolve();
  });
}
