import 'package:assets/assets.dart' as assets;
import 'package:args/args.dart';

void main(List<String> arguments) {
  final parser = ArgParser();
  parser.addOption(
    'ignore',
    abbr: 'i',
    valueHelp: '忽略的资源文件夹',
  );
  try {
    final results = parser.parse(arguments);
    final ignores = results['ignore']?.toString()?.split(',');
    assets.resolve(ignores);
  } catch (e) {
    print(parser.usage);
  }
}
