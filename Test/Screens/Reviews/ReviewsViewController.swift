import UIKit

/// Контроллер экрана отзывов
final class ReviewsViewController: UIViewController {
    /// Основная вью экрана
    private lazy var reviewsView: ReviewsView = {
        let view = ReviewsView()
        view.tableView.delegate = viewModel
        view.tableView.dataSource = viewModel
        return view
    }()
    
    /// ViewModel экрана
    private let viewModel: ReviewsViewModel
    /// Индикатор загрузки
    private let activityIndicator = UIActivityIndicatorView()
    
    // MARK: - Init
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        setupViewModel()
        viewModel.getReviews()
    }

    // MARK: - Private

    /// Настраивает и размещает индикатор загрузки
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.hidesWhenStopped = true
    }

    /// Настраивает обработку изменений состояния ViewModel
    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }

            switch state.loadingState {
            case .initial:
                self.activityIndicator.startAnimating()
                self.reviewsView.tableView.isHidden = true
            case .idle, .pagination:
                self.activityIndicator.stopAnimating()
                self.reviewsView.tableView.isHidden = false
            }

            self.reviewsView.tableView.reloadData()
        }
    }

}
