//
//  File.swift
//  BaiduTranslate
//
//  Created by xy on 2016/12/27.
//  Copyright © 2016年 xy. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

func getInterfaces() -> Bool {
//    guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
//        print("this must be a simulator, no interfaces found")
//        return false
//    }
//    guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
//        print("System error: did not come back as array of Strings")
//        return false
//    }
//    for interface in swiftInterfaces {
//        print("Looking up SSID info for \(interface)") // en0
//        guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface as CFString) else {
//            print("System error: \(interface) has no information")
//            return false
//        }
//        guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
//            print("System error: interface information is not a string-keyed dictionary")
//            return false
//        }
//        for d in SSIDDict.keys {
//            print("\(d): \(SSIDDict[d]!)")
//        }
//    }
    return true
}
