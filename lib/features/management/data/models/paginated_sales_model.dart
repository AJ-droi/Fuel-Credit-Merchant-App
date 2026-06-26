import '../../../transactions/data/models/merchant_transaction.dart';

class PaginatedSalesResponse {
  const PaginatedSalesResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<MerchantTransaction> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PaginatedSalesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const PaginatedSalesResponse(
        items: [],
        page: 1,
        limit: 20,
        total: 0,
        totalPages: 0,
      );
    }

    final itemsRaw = data['items'];
    final pagination = data['pagination'];
    final paginationMap =
        pagination is Map<String, dynamic> ? pagination : <String, dynamic>{};

    return PaginatedSalesResponse(
      items: itemsRaw is List
          ? itemsRaw
                .whereType<Map<String, dynamic>>()
                .map(MerchantTransaction.fromJson)
                .toList()
          : const [],
      page: _toInt(paginationMap['page'], fallback: 1),
      limit: _toInt(paginationMap['limit'], fallback: 20),
      total: _toInt(paginationMap['total'], fallback: 0),
      totalPages: _toInt(paginationMap['totalPages'], fallback: 0),
    );
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
