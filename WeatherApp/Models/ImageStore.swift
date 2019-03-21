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
        
        let cacheKey = key.lowercased()
        
        cache.setObject(image, forKey: cacheKey as NSString)
        
        let url = imageURL(forKey: cacheKey)
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            try? data.write(to: url)
        }
    }
    
    func image(forKey key: String)->UIImage? {
        
        let lowercasedKey = key.lowercased()
        
        if let imageFromCache = cache.object(forKey: lowercasedKey as NSString){
            return imageFromCache
        }
        
        let url = imageURL(forKey: lowercasedKey)
        
        guard let imageFromDisk = UIImage(contentsOfFile: url.path)  else {
            return nil
        }
        
        setImage(imageFromDisk, forKey: lowercasedKey)
        
        return imageFromDisk
    }
    
    func deleteImage(forKey key: String ) {
        
        let cacheKey = key.lowercased() as NSString

        cache.removeObject(forKey: cacheKey)
    }
    
    func imageURL(forKey key: String)->URL {
        
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    
}
