import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethioventure/core/network/network_info.dart';
import 'package:ethioventure/core/supabase/supabase_service.dart';
import 'package:ethioventure/features/messaging/data/datasources/messaging_remote_data_source.dart';
import 'package:ethioventure/features/messaging/data/repositories/messaging_repository_impl.dart';
import 'package:ethioventure/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_or_create_conversation_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/send_message_usecase.dart';
import 'package:ethioventure/features/messaging/domain/usecases/stream_messages_usecase.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/chat_cubit.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversation_list_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

/// Registers shared infrastructure and feature dependencies.
Future<void> configureDependencies() async {
  if (sl.isRegistered<SupabaseClient>()) return;

  sl
    ..registerLazySingleton<SupabaseClient>(() => SupabaseService.client)
    ..registerLazySingleton<Connectivity>(Connectivity.new)
    ..registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ---------------------------------------------------------------------------
  // Messaging Feature (Issue #2)
  // ---------------------------------------------------------------------------
  sl
    ..registerLazySingleton<MessagingRemoteDataSource>(
      () => MessagingRemoteDataSourceImpl(supabaseClient: sl<SupabaseClient>()),
    )
    ..registerLazySingleton<MessagingRepository>(
      () => MessagingRepositoryImpl(remoteDataSource: sl()),
    )
    ..registerLazySingleton(() => GetConversationsUseCase(sl()))
    ..registerLazySingleton(() => GetOrCreateConversationUseCase(sl()))
    ..registerLazySingleton(() => GetMessagesUseCase(sl()))
    ..registerLazySingleton(() => SendMessageUseCase(sl()))
    ..registerLazySingleton(() => StreamMessagesUseCase(sl()))
    ..registerFactory(() => ConversationListCubit(getConversationsUseCase: sl()))
    ..registerFactory(
      () => ChatCubit(
        getMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
        repository: sl(),
      ),
    );
}
