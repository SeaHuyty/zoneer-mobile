import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/features/messaging/models/conversation_with_user_model.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        ref
            .read(messagingViewModelProvider.notifier)
            .loadMyConversations(userId);
      }
    });
  }

  String _conversationTitle(ConversationWithUserModel conversation) {
    return conversation.otherUser.fullname;
  }

  static String formatConversationDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    final localDate = parsed.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(localDate.year, localDate.month, localDate.day);
    final differenceInDays = today.difference(messageDay).inDays;

    if (differenceInDays == 0) {
      return DateFormat('h:mm a').format(localDate);
    }

    if (differenceInDays == 1) {
      return 'Yesterday';
    }

    if (localDate.year == now.year) {
      return DateFormat('MMM d').format(localDate);
    }

    return DateFormat('MMM d, y').format(localDate);
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
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  conversation.conversation.lastMessagePreview ??
                      'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  formatConversationDate(
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
