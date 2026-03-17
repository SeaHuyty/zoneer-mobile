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

  Future<void> loadMyConversations(String userId) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref.read(messagingRepositoryProvider).getMyConversations(userId);
    });
  }

  Future<void> sendMessage(MessageModel message) async {
    await ref.read(messagingRepositoryProvider).sendMessage(message);
  }
}

final messagingViewModelProvider =
    AsyncNotifierProvider<MessagingViewmodel, List<ConversationWithUserModel>>(
      MessagingViewmodel.new,
    );

final messagesByConversationProvider =
    FutureProvider.family<List<MessageWithSenderModel>, String>((
      ref,
      conversationId,
    ) async {
      return ref.read(messagingRepositoryProvider).getMessages(conversationId);
    });

final conversationByInquiryIdProvider =
    FutureProvider.family<ConversationModel, String>((ref, inquiryId) async {
      return ref
          .read(messagingRepositoryProvider)
          .getConversationByInquiryId(inquiryId);
    });
