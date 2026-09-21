//
//  Item.swift
//  Week2
//
//  Created by MAY 01 on 21/9/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
