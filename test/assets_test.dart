import 'dart:io';

import 'package:assets/assets.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('resolve', () {
    final fileMap = <String, List<String>>{
      'images': ['image1.png', 'image2.png', 'image3.png'],
    };
    final keys = fileMap.keys;
    for (var key in keys) {
      var subPaths = fileMap[key];
      for (var subPath in subPaths) {
        File(path.join('assets', key, subPath)).createSync(recursive: true);
      }
    }
    resolve();
  });
}
