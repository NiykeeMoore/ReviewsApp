import UIKit

extension NSAttributedString {

    /// Метод возвращает размер строки с данным ограничением по ширине `width` и высоте `height`.
    ///
    /// - Note: `.greatestFiniteMagnitude` значит, что ограничения по высоте нет.
    func boundingRect(width: CGFloat, height: CGFloat = .greatestFiniteMagnitude) -> CGRect {
        guard length > 0 else { return .zero }
        return boundingRect(
            with: CGSize(width: width, height: height),
            options: .usesLineFragmentOrigin,
            context: nil
        )
    }

    /// Метод проверяет, будет ли пуста строка, если удалить пробелы и переносы строк в начале и конце строки.
    func isEmpty(trimmingCharactersIn set: CharacterSet = .whitespacesAndNewlines) -> Bool {
        string.trimmingCharacters(in: set).isEmpty
    }

    /// Метод возвращает шрифт атрибутированной строки по индексу `location`.
    func font(at location: Int = .zero) -> UIFont? {
        guard length > 0 else { return nil }
        return attributes(at: location, effectiveRange: nil)[.font] as? UIFont
    }

}
