//
//  Item.swift
//  IHeartKatakana
//
//  Created by Onur Orhon on 1/18/26.
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
