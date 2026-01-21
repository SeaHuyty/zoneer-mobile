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
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAsRead(notificationId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markAllNotificationAsRead(String userId) async {
    try {
      await ref.read(notificationRepositoryProvider).markAllAsRead(userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ref.read(notificationRepositoryProvider).deleteOneNotification(notificationId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteAllNotification(String userId) async {
    try {
      await ref.read(notificationRepositoryProvider).deleteAllNotificationsByUserId(userId);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
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
