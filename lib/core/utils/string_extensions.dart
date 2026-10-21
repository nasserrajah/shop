extension StringX on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase {
    return split(RegExp(r'[\s_-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word.capitalized)
        .join(' ');
  }

  String get normalized => trim().toLowerCase();

  bool matchesQuery(String query) => normalized.contains(query.normalized);
}
