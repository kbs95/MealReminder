//
//  ViewController.swift
//  Meal Reminder
//
//  Created by Karanbir Singh on 23/10/18.
//  Copyright © 2018 NA. All rights reserved.
//

import UIKit
import EventKit

class HomeViewController: UIViewController {

    @IBOutlet weak var plansTableView: UITableView!
    var dietPlan:DietPlan?
    var weekdaysMirrorObject:Mirror!
    let store = EKEventStore()
    var userReminders = [EKReminder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupTableView()
        populateDietPlan()
        getReminderAccess()
    }
    
    func setupTableView(){
        plansTableView.delegate = self
        plansTableView.dataSource = self
        plansTableView.separatorStyle = .none
        plansTableView.register(UINib(nibName: "MealsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "MealsHeaderTableViewIdentifier")
        plansTableView.register(UINib(nibName: "MealsDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "MealsDetailsCellIdentifier")
        let setReminderView = UIView(frame: CGRect(x: 0, y: 0, width: plansTableView.frame.width, height: 70))
        let label = UILabel()
        label.text = "Set Reminder"
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        let reminderSwitch = UISwitch()
        reminderSwitch.isOn = false
        reminderSwitch.translatesAutoresizingMaskIntoConstraints = false
        reminderSwitch.addTarget(self, action: #selector(reminderSwitch(sender:)), for: UIControl.Event.valueChanged)
        
        setReminderView.addSubview(label)
        setReminderView.addSubview(reminderSwitch)
        label.leadingAnchor.constraint(equalTo: setReminderView.leadingAnchor, constant: 25).isActive = true
        label.centerYAnchor.constraint(equalTo: setReminderView.centerYAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        reminderSwitch.trailingAnchor.constraint(equalTo: setReminderView.trailingAnchor, constant: -25).isActive = true
        reminderSwitch.centerYAnchor.constraint(equalTo: setReminderView.centerYAnchor).isActive = true
        reminderSwitch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        plansTableView.tableHeaderView = setReminderView
    }
    
    func populateDietPlan(){
        NetworkServiceManager.shared.fetchDietPlan { (plans) in
            self.dietPlan = plans
            var weekDayObj = WeekdaysMeal()
            weekDayObj = plans?.week_diet_data ?? WeekdaysMeal()
            self.weekdaysMirrorObject = Mirror(reflecting:weekDayObj)
            self.plansTableView.reloadData()
        }
    }
    
    func getReminderAccess(){
        store.requestAccess(to: EKEntityType.reminder, completion:
            {(granted, error) in
                if !granted {
                    print("Access to store not granted")
                }else{
                    print("Access granted")
                    self.removeReminders()
                }
        })
    }
    
    func setupNavigation(){
        title = "Diet Plan"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor(red:0.14, green:0.62, blue:0.52, alpha:1.0)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    @objc func reminderSwitch(sender:UISwitch){
        if sender.isOn{
            // reminder set
            setReminder()
        }else{
            // reminder is off
            removeReminders()
            self.showAlert(title: "Success!", message: "Reminder Disabled", action: nil)
        }
    }
    
    func setReminder(){
        weekdaysMirrorObject.children.forEach { (child) in
            if let values = child.value as? [Meals]{
                for meal in values{
                    // calculating exact time for reminder alarm
                    let currentDate = Date()
                    var dateComponents = DateComponents()
                    dateComponents = Calendar.current.dateComponents([Calendar.Component.year,Calendar.Component.month,Calendar.Component.day,Calendar.Component.weekday], from: currentDate)
                    dateComponents.setValue(Int(meal.meal_time?.components(separatedBy: ":")[0] ?? ""), for: Calendar.Component.hour)
                    dateComponents.setValue(Int(meal.meal_time?.components(separatedBy: ":")[1] ?? ""), for: Calendar.Component.minute)
                    let dayDifference = (Weekdays(rawValue: child.label ?? "")?.getIntegerValue() ?? 0) - (dateComponents.weekday ?? 0)
                    dateComponents.setValue(dateComponents.day! + (dayDifference < 0 ? (7 + dayDifference) : dayDifference), for: Calendar.Component.day)
                    let reminder = EKReminder(eventStore: store)
                    reminder.notes = "Get ready to eat \(meal.food ?? "") within 5 minutes."
                    reminder.title = "Time to eat!"
                    reminder.calendar = store.defaultCalendarForNewReminders()
                    reminder.alarms = [EKAlarm(absoluteDate: Calendar.current.date(byAdding: .minute, value: -5, to: Calendar.current.date(from: dateComponents)!)!)]
                    reminder.priority = 3
                    reminder.dueDateComponents = dateComponents
                    // reminder repeat operation
                    let recurrenceRule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, daysOfTheWeek: [EKRecurrenceDayOfWeek.init(Weekdays(rawValue: child.label ?? "")?.getEKweekday() ?? EKWeekday.monday)], daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: EKRecurrenceEnd(end: Calendar.current.date(byAdding: .day, value: 20, to: Calendar.current.date(from: dateComponents)!)!))
                    reminder.addRecurrenceRule(recurrenceRule)
                    do{
                        try store.save(reminder, commit: true)
                    }catch let err{
                        print(err)
                    }
                }
            }
        }
        self.showAlert(title: "Success!", message: "Reminder Set", action: nil)
    }
    
    func removeReminders(){
        // predicate for fetching all reminders
        let predicate = store.predicateForReminders(in: [store.defaultCalendarForNewReminders()!])
        store.fetchReminders(matching: predicate) { (reminders) in
            do{
                for reminder in reminders ?? []{
                    try self.store.remove(reminder, commit: true)
                }
            }catch let err{
                print(err)
            }
        }
    }

}

extension HomeViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealsDetailsCellIdentifier", for: indexPath) as? MealsDetailTableViewCell else{
            return UITableViewCell()
        }
        var data:Any!
        for (index,obj) in weekdaysMirrorObject.children.enumerated(){
            if index == indexPath.section{
                data = obj.value
                break
            }
        }
        cell.foodLabel.text = "Food : \((data as! [Meals])[indexPath.row].food ?? "")"
        cell.timeLabel.text = "Time : \((data as! [Meals])[indexPath.row].meal_time ?? "")"
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var data:Any!
        for (index,obj) in weekdaysMirrorObject.children.enumerated(){
            if index == section{
                data = obj.value
                break
            }
        }
        return (data as? [Meals])?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if weekdaysMirrorObject == nil{
            return 0
        }
        return 7
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealsHeaderTableViewIdentifier") as? MealsHeaderTableViewCell else{
            return UIView()
        }
        var headerData:String = ""
        for (index,obj) in weekdaysMirrorObject.children.enumerated(){
            if index == section{
                headerData = obj.label ?? ""
                break
            }
        }
        cell.dayLabel.text = "\(headerData.capitalized)'s Plan"
        cell.contentView.backgroundColor = .white
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
