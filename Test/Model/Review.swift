/// Модель отзыва.
struct Review: Decodable {
    /// Имя
    let firstName: String
    /// Фамилия
    let lastName: String
    /// Рейтинг
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Полное имя пользователя
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case rating, text, created
    }
}
