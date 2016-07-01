//
//  Consts.swift
//  WSDOT
//
//  Created by Logan Sims on 7/1/16.
//  Copyright © 2016 wsdot. All rights reserved.
//
enum DataAccessError: ErrorType {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}
