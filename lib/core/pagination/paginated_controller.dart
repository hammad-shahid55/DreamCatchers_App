import 'dart:collection';

import 'package:flutter/foundation.dart';

abstract class PaginatedController<T> extends ChangeNotifier {
  PaginatedController({required this.pageSize});

  final int pageSize;

  final List<T> _items = <T>[];
  late final UnmodifiableListView<T> items = UnmodifiableListView(_items);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasLoaded = false;
  bool _disposed = false;
  Object? _error;
  Object? _loadMoreError;

  int _generation = 0;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get hasLoaded => _hasLoaded;
  Object? get error => _error;
  Object? get loadMoreError => _loadMoreError;

  @protected
  Future<List<T>> fetchPage(List<T> loaded);

  @protected
  Object itemKey(T item);

  Future<void> loadInitial() async {
    if (_hasLoaded || _isLoading) return;
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _loadMoreError = null;
    notifyListeners();
    try {
      final page = await fetchPage(const []);
      if (generation != _generation) return;
      _items
        ..clear()
        ..addAll(page);
      _hasMore = page.length >= pageSize;
      _hasLoaded = true;
    } catch (e) {
      if (generation == _generation) _error = e;
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || !_hasLoaded) return;
    final generation = _generation;
    _isLoadingMore = true;
    _loadMoreError = null;
    notifyListeners();
    try {
      final page = await fetchPage(items);
      if (generation != _generation) return;
      final keys = _items.map(itemKey).toSet();
      _items.addAll(page.where((item) => keys.add(itemKey(item))));
      _hasMore = page.length >= pageSize;
    } catch (e) {
      if (generation == _generation) _loadMoreError = e;
    } finally {
      if (generation == _generation) {
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  @protected
  void insertFirst(T item) {
    final key = itemKey(item);
    _items
      ..removeWhere((existing) => itemKey(existing) == key)
      ..insert(0, item);
    notifyListeners();
  }

  @protected
  void updateWhere(bool Function(T item) test, T Function(T item) update) {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (test(_items[i])) {
        _items[i] = update(_items[i]);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  @protected
  void removeWhere(bool Function(T item) test) {
    final before = _items.length;
    _items.removeWhere(test);
    if (_items.length != before) notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
