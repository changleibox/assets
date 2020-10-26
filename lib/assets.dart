import 'dart:io';

import 'package:assets/template.dart';
import 'package:path/path.dart' as path;
import 'package:sprintf/sprintf.dart';

void resolve([List<String> ignores]) {
  assert(File(path.join('pubspec.yaml')).existsSync(), '请在项目更目录执行');

  final fileMap = resolveFileMap(ignores);
  if (fileMap == null) {
    stdout.writeln('assets资源文件夹不存在');
    return;
  }
  if (fileMap == null || fileMap.isEmpty) {
    stdout.writeln('assets资源文件夹是空的');
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

  openWrite.writeln(generatorTips);
  openWrite.writeln(pluginHeader);
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

Map<String, List<String>> resolveFileMap([List<String> ignores]) {
  final directory = Directory('assets');
  if (!directory.existsSync()) {
    return null;
  }
  if (ignores != null && ignores.isNotEmpty) {
    stdout.writeln('忽略目录：[${ignores.join(',')}]');
  }
  final entities = directory.listSync(
    followLinks: false,
  );
  final fileMap = <String, List<String>>{};
  for (var entity in entities) {
    final entityPath = entity.path;
    final entityName = path.basename(entityPath);
    if (entity is Directory && (ignores == null || !ignores.contains(entityName))) {
      final files = fileMap[entityPath] ??= <String>[];
      final subEntities = entity.listSync();
      var subDirectories = subEntities.whereType<Directory>();
      if (subDirectories.isNotEmpty) {
        stdout.writeln('忽略以下子目录：\n${subDirectories.map((e) => '  ${e.path}').join('\n')}');
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
