/// Состояния загрузки отзывов
enum LoadingState {
    /// Бездействие, загрузка не идет.
    case idle
    /// Идет первая, начальная загрузка.
    case initial
    /// Идет загрузка следующей страницы
    case pagination
}

/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = AppConstants.API.reviewsPageLimit
    var offset = 0
    var shouldLoad = true
    var loadingState: LoadingState = .idle
}
