part of 'template_search_cubit.dart';

class TemplateSearchCubit extends Cubit<TemplateSearchState> {
  final GetQuizzesUsecase _getQuizzes;
  Timer? _debounce;

  TemplateSearchCubit(this._getQuizzes) : super(const TemplateSearchInitial()) {
    _fetch(null);
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () => _fetch(query.trim().isEmpty ? null : query.trim()),
    );
  }

  Future<void> _fetch(String? query) async {
    emit(const TemplateSearchLoading());
    try {
      final results = await Future.wait([
        _getQuizzes(scope: 'mine', search: query),
        _getQuizzes(scope: 'global', search: query),
      ]);
      final mine = results[0];
      final global = results[1];
      final seen = <String>{};
      final merged = [
        ...mine,
        ...global,
      ].where((q) => seen.add(q.id)).toList();
      emit(TemplateSearchLoaded(merged));
    } catch (e) {
      emit(TemplateSearchError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

