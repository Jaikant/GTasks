//
//  LogErrorUtil.swift
//  GTasks
//
//  Created by Jai on 30/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

import Foundation

class LogError {
    class func log(message: String, filename : String = __FILE__, function: String = __FUNCTION__, line : Int = __LINE__) {
        var finalMsg = filename.lastPathComponent + "::" + function + "::" + message + "::"
        print(finalMsg)
        println(line)
    }
}


 var dateFormatter: NSDateFormatter? = {
    var _dateformatter = NSDateFormatter()
    _dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
    return _dateformatter
    } ()

var longDateFormatter: NSDateFormatter? = {
    var _dateformatter = NSDateFormatter()
    _dateformatter.dateStyle = NSDateFormatterStyle.LongStyle
    return _dateformatter
    } ()
