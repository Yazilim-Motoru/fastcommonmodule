/// FastFilter is a generic filtering model for list queries.
class FastFilter {
  /// The page index (zero-based).
  final int pageIndex;

  /// The page size (number of items per page).
  final int pageSize;

  /// Optional search query or keyword.
  final String? query;

  /// Optional map of additional filter parameters.
  final Map<String, dynamic>? filters;

  /// Creates a [FastFilter] instance.
  const FastFilter({
    this.pageIndex = 0,
    this.pageSize = 20,
    this.query,
    this.filters,
  });

  /// Creates a [FastFilter] from JSON.
  factory FastFilter.fromJson(Map<String, dynamic> json) {
    return FastFilter(
      pageIndex: json['pageIndex'] ?? 0,
      pageSize: json['pageSize'] ?? 20,
      query: json['query'],
      filters: json['filters'] != null
          ? Map<String, dynamic>.from(json['filters'])
          : null,
    );
  }

  /// Converts this [FastFilter] to JSON.
  Map<String, dynamic> toJson() => {
        'pageIndex': pageIndex,
        'pageSize': pageSize,
        if (query != null) 'query': query,
        if (filters != null) 'filters': filters,
      };
}
