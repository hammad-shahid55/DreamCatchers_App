import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/profile.dart';

class ProfileRepository {
  const ProfileRepository(this._client);

  final SupabaseClient _client;

  StorageFileApi get _avatars =>
      _client.storage.from(SupabaseConfig.avatarsBucket);

  Future<Profile> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select(Profile.selectColumns)
        .eq('id', userId)
        .single();
    return Profile.fromJson(row);
  }

  Future<bool> isUsernameAvailable(String username) async {
    final result = await _client.rpc(
      'is_username_available',
      params: {'p_username': username.trim()},
    );
    return result == true;
  }

  Future<String> updateAvatar({
    required String userId,
    required XFile image,
    String? previousUrl,
  }) async {
    if (await image.length() > AppConstants.maxAvatarBytes) {
      throw const AppException('Photo is too large. The limit is 5 MB.');
    }
    final name = image.name.toLowerCase();
    final isPng = name.endsWith('.png');
    final path =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.${isPng ? 'png' : 'jpg'}';
    await _avatars.uploadBinary(
      path,
      await image.readAsBytes(),
      fileOptions: FileOptions(
        contentType: isPng ? 'image/png' : 'image/jpeg',
        cacheControl: '31536000',
      ),
    );
    final url = _avatars.getPublicUrl(path);
    try {
      await _setAvatarUrl(userId, url);
    } catch (_) {
      await _safeRemove(path);
      rethrow;
    }
    await _removeOwnFile(previousUrl);
    return url;
  }

  Future<void> removeAvatar({
    required String userId,
    String? currentUrl,
  }) async {
    await _setAvatarUrl(userId, null);
    await _removeOwnFile(currentUrl);
  }

  Future<void> _setAvatarUrl(String userId, String? url) =>
      _client.from('profiles').update({'avatar_url': url}).eq('id', userId);

  Future<void> _removeOwnFile(String? url) async {
    const marker = '/object/public/${SupabaseConfig.avatarsBucket}/';
    final index = url?.indexOf(marker) ?? -1;
    if (url == null || index == -1) return;
    await _safeRemove(
      Uri.decodeComponent(url.substring(index + marker.length)),
    );
  }

  Future<void> _safeRemove(String path) async {
    try {
      await _avatars.remove([path]);
    } catch (_) {}
  }
}
