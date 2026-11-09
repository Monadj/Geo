//
//  Item.swift
//  Location
//
//  Created by MAY 01 on 26/10/26.
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
