//
//  BindableResults.swift
//  WSDOT
//
//  Created by Logan Sims on 6/12/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import RealmSwift

@available(iOS 13.0, *)
class BindableResults<Element>: ObservableObject where Element: RealmSwift.RealmCollectionValue {

    var results: Results<Element>
    private var token: NotificationToken!

    init(results: Results<Element>) {
        self.results = results
        lateInit()
    }

    func lateInit() {
        token = results.observe { [weak self] _ in
            print("change!")
            self?.objectWillChange.send()
        }
    }

    deinit {
        token.invalidate()
    }
}
