//
//  Manifest.swift
//  netGear
//
//  Created by Alvin Tu on 3/12/21.
//

import Foundation

struct Manifest: Decodable{
    var structure: [[String]]?
    
    enum CodingKeys: String, CodingKey {
        case structure = "manifest"
    }
}


struct ImageGroup {
    let imageIdentifiers : [String]
}


struct ImageError:Decodable {
    let error : String
}




