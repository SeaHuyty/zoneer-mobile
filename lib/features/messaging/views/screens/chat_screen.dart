import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zoneer_mobile/core/utils/app_colors.dart';
import 'package:zoneer_mobile/features/messaging/models/chat_user_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_model.dart';
import 'package:zoneer_mobile/features/messaging/models/message_with_sender_model.dart';
import 'package:zoneer_mobile/features/messaging/utils/message_date_formatter.dart';
import 'package:zoneer_mobile/features/messaging/viewmodels/messaging_viewmodel.dart';
import 'package:zoneer_mobile/shared/widgets/navigation_back_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  RealtimeChannel? _messagesChannel;
  int _lastRenderedMessageCount = -1;
  bool _didInitialAutoScroll = false;

  void _scrollToBottom({required bool animated}) {
    if (!_scrollController.hasClients) {
      return;
    }

    final target = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  void _scrollToBottomWhenReady({required bool animated, int retries = 6}) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      if (_scrollController.hasClients) {
        _scrollToBottom(animated: animated);
        return;
      }

      if (retries > 0) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        _scrollToBottomWhenReady(animated: animated, retries: retries - 1);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

      if (currentUserId.isNotEmpty) {
        ref
            .read(messagingViewModelProvider.notifier)
            .markConversationRead(widget.conversationId, currentUserId);
      }

      _messagesChannel = Supabase.instance.client
          .channel('messages_${widget.conversationId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: widget.conversationId,
            ),
            callback: (_) async {
              if (!mounted) {
                return;
              }

              if (currentUserId.isNotEmpty) {
                await ref
                    .read(messagingViewModelProvider.notifier)
                    .markConversationRead(widget.conversationId, currentUserId);
              }

              if (!mounted) {
                return;
              }

              ref.invalidate(
                messagesByConversationProvider(widget.conversationId),
              );

              _scrollToBottomWhenReady(animated: true);
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'conversation_id',
              value: widget.conversationId,
            ),
            callback: (_) {
              if (!mounted) {
                return;
              }

              ref.invalidate(
                messagesByConversationProvider(widget.conversationId),
              );
            },
          )
          .subscribe();
    });
  }

  ChatUserModel? _findOtherUser(
    List<MessageWithSenderModel> messages,
    String currentUserId,
  ) {
    for (final item in messages) {
      if (item.sender.id != currentUserId) {
        return item.sender;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_messagesChannel != null) {
      Supabase.instance.client.removeChannel(_messagesChannel!);
    }
    super.dispose();
  }

  Future<void> _sendMessage(String currentUserId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || currentUserId.isEmpty) {
      return;
    }

    await ref
        .read(messagingViewModelProvider.notifier)
        .sendMessage(
          MessageModel(
            conversationId: widget.conversationId,
            senderId: currentUserId,
            body: text,
          ),
        );

    _messageController.clear();
    ref.invalidate(messagesByConversationProvider(widget.conversationId));
    _scrollToBottomWhenReady(animated: true);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final messagesAsync = ref.watch(
      messagesByConversationProvider(widget.conversationId),
    );

    return Scaffold(
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (messages) {
          if (messages.isNotEmpty &&
              messages.length != _lastRenderedMessageCount) {
            final isInitialLoad = !_didInitialAutoScroll;
            _lastRenderedMessageCount = messages.length;
            _didInitialAutoScroll = true;
            _scrollToBottomWhenReady(animated: !isInitialLoad);
          }

          final firstOther = _findOtherUser(messages, currentUserId);

          return Column(
            children: [
              if (firstOther != null)
                ListTile(
                  leading: NavigationBackButton(),
                  title: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            (firstOther.profileUrl != null &&
                                firstOther.profileUrl!.isNotEmpty)
                            ? NetworkImage(firstOther.profileUrl!)
                            : null,
                        child:
                            (firstOther.profileUrl == null ||
                                firstOther.profileUrl!.isEmpty)
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          firstOther.fullname,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),

              /// Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final msg = item.message;
                    final previousMessage = index > 0
                        ? messages[index - 1].message
                        : null;
                    final showDayHeader =
                        index == 0 ||
                        MessageDateFormatter.isDifferentDay(
                          msg.createdAt,
                          previousMessage?.createdAt,
                        );
                    final isMe = msg.senderId == currentUserId;

                    return Column(
                      children: [
                        if (showDayHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  MessageDateFormatter.formatDayHeader(
                                    msg.createdAt,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 16),
                                  ),
                                ),
                                child: Text(
                                  msg.body,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),

                              /// Time + Read status
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    MessageDateFormatter.formatMessageTime(
                                      msg.createdAt,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 5),
                                    Icon(
                                      msg.readAt != null
                                          ? Icons.done_all
                                          : Icons.check,
                                      size: 14,
                                      color: msg.readAt != null
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// Input field
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        onPressed: () => _sendMessage(currentUserId),
                        icon: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
