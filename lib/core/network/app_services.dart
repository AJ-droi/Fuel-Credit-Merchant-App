import 'package:dio/dio.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/fuel_sale/data/repositories/fuel_sale_repository.dart';
import '../../features/settlement/data/repositories/settlement_repository.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

class AppServices {
  AppServices._({
    required this.apiClient,
    required this.authRepository,
    required this.dashboardRepository,
    required this.fuelSaleRepository,
    required this.settlementRepository,
  });

  final ApiClient apiClient;
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;
  final FuelSaleRepository fuelSaleRepository;
  final SettlementRepository settlementRepository;

  static final AppServices instance = _create();

  static AppServices _create() {
    final tokenStorage = TokenStorage();
    final dio = ApiClient.createDio(
      interceptors: <Interceptor>[AuthInterceptor(tokenStorage)],
    );
    final apiClient = ApiClient(dio);

    return AppServices._(
      apiClient: apiClient,
      authRepository: AuthRepository(apiClient, tokenStorage),
      dashboardRepository: DashboardRepository(apiClient),
      fuelSaleRepository: FuelSaleRepository(apiClient),
      settlementRepository: SettlementRepository(apiClient),
    );
  }
}
