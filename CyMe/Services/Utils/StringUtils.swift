//
//  StringUtils.swift
//  CyMe
//
//  Created by Deborah on 27.06.2024.
//

import Foundation

func displayDateDictionary(dict: [Date : Any]){
    for consideredDate in dict.keys.sorted(){
        print(DateFormatter.localizedString(from: consideredDate, dateStyle: .short, timeStyle: .none), terminator: "")
        if let value = dict[consideredDate]{
            print(": \(value) ")}
        else {print("There is a problem with displaying dict objects")}
    }
}


func oxfordComma(list: [Any]) -> String{
    if list.count == 0 {
        return ""
    }
    if list.count == 1 {
        return "\(list[0])"
    }
    if list.count == 2 {
        return "\(list[0]) and \(list[1])"
    }
    
    else {
        var output = ""
        for elem in list[0...list.count-3]{
            output += "\(elem), "
        }
        output += "\(list[list.count-2]) and \(list[list.count-1])"
        
        return output
    }
}
