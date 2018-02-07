//
//  EventViewController.swift
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
import UIKit
import SafariServices

class EventViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var detailsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventItem = EventStore.getActiveEvent()
        if (eventItem != nil){
            self.title = eventItem!.title
            detailsTextView.sizeToFit()
            detailsTextView.isEditable = false
            detailsTextView.delegate = self
            detailsTextView.text = eventItem!.details
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleAnalytics.screenView(screenName: "/Event")
    }
 
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let svc = SFSafariViewController(url: URL, entersReaderIfAvailable: true)
        if #available(iOS 10.0, *) {
            svc.preferredControlTintColor = UIColor.white
            svc.preferredBarTintColor = ThemeManager.currentTheme().mainColor
        } else {
            svc.view.tintColor = Colors.tintColor
        }
        self.present(svc, animated: true, completion: nil)
        return false
    }
 
}
