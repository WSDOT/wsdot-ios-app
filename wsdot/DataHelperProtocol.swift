//
//  DataHelperProtocol.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//

/*
    Defines methods all data helpers must provide
*/

import Foundation
protocol DataHelperProtocol {
    associatedtype T
    static func createTable() throws -> Void
    static func insert(item: T) throws -> Int64
    static func delete(item: T) throws -> Void
    static func findAll() throws -> [T]?
}
