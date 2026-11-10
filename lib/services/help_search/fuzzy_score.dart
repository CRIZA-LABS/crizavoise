import 'dart:math' as math;

/// Fuzzy string similarity (0–100), written for CrizaVoise from the standard
/// published techniques (Levenshtein similarity, best-substring matching and
/// token sort/set comparison). It replaces a GPL-licensed package so the app
/// can stay closed source.
class FuzzyScore {
  /// Lower-case, keep letters/digits (any script), collapse whitespace.
  static String normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Classic edit distance (insert/delete/substitute = 1), two-row DP.
  static int levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var prev = List<int>.generate(b.length + 1, (i) => i);
    var cur = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      cur[0] = i;
      final ca = a.codeUnitAt(i - 1);
      for (var j = 1; j <= b.length; j++) {
        final cost = ca == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = math.min(math.min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final t = prev;
      prev = cur;
      cur = t;
    }
    return prev[b.length];
  }

  /// Similarity of two whole strings: 100 * (1 - distance / combined length),
  /// scaled so identical strings score 100.
  static int ratio(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 100;
    if (a.isEmpty || b.isEmpty) return 0;
    final total = a.length + b.length;
    final d = levenshtein(a, b);
    // Substitutions count twice in the "indel" view used for ratios.
    return (100 * (total - _indel(a, b, d)) / total).round();
  }

  // Approximate insert/delete distance from the edit distance.
  static int _indel(String a, String b, int d) {
    final lenDiff = (a.length - b.length).abs();
    final subs = d - lenDiff;
    return lenDiff + 2 * math.max(0, subs);
  }

  /// Best ratio of the shorter string against every same-length window of
  /// the longer one (finds "invoice" inside "how do i print an invoice").
  static int partialRatio(String a, String b) {
    final (short, long) = a.length <= b.length ? (a, b) : (b, a);
    if (short.isEmpty) return 0;
    if (long.contains(short)) return 100;
    var best = 0;
    for (var i = 0; i + short.length <= long.length; i++) {
      final r = ratio(short, long.substring(i, i + short.length));
      if (r > best) best = r;
      if (best == 100) break;
    }
    return best;
  }

  static List<String> _tokens(String s) =>
      normalize(s).split(' ').where((t) => t.isNotEmpty).toList();

  /// Word order doesn't matter: compare sorted words.
  static int tokenSortRatio(String a, String b) {
    final ta = (_tokens(a)..sort()).join(' ');
    final tb = (_tokens(b)..sort()).join(' ');
    return ratio(ta, tb);
  }

  /// Shared words count fully: compare the common words with each side's
  /// common + remaining words and keep the best.
  static int tokenSetRatio(String a, String b) {
    final sa = _tokens(a).toSet(), sb = _tokens(b).toSet();
    if (sa.isEmpty || sb.isEmpty) return 0;
    final common = (sa.intersection(sb).toList()..sort()).join(' ');
    final restA = (sa.difference(sb).toList()..sort()).join(' ');
    final restB = (sb.difference(sa).toList()..sort()).join(' ');
    final withA = [common, restA].where((s) => s.isNotEmpty).join(' ');
    final withB = [common, restB].where((s) => s.isNotEmpty).join(' ');
    return [
      if (common.isNotEmpty) ratio(common, withA),
      if (common.isNotEmpty) ratio(common, withB),
      ratio(withA, withB),
    ].reduce(math.max);
  }

  /// Overall score used by search: the best of the techniques above, with
  /// substring/token scores slightly discounted when lengths differ a lot so
  /// whole-phrase matches rank first.
  static int weighted(String query, String choice) {
    final a = normalize(query), b = normalize(choice);
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 100;
    final base = ratio(a, b);
    final lenRatio = math.max(a.length, b.length) / math.min(a.length, b.length);
    final partialWeight = lenRatio < 1.5 ? 1.0 : (lenRatio < 8 ? 0.9 : 0.6);
    final tokenWeight = lenRatio < 1.5 ? 0.95 : 0.95 * partialWeight;
    final partial = lenRatio < 1.5 ? 0 : (partialRatio(a, b) * partialWeight).round();
    final tokens = (math.max(tokenSortRatio(a, b), tokenSetRatio(a, b)) * tokenWeight).round();
    return [base, partial, tokens].reduce(math.max).clamp(0, 100);
  }

  /// All [choices] scoring at least [cutoff], best first.
  static List<({T choice, int score})> extractAllSorted<T>({
    required String query,
    required List<T> choices,
    required String Function(T) getter,
    int cutoff = 0,
  }) {
    final out = <({T choice, int score})>[];
    for (final c in choices) {
      final s = weighted(query, getter(c));
      if (s >= cutoff) out.add((choice: c, score: s));
    }
    out.sort((x, y) => y.score.compareTo(x.score));
    return out;
  }
}
