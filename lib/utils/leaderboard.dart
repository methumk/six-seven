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

  void add(T obj) {
    _set.add(obj);
  }

  bool remove(T obj) {
    return _set.remove(obj);
  }

  // This will clear the entire leaderboard and store the contents back in its proper order
  // This assumes all items are already in the leaderboard and their values have been updated internally
  void updateEntireLeaderboard() {
    var list = topN(_set.length);
    _set.clear();
    for (T o in list) {
      _set.add(o);
    }
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
