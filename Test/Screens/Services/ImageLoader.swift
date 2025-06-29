//
//  ImageLoader.swift
//  Test
//
//  Created by Niykee Moore on 27.06.2025.
//

import UIKit

protocol ImageLoader {
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void)
}

final class ImageLoaderImpl: ImageLoader {
    
    // MARK: - Кэш
    
    /// Кэш для хранения загруженных изображений
    private let cache = NSCache<NSURL, UIImage>()
    
    // MARK: - ImageLoader
    
    /// Асинхронно загружает изображение по URL.
    ///
    /// - Parameters:
    ///   - url: URL-адрес изображения для загрузки.
    ///   - completion: Замыкание, которое вызывается по завершении с опциональным UIImage
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(cachedImage)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self,
                  error == nil,
                  let data = data,
                  let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.cache.setObject(image, forKey: url as NSURL)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
}
