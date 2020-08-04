//
//  DataServices.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 19/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import Foundation


class DataServices {
    
    static let instance = DataServices()
    
   
    
    func getStudentLocations(handler: @escaping(_ studentLocation: [StudentLocatin]?, _ error: Error?)->()){
        
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation?limit=100&order=-updatedAt")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                handler(nil,error)
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                handler(nil,statusCodeError)
                return
            }
            if statusCode >= 200 && statusCode < 300 {

                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments])
                    guard let jsonDictionary = jsonObject as? [String:Any] else {return}
                    let resultList = jsonDictionary["results"] as? [[String:Any]]

                    guard let list = resultList else {return}

                    let dataObject = try JSONSerialization.data(withJSONObject: list, options: [])

                    let locations = try JSONDecoder().decode([StudentLocatin].self, from: dataObject)
                    handler(locations,nil)
                }catch {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    
    func postLocation (_ mapString : String!, _ mediaURL : String!,_ uniqueKey :String!, _ latitude : Double!,_ longitude : Double!,  completion: @escaping (StudentLocatin?, Error?) -> ()) {
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey ?? "?")\", \"firstName\": \"\("Aziz")\", \"lastName\": \"\("Aziz")\",\"mapString\": \"\(mapString ?? "?")\", \"mediaURL\": \"\(mediaURL ?? "?")\",\"latitude\": \(latitude ?? 0.00), \"longitude\": \(longitude ?? 0.00)}".data(using: .utf8)


        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                completion (nil, error)
                return
            }

            if statusCode >= 200 && statusCode < 300 {
                let studentLocation = try! JSONDecoder().decode(singleResult.self, from: data!)
                completion(studentLocation.singleResult, nil)
            }
        }
        task.resume()
    }
}
