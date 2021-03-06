//
//  Formatter.swift
//  
//
//  Created by Peter on 06/05/2019.
//

import Foundation

struct Formatter {
    
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    
    static let hour24: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        return formatter
    }()
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    
    func timeOnly()->String {
        let minute = Formatter.minute0x.string(from: self)
        let hour = Formatter.hour24.string(from: self)
        return "\(hour):\(minute)"
    }
    
}




