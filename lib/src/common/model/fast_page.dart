/// FastPage is a generic pagination model for paged list responses.
class FastPage<T> {
  /// The list of items for the current page.
  final List<T> items;

  /// The total number of items available (across all pages).
  final int totalCount;

  /// The current page index (zero-based).
  final int pageIndex;

  /// The size of each page (number of items per page).
  final int pageSize;

  /// Creates a [FastPage] instance.
  const FastPage({
    required this.items,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
  });

  /// Creates a [FastPage] from JSON.
  factory FastPage.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return FastPage<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      totalCount: json['totalCount'] as int,
      pageIndex: json['pageIndex'] as int,
      pageSize: json['pageSize'] as int,
    );
  }

  /// Converts this [FastPage] to JSON.
  Map<String, dynamic> toJson(dynamic Function(T) toJsonT) => {
        'items': items.map(toJsonT).toList(),
        'totalCount': totalCount,
        'pageIndex': pageIndex,
        'pageSize': pageSize,
      };
}
