import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_with_user_model.dart';
import 'package:zoneer_mobile/features/messaging/utils/message_date_formatter.dart';
import 'package:zoneer_mobile/features/messaging/viewmodels/messaging_viewmodel.dart';
import 'package:zoneer_mobile/features/messaging/views/screens/chat_screen.dart';
import 'package:zoneer_mobile/shared/widgets/navigation_back_button.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  RealtimeChannel? _conversationsChannel;
  Timer? _refreshDebounce;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      _currentUserId = userId;

      ref.read(messagingViewModelProvider.notifier).loadMyConversations(userId);
      _subscribeConversationUpdates(userId);
    });
  }

  void _queueRefresh() {
    final userId = _currentUserId;
    if (userId == null) {
      return;
    }

    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 200), () {
      ref
          .read(messagingViewModelProvider.notifier)
          .refreshMyConversations(userId);
    });
  }

  void _subscribeConversationUpdates(String userId) {
    _conversationsChannel = Supabase.instance.client
        .channel('conversation_list_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tenant_id',
            value: userId,
          ),
          callback: (_) {
            _queueRefresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'landlord_id',
            value: userId,
          ),
          callback: (_) {
            _queueRefresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'tenant_id',
            value: userId,
          ),
          callback: (_) {
            _queueRefresh();
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'conversations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'landlord_id',
            value: userId,
          ),
          callback: (_) {
            _queueRefresh();
          },
        )
        .subscribe();
  }

  String _conversationTitle(ConversationWithUserModel conversation) {
    return conversation.otherUser.fullname;
  }

  @override
  void dispose() {
    _refreshDebounce?.cancel();
    if (_conversationsChannel != null) {
      Supabase.instance.client.removeChannel(_conversationsChannel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversationAsync = ref.watch(messagingViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        leading: NavigationBackButton(),
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: conversationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        conversationId: conversation.conversation.id!,
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      (conversation.otherUser.profileUrl != null &&
                          conversation.otherUser.profileUrl!.isNotEmpty)
                      ? NetworkImage(conversation.otherUser.profileUrl!)
                      : null,
                  child:
                      (conversation.otherUser.profileUrl == null ||
                          conversation.otherUser.profileUrl!.isEmpty)
                      ? const Icon(Icons.person_outline)
                      : null,
                ),
                title: Text(
                  _conversationTitle(conversation),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  conversation.hasUnread
                      ? 'A new message'
                      : (conversation.conversation.lastMessagePreview ??
                            'No messages yet'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: conversation.hasUnread ? Colors.black : Colors.grey,
                    fontWeight: conversation.hasUnread
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: Text(
                  MessageDateFormatter.formatConversationDate(
                    conversation.conversation.lastMessageAt,
                  ),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
