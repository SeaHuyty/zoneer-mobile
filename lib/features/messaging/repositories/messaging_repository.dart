import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/supabase_service.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_model.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_with_user_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_with_sender_model.dart';

class MessagingRepository {
  final SupabaseService _supabase;

  const MessagingRepository(this._supabase);

  Future<List<ConversationWithUserModel>> getMyConversations(
    String userId,
  ) async {
    final response = await _supabase
        .from('conversations')
        .select('''
          id,
          inquiry_id,
          property_id,
          tenant_id,
          landlord_id,
          created_at,
          last_message_at,
          last_message_preview,
          tenant:users!conversations_tenant_id_fkey(
            id,
            fullname,
            image_profile_url
          ),
          landlord:users!conversations_landlord_id_fkey(
            id,
            fullname,
            image_profile_url
          )
        ''')
        .or('tenant_id.eq.$userId,landlord_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return (response as List)
        .map((e) => ConversationWithUserModel.fromJoinedJson(e, userId))
        .toList();
  }

  Future<List<MessageWithSenderModel>> getMessages(
    String conversationId,
  ) async {
    final response = await _supabase
        .from('messages')
        .select('''
          id,
          conversation_id,
          sender_id,
          body,
          created_at,
          read_at,
          sender:users!messages_sender_id_fkey(
            id,
            fullname,
            image_profile_url
          )
        ''')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => MessageWithSenderModel.fromJoinedJson(e))
        .toList();
  }

  Future<void> sendMessage(MessageModel message) async {
    await _supabase.from('messages').insert(message.toJson());
  }

  Future<void> markMessageRead(String messageId) async {
    await _supabase
        .from('messages')
        .update({'read_at': DateTime.now().toIso8601String()})
        .eq('id', messageId);
  }

  Future<ConversationModel> getConversationByInquiryId(String inquiryId) async {
    final response = await _supabase
        .from('conversations')
        .select('''
          id,
          inquiry_id,
          property_id,
          tenant_id,
          landlord_id,
          created_at,
          last_message_at,
          last_message_preview
        ''')
        .eq('inquiry_id', inquiryId)
        .single();

    return ConversationModel.fromJson(response);
  }
}

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return MessagingRepository(supabase);
});
