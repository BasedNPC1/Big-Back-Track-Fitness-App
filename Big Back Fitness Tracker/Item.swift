//
//  Item.swift
//  Big Back Fitness Tracker
//
//  Created by Roberto Vela on 7/26/25.
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
