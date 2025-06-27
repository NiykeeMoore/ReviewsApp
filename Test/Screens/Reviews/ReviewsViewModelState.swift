/// Модель, хранящая состояние вью модели.
struct ReviewsViewModelState {

    var items = [any TableCellConfig]()
    var limit = AppConstants.API.reviewsPageLimit
    var offset = 0
    var shouldLoad = true

}
