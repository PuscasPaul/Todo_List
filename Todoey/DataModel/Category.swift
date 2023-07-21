//
//  Category.swift
//  Todoey
//
//  Created by Puscas Paul on 07.06.2023.
//

import Foundation
import RealmSwift


class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    // use () to initialize it as empty
    let items = List<Item>()
    
    
}
