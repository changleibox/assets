const generatorTips = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
''';

const pluginHeader = '''
// **************************************************************************
// Generator: Flutter Assets IDE plugin
// Made by Changlei
// **************************************************************************
''';

const assetsClassTemplate = '''
class Assets {
%s
}
''';

const assetsMethodTemplate = '''
  static String %s(String fileName) {
    return %s._(prefix: _Assets.instance.path).resolveFrom(fileName);
  }
''';

const assetsAbstrctClassTemplate = '''
class _Assets {
  _Assets._({this.prefix});

  final String prefix;

  static _Assets get instance => _getInstance();
  static _Assets _instance;

  static _Assets _getInstance() {
    _instance ??= _Assets._();
    return _instance;
  }

  String get catalog => 'assets';

  String get path {
    final paths = <String>[];
    if (prefix != null && prefix.isNotEmpty) {
      paths.add(prefix);
    }
    paths.add(catalog);
    return paths.join('/');
  }

  String get pathEndsWithSeparator => path + '/';

  String resolveFrom(String fileName) {
    return [path, fileName].join('/');
  }
}
''';

const assetsSubClassTemplate = '''
class %s extends _Assets {
  %s._({String prefix}) : super._(prefix: prefix);

%s

  @override
  String get catalog => '%s';
}
''';

const assetsFieldTemplate = '''
  static const String %s = '%s';
''';
