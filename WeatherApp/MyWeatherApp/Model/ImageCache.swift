//
//  ImageCache.swift
//  MyWeatherApp
//
//  Created by Sreenivas Babu on 8/20/23.
//

import UIKit

class ImageCache {
  static let shared = ImageCache()
  private var cache: Dictionary<String, UIImage> = [:]

  func getImage(for url: URL) -> UIImage? {
    return cache[url.absoluteString]
  }

  func setImage(image: UIImage, for url: URL) {
    cache[url.absoluteString] = image
  }
}
