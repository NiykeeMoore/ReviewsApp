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

        // Логика показа/скрытия showMoreButton
        let contentWidth = cell.contentStackView.frame.width > 0 ? cell.contentStackView.frame.width : UIScreen.main.bounds.width - 60 // запас
        let currentTextHeight = (reviewText.font()?.lineHeight ?? .zero) * CGFloat(maxLines)
        let actualTextHeight = reviewText.boundingRect(width: contentWidth).size.height
        let needsShowMore = maxLines != .zero && actualTextHeight > currentTextHeight
        cell.showMoreButton.isHidden = !needsShowMore

        // Динамический отступ между текстом и датой
        if cell.showMoreButton.isHidden {
            cell.contentStackView.setCustomSpacing(Constants.reviewTextToCreatedSpacing, after: cell.reviewTextLabel)
            cell.contentStackView.setCustomSpacing(0, after: cell.showMoreButton)
        } else {
            cell.contentStackView.setCustomSpacing(0, after: cell.reviewTextLabel)
            cell.contentStackView.setCustomSpacing(Constants.showMoreToCreatedSpacing, after: cell.showMoreButton)
        }
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
#warning("ne zabyd' dropnut' ety zalupu")
    fileprivate var config: Config?
    fileprivate var currentAvatarUrl: URL?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.Avatar.cornerRadius
        imageView.image = AppConstants.Placeholders.avatar
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.usernameToRatingSpacing
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    fileprivate lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    fileprivate lazy var ratingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    fileprivate lazy var reviewTextLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    fileprivate lazy var createdLabel = UILabel()
    
    fileprivate lazy var photosStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.Photos.spacing
        return stackView
    }()
    
    fileprivate lazy var showMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.contentVerticalAlignment = .fill
        
        let action = UIAction { [weak self] _ in
            guard
                let self,
                let id = self.config?.id
            else { return }
            
            self.config?.onTapShowMore(id)
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    fileprivate lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

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
        contentView.addSubview(contentStackView)
        setupHeaderStackView()
        setupPhotosStackView()
        setupReviewTextLabel()
        setupShowMoreButton()
        setupCreatedLabel()
        setupContentStackViewConstraints()

        contentStackView.setCustomSpacing(Constants.ratingToPhotosSpacing, after: headerStackView)
        contentStackView.setCustomSpacing(Constants.photosToTextSpacing, after: photosStackView)
        /// Между reviewTextLabel и showMoreButton — 0 тк кнопка примыкает к тексту
        contentStackView.setCustomSpacing(0, after: reviewTextLabel)
        contentStackView.setCustomSpacing(Constants.showMoreToCreatedSpacing, after: showMoreButton)
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.insets.left),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.insets.top),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.Avatar.size.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.Avatar.size.height)
        ])
    }
    
    func setupHeaderStackView() {
        headerStackView.addArrangedSubview(usernameLabel)
        headerStackView.addArrangedSubview(ratingImageView)
        contentStackView.addArrangedSubview(headerStackView)
    }
    
    func setupPhotosStackView() {
        photosStackView.axis = .horizontal
        photosStackView.spacing = Constants.Photos.spacing
        contentStackView.addArrangedSubview(photosStackView)
    }
    
    func setupReviewTextLabel() {
        contentStackView.addArrangedSubview(reviewTextLabel)
    }

    func setupCreatedLabel() {
        contentStackView.addArrangedSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentStackView.addArrangedSubview(showMoreButton)
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
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
    
    func loadPhotos(from urls: [URL], using imageLoader: ImageLoader) {
        photosStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        photosStackView.isHidden = urls.isEmpty

        for url in urls {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = Constants.Photos.cornerRadius
            imageView.backgroundColor = .systemGray6
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Constants.Photos.size.width),
                imageView.heightAnchor.constraint(equalToConstant: Constants.Photos.size.height)
            ])
            imageLoader.loadImage(from: url) { image in
                imageView.image = image
            }
            photosStackView.addArrangedSubview(imageView)
        }
    }

    func setupContentStackViewConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Constants.avatarToUsernameSpacing),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Кэш

    private var cachedHeight: CGFloat?
    
    // MARK: - Размеры

    private static let avatarSize = Constants.Avatar.size
    private static let avatarCornerRadius = Constants.Avatar.cornerRadius
    private static let photoCornerRadius = Constants.Photos.cornerRadius
    private static let photoSize = Constants.Photos.size
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

    private let insets = Constants.insets
    private let avatarToUsernameSpacing = Constants.avatarToUsernameSpacing
    private let usernameToRatingSpacing = Constants.usernameToRatingSpacing
    private let ratingToTextSpacing = Constants.ratingToTextSpacing
    private let ratingToPhotosSpacing = Constants.ratingToPhotosSpacing
    private let photosSpacing = Constants.Photos.spacing
    private let photosToTextSpacing = Constants.photosToTextSpacing
    private let reviewTextToCreatedSpacing = Constants.reviewTextToCreatedSpacing
    private let showMoreToCreatedSpacing = Constants.showMoreToCreatedSpacing


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
            let stackWidth = CGFloat(config.photoUrls.count) * Self.photoSize.width + CGFloat(config.photoUrls.count - 1) * Constants.Photos.spacing
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
fileprivate typealias Constants = ReviewCell.Constants
