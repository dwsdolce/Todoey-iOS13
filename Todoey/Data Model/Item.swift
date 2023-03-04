//
//  Item.swift
//  Todoey
//
//  Created by David Smith on 3/2/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted var title: String = ""
    @Persisted var done: Bool = false
    @Persisted var dateCreated: Date?
    @Persisted var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
