//
//  AppConstants.swift
//  Test
//
//  Created by Niykee Moore on 27.06.2025.
//

import UIKit

/// Глобальные константы, используемые в приложении.
enum AppConstants {

    /// Константы, связанные с сетевыми запросами.
    enum API {
        static let reviewsResponseFileName = "getReviews.response"
        static let reviewsResponseFileExtension = "json"
        static let reviewsPageLimit = 20
    }

    /// Константы для изображений-плейсхолдеров.
    enum Placeholders {
        static let avatar = UIImage(named: "avatar_placeholder")
    }
}
