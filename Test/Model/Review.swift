import Foundation

/// Модель отзыва.
struct Review: Decodable {
    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// Аватар
    let avatarUrl: URL?
    /// Рейтинг
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Фотографии отзыва
    let photoUrls: [URL]
    /// Время создания отзыва
    let created: String
    /// Полное имя пользователя
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}
