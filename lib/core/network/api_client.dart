// import 'package:dio/dio.dart';
// import 'package:ethio_venture/core/network/api_endpoints.dart';
// import 'package:ethio_venture/core/network/auth_interceptor.dart';

// /// Thin wrapper around Dio, configured once and injected everywhere.
// /// The Node.js/Express REST API is the single source of truth;
// /// this class owns the base config only — actual calls live in
// /// each feature's remote datasource.
// class ApiClient {
//   final Dio dio;

//   ApiClient(this.dio) {
//     dio.options = BaseOptions(
//       baseUrl: ApiEndpoints.baseUrl,
//       connectTimeout: const Duration(seconds: 15),
//       receiveTimeout: const Duration(seconds: 15),
//       headers: {'Content-Type': 'application/json'},
//     );
//     dio.interceptors.add(AuthInterceptor());
//   }
// }
