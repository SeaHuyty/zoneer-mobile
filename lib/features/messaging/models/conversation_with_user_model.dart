import 'package:zoneer_mobile/features/messaging/models/chat_user_model.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_model.dart';

class ConversationWithUserModel {
  final ConversationModel conversation;
  final ChatUserModel otherUser;
  final bool hasUnread;

  const ConversationWithUserModel({
    required this.conversation,
    required this.otherUser,
    this.hasUnread = false,
  });

  factory ConversationWithUserModel.fromJoinedJson(
    Map<String, dynamic> json,
    String currentUserId, {
    bool hasUnread = false,
  }) {
    final conversation = ConversationModel.fromJson(json);

    final tenantJson = json['tenant'] as Map<String, dynamic>?;
    final landlordJson = json['landlord'] as Map<String, dynamic>?;

    final tenant = tenantJson != null
        ? ChatUserModel.fromJson(tenantJson)
        : ChatUserModel(id: conversation.tenantId, fullname: 'Unknown');
    final landlord = landlordJson != null
        ? ChatUserModel.fromJson(landlordJson)
        : ChatUserModel(id: conversation.landlordId, fullname: 'Unknown');

    final otherUser = tenant.id == currentUserId ? landlord : tenant;

    return ConversationWithUserModel(
      conversation: conversation,
      otherUser: otherUser,
      hasUnread: hasUnread,
    );
  }
}
