import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import 'post.dart';

class PickedMedia {
  const PickedMedia({required this.file, required this.type, this.bytes});

  final XFile file;
  final PostMediaType type;

  final Uint8List? bytes;

  static const Map<String, String> _mimeTypes = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'heic': 'image/heic',
    'mp4': 'video/mp4',
    'mov': 'video/quicktime',
    'webm': 'video/webm',
    '3gp': 'video/3gpp',
  };

  String get extension {
    final name = file.name.isNotEmpty ? file.name : file.path;
    final dot = name.lastIndexOf('.');
    final ext = dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
    if (_mimeTypes.containsKey(ext)) return ext;
    return type == PostMediaType.image ? 'jpg' : 'mp4';
  }

  String get mimeType => file.mimeType ?? _mimeTypes[extension]!;
}
