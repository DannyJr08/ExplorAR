//
//  UIImageView+LoadImage.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 17/04/23.
//

import UIKit

extension UIImageView {
    func loadImage(from url: URL, completionHandler: ((Result<Void, Error>) -> Void)? = nil) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completionHandler?(.failure(error))
                    return
                }
                guard let data = data, let image = UIImage(data: data) else {
                    completionHandler?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])))
                    return
                }
                DispatchQueue.main.async {
                    self.image = image
                    completionHandler?(.success(()))
                }
            }.resume()
    }
}
