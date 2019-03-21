//
//  ImageStore.swift
//  WeatherApp
//
//  Created by Peter on 21/03/2019.
//  Copyright © 2019 Excellence. All rights reserved.
//

import Foundation
import UIKit

class ImageStore {
    
    let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forKey key: String) {
        
        let cacheKey = key.lowercased() as NSString
        
        cache.setObject(image, forKey: cacheKey)
    }
    
    func image(forKey key: String)->UIImage? {
        
        let cacheKey = key.lowercased() as NSString
        
        return cache.object(forKey: cacheKey)
    }
    
    func deleteImage(forKey key: String ) {
        
        let cacheKey = key.lowercased() as NSString
        
        cache.removeObject(forKey: cacheKey)
    }
    
}
