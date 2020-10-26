import 'dart:io';

import 'package:assets/assets.dart' as assets;
import 'package:args/args.dart';

const _ignoreDirOption = 'ignore-dir';
const _helpFlag = 'help';

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption(
    _ignoreDirOption,
    abbr: 'i',
    valueHelp: '忽略的资源文件夹，如images,fonts',
  );
  parser.addFlag(
    _helpFlag,
    abbr: 'h',
    negatable: false,
    help: 'Displays this help information.',
  );
  try {
    final results = parser.parse(arguments);
    if (results.wasParsed(_helpFlag)) {
      stdout.writeln(parser.usage);
      return;
    }
    for (var argument in results.options) {
      if (argument != _helpFlag && !results.wasParsed(argument)) {
        throw ArgumentError('Could not find an option named "$argument".');
      }
    }
    assets.resolve(results[_ignoreDirOption]?.toString()?.split(','));
  } catch (e) {
    stderr.writeln(e);
    stdout.writeln('该命令只支持以下操作：');
    stdout.writeln(parser.usage);
  }
}
