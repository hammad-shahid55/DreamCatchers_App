import '../../../core/constants/app_constants.dart';
import '../../../core/pagination/paginated_controller.dart';
import '../../posts/controllers/post_actions_controller.dart';
import '../data/comment_repository.dart';
import '../models/comment.dart';

class CommentsController extends PaginatedController<Comment> {
  CommentsController({
    required this.postId,
    required CommentRepository repository,
    required PostActionsController postActions,
  }) : _repository = repository,
       _postActions = postActions,
       super(pageSize: AppConstants.commentsPageSize);

  final String postId;
  final CommentRepository _repository;
  final PostActionsController _postActions;

  bool _isSending = false;
  bool get isSending => _isSending;

  @override
  Future<List<Comment>> fetchPage(List<Comment> loaded) =>
      _repository.fetchComments(
        postId: postId,
        limit: pageSize,
        after: loaded.isEmpty ? null : loaded.last,
      );

  @override
  Object itemKey(Comment item) => item.id;

  Future<void> addComment({
    required String content,
    required String authorUsername,
    String? authorAvatarUrl,
  }) async {
    if (_isSending) return;
    _isSending = true;
    notifyListeners();
    try {
      final comment = await _repository.addComment(
        postId: postId,
        content: content,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
      );
      insertFirst(comment);
      _postActions.commentAdded(postId);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
