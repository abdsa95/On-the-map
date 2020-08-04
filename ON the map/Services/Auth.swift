//
//  Auth.swift
//  ON the map
//
//  Created by Abdualziz Aljuaid on 19/05/2019.
//  Copyright © 2019 Abdualziz Aljuaid. All rights reserved.
//

import Foundation


class Auth {
    
    static let instance = Auth()
    
    
    
    
    func login(withEmail email: String! ,AndPassword password: String! ,handler: @escaping(_ status: Bool,_ key: String,_ error:  Error?)->()){
        
        let url = "https://onthemap-api.udacity.com/v1/session"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email!)\", \"password\": \"\(password!)\"}}".data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                handler(false,"",error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let  statusCodeError = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                
                handler(false, "", statusCodeError)
                return
            }
            
            if statusCode >= 200 && statusCode < 300 {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                
                do {
                    let loginJSONObject = try JSONSerialization.jsonObject(with: newData!, options: [.allowFragments])
                    
                    let loginDictionary = loginJSONObject as? [String:Any]
                    let account = loginDictionary?["account"] as? [String:Any]
                    let uinqueKey = account?["key"] as? String ?? " "
                
                    handler(true,uinqueKey,nil)
                }catch {
                    print(error)
                }
            } else{
                handler(false,"",nil)
            }
        }
        task.resume()
    }
    
    func logOut(handler: @escaping(_ status: Bool,_ key: String,_ error:  Error?)->()){
        
        var request = URLRequest(url: URL(string: "https://onthemap-api.udacity.com/v1/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
       
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                let error = NSError(domain: NSURLErrorDomain, code: 0, userInfo: nil)
                handler(false, "", error)
                return
            }
            if statusCode >= 200  && statusCode < 300 {
                
                
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range) /* subset response data! */
                
                let json = try! JSONSerialization.jsonObject(with: newData!, options: []) as? [String: Any]
                let accountDictionary = json?["account"] as? [String:Any]
                let uniqueKey = accountDictionary?["key"] as? String ?? ""
                
                handler(true,uniqueKey,nil)
            } else {
                handler(false,"",nil)
            }
        }
        task.resume()
        
    }
}

