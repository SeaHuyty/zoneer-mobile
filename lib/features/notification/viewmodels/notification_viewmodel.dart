import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/features/notification/models/notification_model.dart';
import 'package:zoneer_mobile/features/notification/repositories/notification_repository.dart';

class NotificationViewmodel
    extends Notifier<AsyncValue<List<NotificationModel>>> {
  @override
  AsyncValue<List<NotificationModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadNotifications(String userId) async {
    state = const AsyncValue.loading();
    try {
      final notifications = await ref
          .read(notificationRepositoryProvider)
          .getNotificationsByUserId(userId);
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadUnreadNotifications(String userId) async {
    state = const AsyncValue.loading();
    try {
      final notifications = await ref
          .read(notificationRepositoryProvider)
          .getUnreadNotifications(userId);
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);

      final currentState = state;
      if (currentState is AsyncData<List<NotificationModel>>) {
        state = AsyncValue.data(
          currentState.value
              .map((n) => n.id == notificationId ? n.copyWith(isRead: true) : n)
              .toList(),
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead(userId);

      final currentState = state;
      if (currentState is AsyncData<List<NotificationModel>>) {
        state = AsyncValue.data(
          currentState.value.map((n) => n.copyWith(isRead: true)).toList(),
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final currentState = state;

    try {
      await ref
          .read(notificationRepositoryProvider)
          .deleteOneNotification(notificationId);

      if (currentState is AsyncData<List<NotificationModel>>) {
        state = AsyncValue.data(
          currentState.value.where((n) => n.id != notificationId).toList(),
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAllNotifications(String userId) async {
    try {
      final success = await ref
          .read(notificationRepositoryProvider)
          .deleteAllNotificationsByUserId(userId);
      
      if (!success) {
        state = AsyncValue.error(
          'Failed to delete all notifications',
          StackTrace.current,
        );
        return;
      }

      state = const AsyncValue.data([]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final notificationsViewModelProvider =
    NotifierProvider<
      NotificationViewmodel,
      AsyncValue<List<NotificationModel>>
    >(() {
      return NotificationViewmodel();
    });
