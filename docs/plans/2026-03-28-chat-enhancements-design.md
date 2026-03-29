# Design: Chat Enhancements, Message Filter & Icon Animation

**Date:** 2026-03-28
**Status:** Approved
**Branch:** enhance/profile-messages-inquiry

---

## Overview

Six enhancements to the messaging experience: a property summary card pinned in chat, individual message delete, conversation end, a conversation list filter, occupation pre-fill in inquiry, and the animated Messages nav icon.

---

## Pre-implementation (Already Done)

Supabase schema changes applied:

```sql
ALTER TABLE messages
  ADD COLUMN is_deleted boolean NOT NULL DEFAULT false,
  ADD COLUMN is_system  boolean NOT NULL DEFAULT false;

ALTER TABLE conversations
  ADD COLUMN status    text NOT NULL DEFAULT 'active',
  ADD COLUMN ended_by  uuid REFERENCES auth.users(id) ON DELETE SET NULL;
```

---

## 1 — Property Summary Card in Chat

**Placement:** Non-scrollable card pinned above the message list in `ChatScreen`.

**Card layout:**
```
┌──────────────────────────────────────────┐
│ [60×60 thumb]  House in Phnom Penh       │
│                $450 / mo                 │
│                📍 Street 123, BKK1       │
│  "This user wants to rent this property" │
└──────────────────────────────────────────┘
```

**Data needed:** `propertyName`, `propertyAddress`, `propertyThumbnail`, `propertyPrice`

**Changes required:**

### Repository
Extend `getMyConversations` select to also fetch `thumbnail` and `price` from properties:
```
property:properties!conversations_property_id_fkey(id, name, address, thumbnail, price)
```

### ConversationWithUserModel
Add two new nullable fields:
```dart
final String? propertyThumbnail;
final double? propertyPrice;
```
Parse from `json['property']`.

### ChatScreen constructor
Change from receiving only `conversationId` to receiving the full `ConversationWithUserModel`:
```dart
class ChatScreen extends ConsumerStatefulWidget {
  final ConversationWithUserModel conversationData;
  // conversationId accessed via conversationData.conversation.id!
}
```
Update all call sites (`ConversationListScreen`) to pass `conversationData` instead of `conversationId`.

**Files affected:**
- `lib/features/messaging/repositories/messaging_repository.dart`
- `lib/features/messaging/models/conversation_with_user_model.dart`
- `lib/features/messaging/views/screens/chat_screen.dart`
- `lib/features/messaging/views/screens/conversation_list_screen.dart`

---

## 2 — Individual Message Delete

