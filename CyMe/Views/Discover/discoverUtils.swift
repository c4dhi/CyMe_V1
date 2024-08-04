//
//  discoverUtils.swift
//  CyMe
//
//  Created by Marinja Principe on 22.07.2024.
//

import Foundation

func intensityToString(intensity: Double, questionType: QuestionType) -> String {
    switch questionType {
    case .amountOfhour:
        return "\(intensity) hours"
    case .emoticonRating:
        switch intensity {
        case 0.0:
            return "😭"
        case 1.0:
            return "😣"
        case 2.0:
            return "🤔"
        case 3.0:
            return "😌"
        case 4.0:
            return "🤩"
        default:
            return ""
        }
    case .menstruationEmoticonRating:
        switch intensity {
        case 0.0:
            return "None"
        case 1.0:
            return "🩸"
        case 2.0:
            return "🩸🩸"
        case 3.0:
            return "🩸🩸🩸"
        default:
            return ""
        }
    case .painEmoticonRating:
        switch intensity {
        case 0.0:
            return "None"
        case 1.0:
            return "😐"
        case 2.0:
            return "😣"
        case 3.0:
            return "😖"
        default:
            return ""
        }
    case .changeEmoticonRating:
        switch intensity {
        case 0.0:
            return "None"
        case 1.0:
            return "⬇"
        case 2.0:
            return "⬆"
        default:
            return ""
        }
    default:
        return "\(intensity)"
    }
}

func getAxisValues( questionType: QuestionType) -> [Int] {
    switch questionType {
    case .emoticonRating:
        return [0, 1, 2, 3, 4, 5] // todo can not switch axis emoticon :(
    case .menstruationEmoticonRating:
        return [0, 1, 2, 3, 4]
    case .changeEmoticonRating:
        return [0, 1, 2, 3]
    case .amountOfhour:
        return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    case .amountOfMin:
        return [0, 20, 40, 60, 80, 100, 120, 140, 160, 180, 200]
    case .amountOfSteps:
        return [0, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000]
    default:
        return [0, 1, 2, 3, 4]
    }
}
