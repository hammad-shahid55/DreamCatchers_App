import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../data/post_repository.dart';
import '../models/picked_media.dart';
import '../models/post.dart';
import 'post_events.dart';

class CreatePostController extends ChangeNotifier {
  CreatePostController(
    this._repository,
    this._events, {
    this.editing,
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker() {
    title.text = editing?.title ?? '';
    text.text = editing?.content ?? '';
    title.addListener(_onTextChanged);
    text.addListener(_onTextChanged);
    _onTextChanged();
  }

  final PostRepository _repository;
  final PostEventBus _events;
  final ImagePicker _picker;

  final Post? editing;

  final TextEditingController title = TextEditingController();
  final TextEditingController text = TextEditingController();

  PickedMedia? _media;
  bool _isSubmitting = false;
  bool _hasText = false;

  bool get isEditing => editing != null;
  PickedMedia? get media => _media;
  bool get isSubmitting => _isSubmitting;
  bool get canSubmit =>
      !_isSubmitting &&
      (_hasText || _media != null || (editing?.hasMedia ?? false));

  void _onTextChanged() {
    final hasText = title.text.trim().isNotEmpty || text.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      _hasText = hasText;
      notifyListeners();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: AppConstants.imageMaxWidth,
      imageQuality: AppConstants.imageQuality,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    _media = PickedMedia(file: file, type: PostMediaType.image, bytes: bytes);
    notifyListeners();
  }

  Future<void> pickVideo(ImageSource source) async {
    final file = await _picker.pickVideo(
      source: source,
      maxDuration: AppConstants.maxVideoDuration,
    );
    if (file == null) return;
    _media = PickedMedia(file: file, type: PostMediaType.video);
    notifyListeners();
  }

  void removeMedia() {
    _media = null;
    notifyListeners();
  }

  Future<Post> submit({
    required String authorUsername,
    String? authorAvatarUrl,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      final original = editing;
      if (original != null) {
        final updated = await _repository.updatePost(
          original,
          title: title.text,
          content: text.text,
        );
        _events.emit(
          PostPatched(
            original.id,
            (p) => p.withText(title: updated.title, content: updated.content),
          ),
        );
        return updated;
      }
      final post = await _repository.createPost(
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        title: title.text,
        content: text.text,
        media: _media,
      );
      _events.emit(PostCreated(post));
      return post;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    title
      ..removeListener(_onTextChanged)
      ..dispose();
    text
      ..removeListener(_onTextChanged)
      ..dispose();
    super.dispose();
  }
}
