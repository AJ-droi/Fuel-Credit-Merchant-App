import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/merchant_transaction.dart';

class TransactionsRepository {
  const TransactionsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResult<List<MerchantTransaction>>> fetchTransactions({
    int page = 1,
    int limit = 20,
  }) {
    return _apiClient.get<List<MerchantTransaction>>(
      ApiEndpoints.merchantTransactions,
      queryParameters: <String, dynamic>{
        'page': page,
        'limit': limit,
      },
      parser: (json) {
        final items = _extractItems(json);
        return items
            .map((item) => MerchantTransaction.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  List<dynamic> _extractItems(dynamic json) {
    if (json is List<dynamic>) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      final data = json['data'];
      if (data is List<dynamic>) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final nestedTransactions = data['transactions'];
        if (nestedTransactions is List<dynamic>) {
          return nestedTransactions;
        }

        final nestedItems = data['items'];
        if (nestedItems is List<dynamic>) {
          return nestedItems;
        }
      }

      final transactions = json['transactions'];
      if (transactions is List<dynamic>) {
        return transactions;
      }

      final items = json['items'];
      if (items is List<dynamic>) {
        return items;
      }
    }

    return const <dynamic>[];
  }
}
