class Pagination {
  Pagination({
    required this.totalDocs,
    required this.totalPages,
    required this.page,
    required this.limit,
    this.hasPrevPage,
    this.hasNextPage,
    this.prevPage,
    this.nextPage,
  });

  int totalDocs;
  final int totalPages;
  final int page;
  final int limit;
  final bool? hasPrevPage;
  final bool? hasNextPage;
  final int? prevPage;
  final int? nextPage;

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        totalDocs: json['totalDocs'] ?? 0,
        totalPages: json['totalPages'],
        page: json['page'],
        hasPrevPage: json['hasPrevPage'],
        hasNextPage: json['hasNextPage'],
        prevPage: json['prevPage'],
        nextPage: json['nextPage'],
        limit: json['limit'],
      );
}
