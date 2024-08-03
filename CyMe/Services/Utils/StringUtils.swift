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
    
func getTimeRepresentationFromString(timeString: String) -> Int {
    let regex = try! NSRegularExpression(pattern: "(\\d+) hours (\\d+) minutes")
    let nsString = timeString as NSString
    
    if let match = regex.firstMatch(in: timeString, range: NSRange(location: 0, length: nsString.length)) {
        let hoursString = nsString.substring(with: match.range(at: 1))
        let minutesString = nsString.substring(with: match.range(at: 2))
        
        if let hours = Int(hoursString), let minutes = Int(minutesString) {
            return (hours * 60) + minutes
        } else {
            print("Failed to convert extracted strings to integers.")
        }
    } else {
        print("No match found in the string.")
        
    }
    return -1
}

func sleepSecondsToHours(seconds : Int?) -> Int?{
    if seconds == nil{
        return nil
    }
    else{
        let seconds = Double(seconds!)
        
        let sec = seconds.truncatingRemainder(dividingBy: 60)
        let min_incl_h = (seconds - sec)/60
        let min = min_incl_h.truncatingRemainder(dividingBy: 60)
        var hours = (min_incl_h - min)/60
        
        if min > 30 {
            hours += 1
        }
                
        return Int(hours)
    }
}
