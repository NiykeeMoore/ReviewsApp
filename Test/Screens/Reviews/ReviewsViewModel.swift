import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let imageLoader: ImageLoader
    private let decoder: JSONDecoder

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        imageLoader: ImageLoader,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.imageLoader = imageLoader
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        
        if state.offset == 0 {
            state.loadingState = .initial
        } else {
            state.loadingState = .pagination
        }
        
        onStateChange?(state)
        reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        state.loadingState = .idle
        
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)

            var updatedItems = state.items.filter { !($0 is ReviewCountCellConfig) }
            updatedItems += reviews.items.map(makeReviewItem)

            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count

            if !state.shouldLoad {
                let countText = pluralizedString(for: reviews.count)
                let attributedText = countText.attributed(
                    font: .reviewCount,
                    color: .reviewCount
                )
                let countItem = ReviewCountCellConfig(countText: attributedText)
                updatedItems.append(countItem)
            }
            
            state.items = updatedItems
        } catch {
            state.shouldLoad = true
        }
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let usernameText = "\(review.fullName)"
        let username = usernameText.attributed(font: .username)
        let ratingImage = ratingRenderer.ratingImage(review.rating)

        let item = ReviewItem(
            username: username,
            ratingImage: ratingImage,
            reviewText: reviewText,
            created: created,
            avatarUrl: review.avatarUrl,
            photoUrls: review.photoUrls,
            imageLoader: imageLoader,
            onTapShowMore: { [weak self] id in
                guard let self else { return }
                self.showMoreReview(with: id)
            }
        )
        return item
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}

private extension ReviewsViewModel {
    func pluralizedString(for count: Int) -> String {
        let lastTwoDigits = count % 100
        if (11...19).contains(lastTwoDigits) {
            return "\(count) отзывов"
        }

        let lastDigit = count % 10
        switch lastDigit {
        case 1:
            return "\(count) отзыв"
        case 2, 3, 4:
            return "\(count) отзыва"
        default:
            return "\(count) отзывов"
        }
    }
}
