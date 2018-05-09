//
//  NotificationTopicsViewController.swift
//  WSDOT
//
//  Copyright (c) 2018 Washington State Department of Transportation
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//

import UIKit
import UserNotifications

class NotificationTopicsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum AuthResult {
        case success(Bool), failure(Error)
    }
    
    let cellIdentifier = "TopicCell"
    
    var topicItems = [NotificationTopicItem]()
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notification Settings"
        
        self.tableView.layoutIfNeeded()
        self.topicItems = NotificationsStore.getTopics()
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
       
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
        
        self.tableView.layoutIfNeeded()
        refresh(true)
        
        self.tableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Notification Settings")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 10.0, *) {} else {
            NotificationCenter.default.addObserver(
                self,
                selector:#selector(NotificationTopicsViewController.applicationDidBecomeActiveNotification),
                name:NSNotification.Name.UIApplicationDidBecomeActive,
                object:nil)
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 10.0, *) {} else {
            NotificationCenter.default.removeObserver(
                self,
                name:NSNotification.Name.UIApplicationDidBecomeActive,
                object:nil)
        }
    }

    func applicationDidBecomeActiveNotification() {
        if UIApplication.shared.isRegisteredForRemoteNotifications {
            print("iOS 9 access is granted")
        } else {
            print("iOS 9 access is denied")
        }
    }

    func refresh(_ force: Bool) {
    
        showOverlay(self.view)
    
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            NotificationsStore.updateTopics(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.topicItems = NotificationsStore.getTopics()
                            selfValue.tableView.layoutIfNeeded()
                            selfValue.tableView.reloadData()

                            selfValue.tableView.layoutIfNeeded()
                            selfValue.hideOverlayView()
                            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, selfValue.tableView)
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self{
                            selfValue.hideOverlayView()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    func showOverlay(_ view: UIView) {
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.color = UIColor.gray
        
        if self.splitViewController!.isCollapsed {
            activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        } else {
            activityIndicator.center = CGPoint(x: view.center.x - self.splitViewController!.viewControllers[0].view.center.x, y: view.center.y - self.navigationController!.navigationBar.frame.size.height)
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    func hideOverlayView() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    // MARK: Table View Data Source Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SwitchCell
        
        let topicItem = topicItems[indexPath.row]
        
        cell.settingLabel.text = topicItem.title
        cell.settingSwitch.setOn(topicItem.subscribed, animated: false)
        cell.settingSwitch.params["topic"] = topicItem
        cell.settingSwitch.addTarget(self, action: #selector(NotificationTopicsViewController.changeSubscriptionPref(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func changeSubscriptionPref(_ sender: PassableUISwitch) {
    
        if #available(iOS 10.0, *) {
            checkAvailabilty { result in
                DispatchQueue.main.async { [weak self] in
                    if let selfValue = self{
                        switch result {
                            case .success(let granted) :
                                if granted {
                                    print("access is granted")
                            
                                    let topic = sender.params["topic"] as! NotificationTopicItem
        
                                    NotificationsStore.updateSubscription(topic, newValue: !topic.subscribed)
                                    GoogleAnalytics.event(category: "Notification", action: "", label: "")
                                } else {
                                    print("access is denied")
                                    selfValue.present(AlertMessages.getAcessDeniedAlert("Turn On Notifications", message: "Please allow notifications from Settings"), animated:     true, completion: nil)
                                }
                            case .failure(let error): print(error)
                        }
                    }
                }
            }
        } else {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                print("iOS 9 access is granted")
                
                let topic = sender.params["topic"] as! NotificationTopicItem
        
                NotificationsStore.updateSubscription(topic, newValue: !topic.subscribed)
                GoogleAnalytics.event(category: "Notification", action: "", label: "")
            } else {
                print("iOS 9 access is denied")
                self.present(AlertMessages.getAcessDeniedAlert("Turn On Notifications", message: "Please allow notifications from Settings"), animated: true, completion: nil)
            }
        }
    }

    @available(iOS 10,  *)
    func checkAvailabilty(completion: @escaping (AuthResult) -> ()) {

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {(granted, error) in
                if error != nil {
                    completion(.failure(error!))
                } else {
                    completion(.success(granted))
                }
        })
    }
}
