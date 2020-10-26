import 'dart:io';

import 'package:assets/template.dart';
import 'package:path/path.dart' as path;
import 'package:sprintf/sprintf.dart';

void resolve() {
  assert(File(path.join('pubspec.yaml')).existsSync(), '请在项目更目录执行');

  final fileMap = resolveFileMap();
  if (fileMap == null) {
    print('assets资源文件夹不存在');
    return;
  }
  if (fileMap == null || fileMap.isEmpty) {
    print('assets资源文件夹是空的');
    return;
  }

  resolveAssets(fileMap);
}

void resolveAssets(Map<String, List<String>> fileMap) {
  final assetsFile = File(path.join('lib', 'generated', 'assets.dart'));
  if (assetsFile.existsSync()) {
    assetsFile.deleteSync(recursive: true);
  }
  assetsFile.createSync(recursive: true);
  final openWrite = assetsFile.openWrite();
  openWrite.flush();

  final directoryPaths = fileMap.keys;
  // 创建Assets提供者
  openWrite.writeln(sprintf(assetsClassTemplate, [
    directoryPaths.map((e) {
      final dirname = path.basename(e);
      final className = _capitalize(dirname);
      return sprintf(assetsMethodTemplate, [dirname, className]).trimRight();
    }).join('\n\n'),
  ]).trim());
  openWrite.writeln();

  // 创建Assets抽象类
  openWrite.writeln(assetsAbstrctClassTemplate.trim());
  openWrite.writeln();

  final assetsSubClasses = <String>[];
  // 创建资源子类
  for (var directoryPath in directoryPaths) {
    final dirname = path.basename(directoryPath);
    final className = _capitalize(dirname);
    final filePaths = fileMap[directoryPath];
    if (filePaths == null) {
      continue;
    }
    final fieldNames = filePaths.where((element) => !path.basename(element).startsWith('.')).map((e) {
      final fileName = path.basename(e);
      final fileNameWithoutExtension = path.basenameWithoutExtension(fileName);
      return sprintf(assetsFieldTemplate, [fileNameWithoutExtension, fileName]).trimRight();
    });
    assetsSubClasses.add(
      sprintf(assetsSubClassTemplate, [className, className, fieldNames.join('\n'), dirname]).trim(),
    );
  }
  openWrite.writeln(assetsSubClasses.join('\n\n').trim());
  openWrite.close();
}

Map<String, List<String>> resolveFileMap() {
  final directory = Directory('assets');
  if (!directory.existsSync()) {
    return null;
  }
  final entities = directory.listSync(
    followLinks: false,
  );
  final fileMap = <String, List<String>>{};
  for (var entity in entities) {
    final entityPath = entity.path;
    if (entity is Directory) {
      final files = fileMap[entityPath] ??= <String>[];
      final subEntities = entity.listSync();
      var subDirectories = subEntities.whereType<Directory>();
      if (subDirectories.isNotEmpty) {
        print('忽略以下子文件夹：\n${subDirectories.map((e) => '  ${e.path}').join('\n')}');
      }
      files.addAll(subEntities.whereType<File>().map((e) => e.path));
    }
  }
  return fileMap;
}

String _capitalize(String s) {
  if (s == null || s.isEmpty) {
    return s;
  }
  return s[0].toUpperCase() + s.substring(1);
}
