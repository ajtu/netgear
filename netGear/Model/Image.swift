//
//  Image.swift
//  netGear
//
//  Created by Alvin Tu on 3/12/21.
//

import Foundation
struct Image: Decodable {
    let height: Int
    let width: Int
    let name: String
    let type: String
    let url: String
}
