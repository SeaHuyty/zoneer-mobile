import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_model.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_with_user_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_with_sender_model.dart';
import 'package:zoneer_mobile/features/messaging/repositories/messaging_repository.dart';

class MessagingViewmodel
    extends AsyncNotifier<List<ConversationWithUserModel>> {
  @override
  FutureOr<List<ConversationWithUserModel>> build() async => [];

  Future<List<ConversationWithUserModel>> _fetchConversations(String userId) {
    return ref.read(messagingRepositoryProvider).getMyConversations(userId);
  }

  Future<void> loadMyConversations(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return _fetchConversations(userId);
    });
  }

  Future<void> refreshMyConversations(String userId) async {
    try {
      final conversations = await _fetchConversations(userId);
      state = AsyncValue.data(conversations);
    } catch (error, stackTrace) {
      if (!state.hasValue) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> sendMessage(MessageModel message) async {
    await ref.read(messagingRepositoryProvider).sendMessage(message);
  }

  Future<void> markConversationRead(
    String conversationId,
    String currentUserId,
  ) async {
    await ref
        .read(messagingRepositoryProvider)
        .markConversationMessagesRead(conversationId, currentUserId);
  }
}

final messagingViewModelProvider =
    AsyncNotifierProvider<MessagingViewmodel, List<ConversationWithUserModel>>(
      MessagingViewmodel.new,
    );

final messagesByConversationProvider = FutureProvider.autoDispose
    .family<List<MessageWithSenderModel>, String>((ref, conversationId) async {
      return ref.read(messagingRepositoryProvider).getMessages(conversationId);
    });

final conversationByInquiryIdProvider =
    FutureProvider.family<ConversationModel, String>((ref, inquiryId) async {
      return ref
          .read(messagingRepositoryProvider)
          .getConversationByInquiryId(inquiryId);
    });
