//
//  DietPlanModal.swift
//  Meal Reminder
//
//  Created by Karanbir Singh on 23/10/18.
//  Copyright © 2018 NA. All rights reserved.
//

import Foundation

class DietPlan:Codable{
    var diet_duration:Int64?
    var week_diet_data:WeekdaysMeal?
}

class WeekdaysMeal:Codable{
    var monday:[Meals]?
    var tuesday:[Meals]?
    var wednesday:[Meals]?
    var thursday:[Meals]?
    var friday:[Meals]?
    var saturday:[Meals]?
    var sunday:[Meals]?
}

class Meals:Codable{
    var food:String?
    var meal_time:String?
}
