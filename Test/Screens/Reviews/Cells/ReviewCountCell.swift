//
//  ReviewCountCell.swift
//  Test
//
//  Created by Владимир Головин on 27.06.2025.
//

import UIKit

/// Конфигуратор ячейки количества отзывов
struct ReviewCountCellConfig {
    
    /// Идентификатор для переиспользования ячейки
    static let reuseId = String(describing: ReviewCountCellConfig.self)
    
    /// Текст количества отзывов
    let countText: NSAttributedString
}

// MARK: - TableCellConfig
extension ReviewCountCellConfig: TableCellConfig {
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.countLabel.attributedText = countText
    }
}

// MARK: - Cell

final class ReviewCountCell: UITableViewCell {
        private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    fileprivate let countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        countLabel.attributedText = nil
    }
    
    private func setupCell() {
        contentView.addSubview(countLabel)
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: insets.top),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: insets.left),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -insets.right),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
