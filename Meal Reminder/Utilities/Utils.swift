//
//  Utils.swift
//  Meal Reminder
//
//  Created by Karanbir Singh on 23/10/18.
//  Copyright © 2018 NA. All rights reserved.
//

import UIKit
import EventKit

extension UIViewController{
    func showAlert(title:String,message:String,action:((UIAlertAction) -> Void)?){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: action))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

enum Weekdays:String{
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    func getEKweekday()->EKWeekday{
        switch self {
        case .monday:
            return EKWeekday.monday
        case .tuesday:
            return EKWeekday.tuesday
        case .wednesday:
            return EKWeekday.wednesday
        case .thursday:
            return EKWeekday.thursday
        case .friday:
            return EKWeekday.friday
        case .saturday:
            return EKWeekday.saturday
        case .sunday:
            return EKWeekday.sunday
        
        }
    }
    
    func getIntegerValue()->Int{
        switch self {
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        case .sunday:
            return 1
            
        }
    }
}
