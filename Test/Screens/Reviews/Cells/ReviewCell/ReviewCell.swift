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
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
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
        return UITableView.automaticDimension
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
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.insets.top),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.insets.right),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.insets.bottom)
        ])
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Constants = ReviewCell.Constants
