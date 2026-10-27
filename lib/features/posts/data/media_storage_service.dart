import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../models/picked_media.dart';

class UploadedMedia {
  const UploadedMedia({required this.path, required this.publicUrl});

  final String path;
  final String publicUrl;
}

class MediaStorageService {
  const MediaStorageService(this._client);

  final SupabaseClient _client;

  StorageFileApi get _bucket =>
      _client.storage.from(SupabaseConfig.postMediaBucket);

  Future<UploadedMedia> upload({
    required String userId,
    required PickedMedia media,
  }) async {
    final size = await media.file.length();
    if (size > AppConstants.maxMediaBytes) {
      throw const AppException('File is too large. The limit is 50 MB.');
    }
    final bytes = media.bytes ?? await media.file.readAsBytes();
    final path =
        '$userId/${DateTime.now().microsecondsSinceEpoch}.${media.extension}';
    await _bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: media.mimeType,
        cacheControl: '31536000',
      ),
    );
    return UploadedMedia(path: path, publicUrl: _bucket.getPublicUrl(path));
  }

  Future<void> remove(String path) => _bucket.remove([path]);
}
