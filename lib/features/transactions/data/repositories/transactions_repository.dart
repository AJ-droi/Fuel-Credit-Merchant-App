import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../../../management/data/models/paginated_sales_model.dart';

class TransactionsRepository {
  const TransactionsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<PaginatedSalesResponse>> fetchTransactions({
    int page = 1,
    int limit = 20,
    String? fromDate,
    String? toDate,
    String? status,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) {
    return _apiClient.get<PaginatedSalesResponse>(
      ApiEndpoints.merchantTransactions,
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        if (fromDate != null && fromDate.isNotEmpty) 'fromDate': fromDate,
        if (toDate != null && toDate.isNotEmpty) 'toDate': toDate,
        if (status != null && status.isNotEmpty) 'status': status,
      },
      parser: (json) {
        if (json is Map<String, dynamic>) {
          return PaginatedSalesResponse.fromJson(json);
        }
        return PaginatedSalesResponse(
          items: const [],
          page: page,
          limit: limit,
          total: 0,
          totalPages: 0,
        );
      },
    );
  }
}
