//
//  TerminalViewController.swift
//  WSDOT
//
//  Copyright (c) 2025 Washington State Department of Transportation
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
import SwiftyJSON
import Alamofire


class TerminalViewController: RefreshViewController, INDLinkLabelDelegate {
    
    var terminalItem: TerminalItem? = nil
    var ferriesTerminalItem: Int = 0
    
    fileprivate weak var timer: Timer?
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var terminalStackView: UIStackView!
    @IBOutlet weak var terminalLabel: INDLinkLabel!
    @IBOutlet weak var locationLabel: INDLinkLabel!
    @IBOutlet weak var ferryAlertBulletinsLabel: INDLinkLabel!
    @IBOutlet weak var categoryStack: UIStackView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var terminalStackConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Vessel Watch"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false

        self.terminalStackView.isHidden = true
        self.terminalStackConstraint.constant = -5

        self.categoryLabel.text = "Terminal Bulletins"
        self.categoryImage.image = UIImage(named: "terminal")

        if #available(iOS 14.0, *) {
            self.categoryStack.backgroundColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 0.2)
            self.categoryStack.layer.borderColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 1.0).cgColor
            self.categoryStack.layer.borderWidth = 1
            self.categoryStack.layer.cornerRadius = 4.0
        } else {
            let subView = UIView()
            subView.backgroundColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 0.2)
            subView.layer.borderColor = UIColor(red: 28/255, green: 120/255, blue: 205/255, alpha: 1.0).cgColor
            subView.layer.borderWidth = 1
            subView.layer.cornerRadius = 4.0
            subView.translatesAutoresizingMaskIntoConstraints = false
            categoryStack.insertSubview(subView, at: 0)
            subView.topAnchor.constraint(equalTo: categoryStack.topAnchor).isActive = true
            subView.bottomAnchor.constraint(equalTo: categoryStack.bottomAnchor).isActive = true
            subView.leftAnchor.constraint(equalTo: categoryStack.leftAnchor).isActive = true
            subView.rightAnchor.constraint(equalTo: categoryStack.rightAnchor).isActive = true
        }
        
        self.loadTerminalData()
        
        self.timer = Timer.scheduledTimer(timeInterval: CachesStore.terminalUpdateTime, target: self, selector: #selector(self.terminalTimerTask), userInfo: nil, repeats: true)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MyAnalytics.screenView(screenName: "TerminalView")
    }
    
    @objc func terminalTimerTask(_ timer:Timer) {
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.loadTerminalData()
        
    }
    
    @IBAction func refreshPressed(_ sender: UIBarButtonItem) {
        MyAnalytics.event(category: "TerminalView", action: "UIAction", label: "Refresh")
                
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.isHidden = false
        self.loadTerminalData()
        
    }
    
    
    func loadTerminalData() {
        
        let htmlStyleLight =
        "<style>*{font-family:'-apple-system';font-size:\(self.ferryAlertBulletinsLabel.font.pointSize)px;font:-apple-system-body}body{color:black}body strong{font-weight:bold}h1{font-weight:bold}a{color:#007a5d}a strong{color:#007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}.footnote{font:-apple-system-footnote;color:#3C3C4399}</style>"
        
        let htmlStyleDark =
        "<style>*{font-family:'-apple-system';font-size:\(self.ferryAlertBulletinsLabel.font.pointSize)px;font:-apple-system-body}body{color:white}body strong{font-weight:bold}h1{font-weight:bold}a{color:#007a5d}a strong{color:#007a5d}li{margin:10px 0}li:last-child{margin-bottom:25px}.footnote{font:-apple-system-footnote;color:#EBEBF599}</style>"
        
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            AF.request("https://www.wsdot.wa.gov/ferries/api/terminals/rest/terminalverbose?apiaccesscode=" + ApiKeys.getWSDOTKey()).validate().responseDecodable(of: TerminalStore.self) { response in
                
                switch response.result {
                
                case .success:
                    if let value = response.data {
                        let json = JSON(value)
                        let terminals = TerminalStore.parseTerminalsJSON(json)
                        let ferryAlerts = NSMutableAttributedString()

                        for terminal in terminals {
                            
                            if (terminal.terminalID == self.ferriesTerminalItem) {
                                
                                // Terminal Name
                                self.terminalLabel.text = terminal.terminalName + " Terminal"
                                self.terminalLabel.font = UIFont(descriptor: UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withSymbolicTraits(.traitBold)!, size: UIFont.preferredFont(forTextStyle: .title2).pointSize)
                                
                                // Terminal Address
                                if (terminal.addressLineOne != "") {
                                    let location = terminal.addressLineOne + "<br>" + terminal.city + " " + terminal.state + ", " + terminal.zipCode
                                                                                                            
                                    if self.traitCollection.userInterfaceStyle == .light {
                                        self.locationLabel.attributedText = try! NSMutableAttributedString(
                                            data: (htmlStyleLight + location).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                            documentAttributes: nil)
                                    }
                                    
                                    if self.traitCollection.userInterfaceStyle == .dark {
                                        self.locationLabel.attributedText = try! NSMutableAttributedString(
                                            data: (htmlStyleDark + location).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                            documentAttributes: nil)
                                    }
                                    
                                    self.locationLabel.font = UIFont.preferredFont(forTextStyle: .body)
                                    
                                }
                                else {
                                    self.locationLabel.isHidden = true
                                }
                                                            
                                if (!JSON(terminal.bulletins).arrayValue.isEmpty) {
                                   
                                    // Terminal Bulletins
                                    for item in JSON(terminal.bulletins).arrayValue {
                                        
                                        ferryAlerts.append(NSAttributedString(string: "\r\u{00A0} \u{0009} \u{00A0}\n\n", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.lightGray]))
                                        
                                        let alert = "<h1>" + item["BulletinTitle"].stringValue + "</h1>" + item["BulletinText"].stringValue.replacingOccurrences(of: "</a><br></li>\n<li>", with: "</a></li>\n<li>", options: .regularExpression, range: nil).replacingOccurrences(of: "<b><span data-contrast=\"none\">", with: "<span style=font-weight:bold>", options: .literal, range: nil) + "<span class=footnote>" + TimeUtils.timeAgoSinceDate(date: Date(timeIntervalSince1970: TimeInterval(item["BulletinLastUpdated"].stringValue.dropFirst(6).dropLast(10))!), numericDates: false) + "</span><br>"
                                                                                
                                        if self.traitCollection.userInterfaceStyle == .light {
                                            ferryAlerts.append(try! NSMutableAttributedString(
                                                data: (htmlStyleLight + alert).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                                options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                documentAttributes: nil))
                                        }
                                        
                                        if self.traitCollection.userInterfaceStyle == .dark {
                                            ferryAlerts.append(try! NSMutableAttributedString(
                                                data: (htmlStyleDark + alert).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                                options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                documentAttributes: nil)
                                            )
                                        }
                                    }
                                    
                                    ferryAlerts.append(NSAttributedString(string: "\r\u{00A0} \u{0009} \u{00A0}\n\n", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.lightGray]))
                                }
                                
                                else {
                                    
                                    ferryAlerts.append(NSAttributedString(string: "\r\u{00A0} \u{0009} \u{00A0}\n\n", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.lightGray]))

                                    let alert = "&bull; <strong>No Posted Bulletins</strong>"

                                    if self.traitCollection.userInterfaceStyle == .light {
                                        ferryAlerts.append(try! NSMutableAttributedString(
                                            data: (htmlStyleLight + alert).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                            documentAttributes: nil))
                                    }
                                    
                                    if self.traitCollection.userInterfaceStyle == .dark {
                                        ferryAlerts.append(try! NSMutableAttributedString(
                                            data: (htmlStyleDark + alert).data(using: String.Encoding.unicode, allowLossyConversion: false)!,
                                            options: [ NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                            documentAttributes: nil)
                                        )
                                    }
                                    
                                    ferryAlerts.append(NSAttributedString(string: "\n\r\u{00A0} \u{0009} \u{00A0}\n\n", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: UIColor.lightGray]))
                                }
                                    
                                    self.ferryAlertBulletinsLabel.attributedText = ferryAlerts
                                    self.ferryAlertBulletinsLabel.delegate = self
                            }
                        }
                        
                        self.activityIndicatorView.stopAnimating()
                        self.terminalStackView.isHidden = false
                        self.activityIndicatorView.isHidden = true
                        
                    }
                    
                case .failure(let error):
                    print(error)
                    AlertMessages.getConnectionAlert(backupURL: WsdotURLS.terminals, message: WSDOTErrorStrings.ferryTerminal)
                    
                    self.terminalStackView.isHidden = true
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                }
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.loadTerminalData()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed || self.isMovingFromParent {
            if timer != nil {
                self.timer?.invalidate()
            }
        }
    }
    
    // MARK: INDLinkLabelDelegate
    func linkLabel(_ label: INDLinkLabel, didLongPressLinkWithURL URL: Foundation.URL) {
        let activityController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }
    
    func linkLabel(_ label: INDLinkLabel, didTapLinkWithURL URL: Foundation.URL) {
     
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let svc = SFSafariViewController(url: URL, configuration: config)
        
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = ThemeManager.currentTheme().secondaryColor
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = ThemeManager.currentTheme().mainColor
        }
        self.present(svc, animated: true, completion: nil)
    }
    
}
