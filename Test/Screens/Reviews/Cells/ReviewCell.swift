import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Имя пользователя
    let username: NSAttributedString
    /// Изображение рейтинга
    let ratingImage: UIImage
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3. Сбрасывает кэш при изменении высоты.
    var maxLines = 3 {
        didSet {
            layout.invalidateLayoutCache()
        }
    }
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Аватар
    let avatarUrl: URL?
    /// Фото в отзыве
    let photoUrls: [URL]
    /// Сервис для загрузки картинок
    let imageLoader: ImageLoader
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.usernameLabel.attributedText = username
        cell.ratingImageView.image = ratingImage
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
        
        cell.loadAvatar(from: avatarUrl, using: imageLoader)
        cell.loadPhotos(from: photoUrls, using: imageLoader)
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate var currentAvatarUrl: URL?
    fileprivate let photosStackView = UIStackView()
    fileprivate let showMoreButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        usernameLabel.frame = layout.usernameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        photosStackView.frame = layout.photosStackViewFrame
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupAvatarImageView()
        setupUsernameLabel()
        setupRatingImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupPhotosStackView()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        
        let action = UIAction { [weak self] _ in
            guard
                let self,
                let id = self.config?.id
            else { return }
            
            self.config?.onTapShowMore(id)
        }
        showMoreButton.addAction(action, for: .touchUpInside)
    }
    
    func setAvatarPlaceholder() {
        avatarImageView.image = AppConstants.Placeholders.avatar
    }
    
    func loadAvatar(from url: URL?, using imageLoader: ImageLoader) {
        setAvatarPlaceholder()
        currentAvatarUrl = url
        
        guard let url else { return }

        imageLoader.loadImage(from: url) { [weak self] image in
            guard
                let self,
                self.currentAvatarUrl == url
            else {
                return
            }
            
            if let image {
                self.avatarImageView.image = image
                self.avatarImageView.backgroundColor = .clear
            } else {
                self.setAvatarPlaceholder()
            }
        }
    }
    
    func setupPhotosStackView() {
        contentView.addSubview(photosStackView)
        photosStackView.axis = .horizontal
        photosStackView.spacing = Layout.photosSpacing
    }
    
    func loadPhotos(from urls: [URL], using imageLoader: ImageLoader) {
            photosStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            photosStackView.isHidden = urls.isEmpty

            for url in urls {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = Layout.photoCornerRadius
                imageView.backgroundColor = .systemGray6

                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalToConstant: Layout.photoSize.width),
                    imageView.heightAnchor.constraint(equalToConstant: Layout.photoSize.height)
                ])

                imageLoader.loadImage(from: url) { image in
                    imageView.image = image
                }

                photosStackView.addArrangedSubview(imageView)
            }
        }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Кэш

    private var cachedHeight: CGFloat?
    
    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    fileprivate static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var photosStackViewFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    fileprivate static let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    /// Сбрасывает кэш лэйаута
    func invalidateLayoutCache() {
        cachedHeight = nil
    }
    
    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        if let cachedHeight = cachedHeight {
            return cachedHeight
        }

        let contentX = insets.left + Self.avatarSize.width + avatarToUsernameSpacing
        let contentWidth = maxWidth - contentX - insets.right
        
        var maxY = layoutTopBlock(config: config, contentX: contentX, contentWidth: contentWidth)
        
        maxY = layoutPhotosBlock(config: config, contentX: contentX, currentY: maxY)
        
        maxY = layoutBottomBlock(config: config, contentX: contentX, contentWidth: contentWidth, currentY: maxY)
        
        let finalHeight = maxY + insets.bottom
        cachedHeight = finalHeight
        return finalHeight
    }
    
}

// MARK: - Private methods Layout

private extension ReviewCellLayout {
    /// Верхний блок: аватар, имя, рейтинг
    func layoutTopBlock(config: Config, contentX: CGFloat, contentWidth: CGFloat) -> CGFloat {
        avatarImageViewFrame = CGRect(origin: CGPoint(x: insets.left, y: insets.top), size: Self.avatarSize)
        
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: contentX, y: insets.top),
            size: config.username.boundingRect(width: contentWidth).size
        )
        
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: contentX, y: usernameLabelFrame.maxY + usernameToRatingSpacing),
            size: config.ratingImage.size
        )
        
        return max(avatarImageViewFrame.maxY, ratingImageViewFrame.maxY)
    }
    
    /// Блок с фотографиями
    func layoutPhotosBlock(config: Config, contentX: CGFloat, currentY: CGFloat) -> CGFloat {
        var newY = currentY
        
        if !config.photoUrls.isEmpty {
            newY += ratingToPhotosSpacing
            let stackWidth = CGFloat(config.photoUrls.count) * Self.photoSize.width + CGFloat(config.photoUrls.count - 1) * Layout.photosSpacing
            photosStackViewFrame = CGRect(
                origin: CGPoint(x: contentX, y: newY),
                size: CGSize(width: stackWidth, height: Self.photoSize.height)
            )
            newY = photosStackViewFrame.maxY
        } else {
            photosStackViewFrame = .zero
        }
        
        return newY
    }
    
    /// Нижний блок: текст, кнопка, дата
    func layoutBottomBlock(config: Config, contentX: CGFloat, contentWidth: CGFloat, currentY: CGFloat) -> CGFloat {
        var newY = currentY
        var hasTextContent = false
        
        if !config.reviewText.isEmpty() {
            hasTextContent = true
            newY += photosToTextSpacing

            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            let actualTextHeight = config.reviewText.boundingRect(width: contentWidth).size.height
            let showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: contentX, y: newY),
                size: config.reviewText.boundingRect(width: contentWidth, height: currentTextHeight).size
            )
            newY = reviewTextLabelFrame.maxY

            if showShowMoreButton {
                newY += reviewTextToCreatedSpacing
                showMoreButtonFrame = CGRect(
                    origin: CGPoint(x: contentX, y: newY),
                    size: Self.showMoreButtonSize
                )
                newY = showMoreButtonFrame.maxY
            } else {
                showMoreButtonFrame = .zero
            }
        } else {
            reviewTextLabelFrame = .zero
            showMoreButtonFrame = .zero
        }

        if !config.created.isEmpty() {
            let spacing = hasTextContent ?
            (showMoreButtonFrame != .zero ? showMoreToCreatedSpacing : reviewTextToCreatedSpacing) :
            photosToTextSpacing
            
            newY += spacing

            createdLabelFrame = CGRect(
                origin: CGPoint(x: contentX, y: newY),
                size: config.created.boundingRect(width: contentWidth).size
            )
            newY = createdLabelFrame.maxY
        } else {
            createdLabelFrame = .zero
        }
        
        return newY
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
