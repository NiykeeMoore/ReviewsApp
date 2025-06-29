//
//  Constants.swift
//  Test
//
//  Created by Niykee Moore on 29.06.2025.
//

import UIKit

extension ReviewCell {

    enum Constants {
        // MARK: - Layout
        
        /// Отступы от краев ячейки до ее содержимого.
        static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
        
        /// Горизонтальный отступ от аватара до блока с текстом.
        static let avatarToUsernameSpacing: CGFloat = 10.0
        /// Вертикальный отступ от имени пользователя до рейтинга.
        static let usernameToRatingSpacing: CGFloat = 6.0
        /// Вертикальный отступ от рейтинга до фотографий.
        static let ratingToPhotosSpacing: CGFloat = 10.0
        /// Вертикальный отступ от рейтинга до текста отзыва (если фото нет).
        static let ratingToTextSpacing: CGFloat = 6.0
        /// Вертикальный отступ от фотографий до текста отзыва.
        static let photosToTextSpacing: CGFloat = 10.0
        /// Вертикальный отступ от текста отзыва до кнопки "Показать полностью...".
        static let reviewTextToCreatedSpacing: CGFloat = 6.0
        /// Вертикальный отступ от кнопки "Показать полностью..." до даты.
        static let showMoreToCreatedSpacing: CGFloat = 6.0

        // MARK: - Avatar
        
        enum Avatar {
            static let size = CGSize(width: 36.0, height: 36.0)
            static let cornerRadius: CGFloat = 18.0
        }
        
        // MARK: - Photos
        
        enum Photos {
            static let size = CGSize(width: 55.0, height: 66.0)
            static let cornerRadius: CGFloat = 8.0
            static let spacing: CGFloat = 8.0
        }
    }
}
