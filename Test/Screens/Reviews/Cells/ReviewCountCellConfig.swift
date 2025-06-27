//
//  ReviewCountCellConfig.swift
//  Test
//
//  Created by Владимир Головин on 27.06.2025.
//

import UIKit

// MARK: - Config

/// Конфигурация ячейки. Содержит данные для отображения в ячейке
struct ReviewCountCellConfig {
    
    /// Идентификатор для переиспользования ячейки
    static let reuseId = String(describing: ReviewCountCellConfig.self)
    
    /// Текст количества отзывов
    let countText: NSAttributedString
    
    /// Объект, хранящий посчитанные фреймы для ячейки
    fileprivate let layout = ReviewCountCellLayout()
}

// MARK: - TableCellConfig
extension ReviewCountCellConfig: TableCellConfig {
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCountCell else { return }
        cell.countLabel.attributedText = countText
        cell.config = self
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
}

// MARK: - Cell

final class ReviewCountCell: UITableViewCell {
    fileprivate var config: Config?
    
    fileprivate let countLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        countLabel.frame = layout.countLabelFrame
    }
}

// MARK: - Private

private extension ReviewCountCell {
    func setupCell() {
        setupCountCell()
    }
    
    func setupCountCell() {
        contentView.addSubview(countLabel)
        countLabel.textAlignment = .center
    }
}

// MARK: - Layout

private final class ReviewCountCellLayout {
    private(set) var countLabelFrame = CGRect.zero
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentWidth = maxWidth - insets.left - insets.right
        let labelSize = config.countText.boundingRect(width: contentWidth).size
        
        countLabelFrame = CGRect(
            x: insets.left,
            y: insets.top,
            width: contentWidth,
            height: labelSize.height
        )
        
        return insets.top + labelSize.height + insets.bottom
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCountCellConfig
fileprivate typealias Layout = ReviewCountCellLayout
