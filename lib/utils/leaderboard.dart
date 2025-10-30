import 'dart:collection';

class Leaderboard<T> {
  late final SplayTreeSet<T> _set;

  Leaderboard({required int Function(T a, T b) compare})
    : _set = SplayTreeSet<T>(compare);

  // Get top item
  T? get top => _set.isNotEmpty ? _set.first : null;

  // Get top N
  List<T> topN(int n) => _set.take(n).toList();

  // Get bottom N
  List<T> bottomN(int n) => topN(n).reversed.toList();

  void add(T value) {
    _set.add(value);
  }

  // Update the value in the object first, and this will reorder it for you
  void updateFor(T obj) {
    _set.remove(obj);
    _set.add(obj);
  }

  int getLeaderboardRank(T obj) {
    int rank = 1;
    for (final other in _set) {
      if (other == obj) return rank;
      rank++;
    }
    return -1;
  }
}