**Trigger:** Long-press on a message bubble (only the sender's own messages).

**Behavior:**
- Shows a bottom sheet with a red "Delete message" option
- Confirmation dialog: "Delete this message? This cannot be undone."
- On confirm: `UPDATE messages SET is_deleted = true WHERE id = ?`
- The deleted message is replaced in the UI:
  - Sender sees: *"You deleted a message"* (grey, italic, no bubble background)
  - Receiver sees: *"X deleted a message"* (grey, italic, no bubble background)
- Realtime subscription already handles message updates — UI auto-refreshes

**Repository method to add:**
```dart
Future<void> deleteMessage(String messageId);
// UPDATE messages SET is_deleted = true WHERE id = messageId
```

**Files affected:**
- `lib/features/messaging/repositories/messaging_repository.dart`
- `lib/features/messaging/viewmodels/messaging_viewmodel.dart`
- `lib/features/messaging/views/screens/chat_screen.dart`

---

## 3 — End Conversation

**Trigger:** 3-dot `PopupMenuButton` in the ChatScreen header → "End conversation" option.

**Behavior:**
1. Confirmation dialog: "End this conversation? Neither party will be able to send new messages."
2. On confirm:
   - `UPDATE conversations SET status = 'ended', ended_by = currentUserId WHERE id = ?`
   - Insert a system message: `INSERT INTO messages (conversation_id, sender_id, body, is_system) VALUES (?, currentUserId, 'X has ended this conversation.', true)`
3. The system message appears in both users' chat as a centered grey pill (not a bubble)
4. The chat input field is hidden/replaced with *"This conversation has ended"* text
5. Realtime subscription picks up both the conversation update and the new system message automatically

**ConversationListScreen card:**
- Show an "Ended" grey badge when `conversation.status == 'ended'`

**Repository method to add:**
```dart
Future<void> endConversation(String conversationId, String endedBy, String endedByName);
```

**Files affected:**
- `lib/features/messaging/repositories/messaging_repository.dart`
- `lib/features/messaging/viewmodels/messaging_viewmodel.dart`
- `lib/features/messaging/views/screens/chat_screen.dart`
- `lib/features/messaging/models/conversation_model.dart` (add `status`, `endedBy` fields)
- `lib/features/messaging/models/conversation_with_user_model.dart`

---

## 4 — Conversation List Filter

**Placement:** Horizontal scrollable chip row below the AppBar in `ConversationListScreen`.

**Tabs:**

| Label | Filter Logic | Default |
|-------|-------------|---------|
| Active | `status == 'active'` AND propertyStatus != rented | ✅ Yes |
| Unread | `hasUnread == true` | |
| Ended | `status == 'ended'` OR propertyStatus == rented | |
| All | No filter | |

**Default: Active** — shows only actionable conversations, no historical clutter.

**Chip design:** Selected chip uses `AppColors.primary` background + white text. Unselected is grey outline. Unread count badge on chip label where relevant (e.g. `Unread (3)`).

**State:** Local `_selectedFilter` enum in `_ConversationListScreenState`. No provider needed — purely UI-side filtering of the already-loaded list.

```dart
enum ConversationFilter { active, unread, ended, all }
```

**Files affected:**
- `lib/features/messaging/views/screens/conversation_list_screen.dart`
- `lib/features/messaging/models/conversation_with_user_model.dart` (expose `status` via `conversation.status`)
- `lib/features/messaging/models/conversation_model.dart` (add `status` field from DB)

---

## 5 — Occupation Pre-fill in Inquiry

**File:** `lib/features/inquiry/views/inquiry.dart`

The form already has `_occupationController`. The `_prefillUserData()` method fills name, email, and phone but skips occupation. Add one line:

```dart
if (user.occupation?.isNotEmpty == true) {
  _occupationController.text = user.occupation!;
}
```

No schema change needed.

---

## 6 — Animated Messages Icon in Nav Bar

**File:** `lib/shared/widgets/google_nav_bar.dart`

Replace the static `Icons.chat_bubble_outline / Icons.chat_bubble` with the Lottie animation `assets/icons/system-solid-47-chat-hover-chat.json`.

**Changes:**
- Add `late AnimationController _messagesController;`
- Initialize in `initState()` with `duration: const Duration(milliseconds: 300)`
- Dispose in `dispose()`
- Replace the static icon `leading` with the same `ColorFiltered + Lottie.asset` pattern used by Home/Wishlist/Map/Profile tabs
- Play `_messagesController.forward(from: 0)` in `onTabChange` case 3
- Keep the unread red dot `Stack` overlay on top of the Lottie widget

---

## Affected Files Summary

| File | Change |
|------|--------|
| `lib/features/messaging/repositories/messaging_repository.dart` | Add thumbnail/price to property join; add `deleteMessage`, `endConversation` methods |
| `lib/features/messaging/models/conversation_with_user_model.dart` | Add `propertyThumbnail`, `propertyPrice`; expose `status` |
| `lib/features/messaging/models/conversation_model.dart` | Add `status`, `endedBy` fields |
| `lib/features/messaging/viewmodels/messaging_viewmodel.dart` | Add `deleteMessage`, `endConversation` actions |
| `lib/features/messaging/views/screens/chat_screen.dart` | Accept `ConversationWithUserModel`; property card; message delete; end conversation; system message rendering |
| `lib/features/messaging/views/screens/conversation_list_screen.dart` | Filter chips; Ended badge; pass `conversationData` to ChatScreen |
| `lib/features/inquiry/views/inquiry.dart` | Pre-fill occupation |
| `lib/shared/widgets/google_nav_bar.dart` | `_messagesController` + Lottie icon |
