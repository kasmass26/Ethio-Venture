import 'package:flutter/foundation.dart';
import 'package:ethioventure/features/messaging/domain/usecases/get_conversations_usecase.dart';
import 'package:ethioventure/features/messaging/presentation/cubit/conversation_list_state.dart';

class ConversationListCubit extends ChangeNotifier {
  final GetConversationsUseCase getConversationsUseCase;

  ConversationListState _state = const ConversationListInitial();
  ConversationListState get state => _state;

  String _currentUserId = 'inv_001';
  String _currentUserName = 'Dawit Abebe';
  String _currentUserRole = 'investor';

  ConversationListCubit({required this.getConversationsUseCase});

  Future<void> loadConversations({
    String? userId,
    String? userName,
    String? userRole,
  }) async {
    if (userId != null) _currentUserId = userId;
    if (userName != null) _currentUserName = userName;
    if (userRole != null) _currentUserRole = userRole;

    _state = const ConversationListLoading();
    notifyListeners();

    final result = await getConversationsUseCase(
      GetConversationsParams(userId: _currentUserId),
    );

    if (result.isSuccess) {
      _state = ConversationListLoaded(
        conversations: result.dataOrNull ?? [],
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
        currentUserRole: _currentUserRole,
      );
    } else {
      _state = ConversationListError(
        result.failureOrNull?.message ?? 'Failed to load conversations',
      );
    }
    notifyListeners();
  }
}
