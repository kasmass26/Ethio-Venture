// import 'package:dio/dio.dart';
// import 'package:ethioventure/core/utils/token_storage.dart';

// /// Attaches the JWT to every outgoing request and can trigger
// /// a refresh-token flow on a 401. Kept in core/network since both
// /// auth and every other feature's datasources depend on it.
// class AuthInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
//     final token = await TokenStorage.getAccessToken();
//     if (token != null) {
//       options.headers['Authorization'] = 'Bearer $token';
//     }
//     handler.next(options);
//   }

//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) async {
//     if (err.response?.statusCode == 401) {
//       // TODO: attempt refresh-token flow via AuthRemoteDataSource,
//       // then retry the original request. Fall back to forcing logout.
//     }
//     handler.next(err);
//   }
// }
