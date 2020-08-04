//
//  StudentLocation.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 19/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import Foundation


struct StudentLocatin: Codable {
    
    let objectId: String?
    let uniqueKey: String?
    let firstName: String?
    let lastName: String?
    let mapString: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let createAt: Date?
    let updateAt: Date?
    let acl: String?

}



struct StudentLocations: Codable {
    var results: [StudentLocatin]
}




struct singleResult: Codable {
    var singleResult: StudentLocatin?
}
