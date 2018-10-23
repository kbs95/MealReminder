//
//  NetworkServiceManager.swift
//  Meal Reminder
//
//  Created by Karanbir Singh on 23/10/18.
//  Copyright © 2018 NA. All rights reserved.
//

import Foundation

class NetworkServiceManager{
    static let shared = NetworkServiceManager()
    private let dietPlanUrl = "https://naviadoctors.com/dummy/"
    
    
    private init(){
    }
    
    func fetchDietPlan(completion: @escaping (_ response:DietPlan?)->()){
        URLSession.shared.dataTask(with: URL(string: dietPlanUrl)!) { (data, response, err) in
            if let jsonData = data,err == nil{
                DispatchQueue.main.async {
                    completion(try! JSONDecoder.init().decode(DietPlan.self, from: jsonData))
                }
            }else{
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
}
