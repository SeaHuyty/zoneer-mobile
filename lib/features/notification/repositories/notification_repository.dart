import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zoneer_mobile/core/services/supabase_service.dart';
import 'package:zoneer_mobile/features/notification/models/notification_model.dart';

class NotificationRepository {
  final SupabaseService _supabase;

  NotificationRepository(this._supabase);

  Future<List<NotificationModel>> getNotificationsByUserId(
    String userId,
  ) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<NotificationModel> markAsRead(String notificationId) async {
    final response = await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .select()
        .single();

    return NotificationModel.fromJson(response);
  }

  Future<List<NotificationModel>> markAllAsRead(String userId) async {
    final response = await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .select();

    return (response as List)
        .map((e) => NotificationModel.fromJson(e))
        .toList();
  }

  Future<void> deleteOneNotification(String notificationId) async {
    await _supabase.from('notifications').delete().eq('id', notificationId);
  }

  Future<bool> deleteAllNotificationsByUserId(String userId) async {
    try {
      await _supabase.from('notifications').delete().eq('user_id', userId);

      return true;
    } catch (_) {
      return false;
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return NotificationRepository(supabase);
});
