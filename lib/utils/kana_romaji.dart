// 假名 -> 罗马音转换(用于 CV 搜索: 输入罗马音匹配日文 CV 名)。
// 覆盖清音/浊音/半浊音/拗音, 汉字原样保留。
library;

const Map<String, String> _kanaToRomaji = {
  // 清音
  'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
  'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
  'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
  'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
  'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
  'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
  'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
  'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
  'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
  'わ': 'wa', 'を': 'wo', 'ん': 'n',
  // 浊音
  'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
  'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
  'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
  'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
  // 半浊音
  'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
  // 拗音
  'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
  'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
  'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
  'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
  'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
  'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
  'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
  'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
  'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
  'ぢゃ': 'ja', 'ぢゅ': 'ju', 'ぢょ': 'jo',
  'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
  'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
  // 外来音
  'しぇ': 'she', 'じぇ': 'je', 'ちぇ': 'che', 'てぃ': 'ti',
  'ふぁ': 'fa', 'ふぃ': 'fi', 'ふぇ': 'fe', 'ふぉ': 'fo',
  'うぃ': 'wi', 'うぇ': 'we', 'うぉ': 'wo', 'ゔ': 'vu',
  'っ': 'tsu',
};

/// 片假名 -> 平假名(Unicode 偏移)。
String _katakanaToHiragana(String input) {
  return input.replaceAllMapped(
    RegExp(r'[\u30A1-\u30F6\u30FC]'),
    (m) {
      final code = m.group(0)!.codeUnitAt(0);
      if (code == 0x30FC) return ''; // 长音符 ー 忽略
      return String.fromCharCode(code - 0x60);
    },
  );
}

/// 将假名转换为罗马音(最长匹配优先, 汉字等字符原样保留)。
String kanaToRomaji(String input) {
  final hira = _katakanaToHiragana(input);
  final result = StringBuffer();
  var i = 0;
  while (i < hira.length) {
    final two = i + 1 < hira.length ? hira.substring(i, i + 2) : '';
    final twoRomaji = _kanaToRomaji[two];
    if (twoRomaji != null) {
      result.write(twoRomaji);
      i += 2;
      continue;
    }
    final one = hira[i];
    result.write(_kanaToRomaji[one] ?? one);
    i++;
  }
  return result.toString();
}
