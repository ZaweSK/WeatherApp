//
//  Formatter.swift
//  
//
//  Created by Peter on 06/05/2019.
//

import Foundation

struct Formatter {
    
     static let brnoTimeZone = TimeZone(identifier: "Europe/Paris")
    
    static let fullDateWithTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = brnoTimeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let dateOnly:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}



