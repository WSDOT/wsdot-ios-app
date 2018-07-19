//
//  I405ViewController.swift
//  WSDOT
//
//  Copyright (c) 2016 Washington State Department of Transportation
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
import Foundation
import UIKit
import SafariServices

class DynamicTollRatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {

    let cellIdentifier = "I405TollRatesCell"

    var stateRoute: String?
    var tollRates = [TollRateSignItem]()

    var directions = ["Northbound", "Southbound"]
    var selectedDirectionIndex = 0

    let refreshControl = UIRefreshControl()

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var directionButton: UIButton!
    
    var blackoutWindow = UIView()
    
    private lazy var view_PickerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.toolbarPicker)
        view.addSubview(self.picker)
        
        view.backgroundColor = UIColor.white
        return view
    }()

    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = Colors.paleGrey
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()

    private lazy var toolbarPicker: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        toolbar.barTintColor = ThemeManager.currentTheme().mainColor
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction(_:)))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        doneButton.tintColor = UIColor.white

        toolbar.setItems([flexButton, doneButton], animated: false)
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // refresh controller
        refreshControl.addTarget(self, action: #selector(BorderWaitsViewController.refreshAction(_:)), for: .valueChanged)
        
        directionButton.layer.cornerRadius = 8.0
        directionButton.setTitle(directions[selectedDirectionIndex], for: UIControlState())
        directionButton.accessibilityHint = "double tap to change travel direction"
        
        // self.view.addSubview(view_PickerContainer)
        self.view.addSubview(view_PickerContainer)
        
        // Add picker container constraints
        view_PickerContainer.heightAnchor.constraint(equalTo: picker.heightAnchor, multiplier: 1, constant: 40).isActive = true
        view_PickerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        view_PickerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        view_PickerContainer.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Add picker constraints
        picker.heightAnchor.constraint(equalToConstant: picker.bounds.height).isActive = true
        picker.widthAnchor.constraint(equalTo: view_PickerContainer.widthAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view_PickerContainer.bottomAnchor).isActive = true
 
        toolbarPicker.leadingAnchor.constraint(equalTo: view_PickerContainer.leadingAnchor).isActive = true
        toolbarPicker.trailingAnchor.constraint(equalTo: view_PickerContainer.trailingAnchor).isActive = true
        toolbarPicker.topAnchor.constraint(equalTo: view_PickerContainer.topAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: toolbarPicker.bottomAnchor, constant: 0).isActive = true
        
/*
        // set up black out window for when picker is visable
        let window = UIApplication.shared.keyWindow!
        blackoutWindow = UIView(frame: CGRect(x: window.frame.origin.x, y: window.frame.origin.y - self.view_PickerContainer.frame.height, width: window.frame.width, height: window.frame.height))
        blackoutWindow.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        blackoutWindow.isHidden = true
        window.addSubview(blackoutWindow);
*/
 
        tableView.addSubview(refreshControl)
        activityIndicator.startAnimating()
        refresh(true)
    }
    
    @objc func refreshAction(_ refreshControl: UIRefreshControl) {
        refresh(true)
    }
    
    func refresh(_ force: Bool){
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async { [weak self] in
            TollRatesStore.updateTollRates(force, completion: { error in
                if (error == nil) {
                    // Reload tableview on UI thread
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            if let route = selfValue.stateRoute {
                                selfValue.tollRates = TollRatesStore.getTollRatesByRoute(route: route)
                            }
                            selfValue.tableView.reloadData()
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.activityIndicator.isHidden = true
                            selfValue.refreshControl.endRefreshing()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        if let selfValue = self {
                            selfValue.refreshControl.endRefreshing()
                            selfValue.activityIndicator.stopAnimating()
                            selfValue.present(AlertMessages.getConnectionAlert(), animated: true, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
    @objc func doneAction(_ button: UIButton) {
        directionButton.isEnabled = true

        // Add picker container constraints
        UIView.animate(withDuration: 0.3, animations: {
            self.view_PickerContainer.frame.origin.y += self.view_PickerContainer.frame.height
        }, completion: { done in
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.directionButton)
            self.blackoutWindow.isHidden = true
        })
        
    }
    
    @IBAction func pickDirection(_ sender: UIButton) {

        directionButton.isEnabled = false

        // Add picker container constraints
        UIView.animate(withDuration: 0.3, animations: {
            self.view_PickerContainer.frame.origin.y -= self.view_PickerContainer.frame.height
        }, completion: { done in
        
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.picker)
            self.blackoutWindow.isHidden = false
        })
    }
    
    // MARK -- Picker delegate & data source
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return directions.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return directions[row]
    }
    
    // MARK -- TableView delegate
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tollRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! GroupRouteCell
        
        // Remove any RouteViews carried over from being recycled.
        for route in cell.dynamicRouteViews {
            route.removeFromSuperview()
        }
        cell.dynamicRouteViews.removeAll()
        
        let tollSign = tollRates[indexPath.row]
        
        var travelDirection = ""
        
        switch (tollSign.travelDirection.lowercased()) {
            case "n":
                travelDirection = "Northbound"
            break
            case "s":
                travelDirection = "Southbound"
            break
            case "e":
                travelDirection = "Eastbound"
            break
            case "w":
                travelDirection = "Westbound"
            break
            default:
                travelDirection = ""
        }
        
        cell.routeLabel.text = "\(tollSign.startLocationName) \(travelDirection) Entrance"
        
        // set up favorite button
        cell.favoriteButton.setImage(tollSign.selected ? UIImage(named: "icStarSmallFilled") : UIImage(named: "icStarSmall"), for: .normal)
        cell.favoriteButton.tintColor = ThemeManager.currentTheme().mainColor

        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(favoriteAction(_:)), for: .touchUpInside)
        
        var lastRouteView: RouteView? = nil
        
        for route in tollSign.trips {
        
            let routeView = RouteView.instantiateFromXib()
            
            routeView.translatesAutoresizingMaskIntoConstraints = false
            routeView.contentView.translatesAutoresizingMaskIntoConstraints = false
            routeView.titleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.updatedLabel.translatesAutoresizingMaskIntoConstraints = false
            routeView.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            
            routeView.titleLabel.text = "\(route.endLocationName) Exit"
            
            routeView.subtitleLabel.text = route.message
            
            routeView.updatedLabel.text = TimeUtils.timeAgoSinceDate(date: route.updatedAt, numericDates: true)
            
            // Since messages are displayed in place of tolls, if we have a message don't show the toll
            if (route.message == ""){
                routeView.valueLabel.text = "$" + String(format: "%.2f", locale: Locale.current, arguments: [route.toll])
            }
            
            cell.contentView.addSubview(routeView)
            
            let leadingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .leading, relatedBy: .equal, toItem: cell.routeLabel, attribute: .leading, multiplier: 1, constant: 0);
            cell.contentView.addConstraint(leadingSpaceConstraintForRouteView)
            
            let trailingSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .trailing, relatedBy: .equal, toItem: cell.contentView, attribute: .trailingMargin, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(trailingSpaceConstraintForRouteView)
            
            let topSpaceConstraintForRouteView = NSLayoutConstraint(item: routeView.contentView, attribute: .top, relatedBy: .equal, toItem: (lastRouteView == nil ? cell.routeLabel : lastRouteView!.updatedLabel), attribute: .bottom, multiplier: 1, constant: 8);
            cell.contentView.addConstraint(topSpaceConstraintForRouteView)
       
            if tollSign.trips.index(of: route) == tollSign.trips.index(of: tollSign.trips.last!) {
                let bottomSpaceConstraint = NSLayoutConstraint(item: routeView.updatedLabel, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: -16)
                cell.contentView.addConstraint(bottomSpaceConstraint)
                routeView.line.isHidden = true
            }
            
            cell.dynamicRouteViews.append(routeView)
            lastRouteView = routeView
            
        }

        cell.sizeToFit()
        
        return cell
        
    }

    // MARK: Favorite action
    @objc func favoriteAction(_ sender: UIButton) {
        let index = sender.tag
        let tollSign = self.tollRates[index]
        
        if (tollSign.selected){
            TollRatesStore.updateFavorite(tollSign, newValue: false)
            sender.setImage(UIImage(named: "icStarSmall"), for: .normal)
        }else {
            TollRatesStore.updateFavorite(tollSign, newValue: true)
            sender.setImage(UIImage(named: "icStarSmallFilled"), for: .normal)
        }
    }

}
