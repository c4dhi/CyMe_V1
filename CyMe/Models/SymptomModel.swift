//
//  DiscoverModel.swift
//  CyMe
//
//  Created by Marinja Principe on 03.06.24.
//

import Foundation

struct SymptomModel: Identifiable, Hashable {
    let id = UUID() // Ke plan was das isch, muesi das setze (du hesch im Bispieu iwie o nid)?
    var title: String // 👍
    var cycleOverview: [Int] // Wäri da double ou ok (isch wahrschinlich augemeiner)
    var hints: [String] // 👍
    var min: Int // Da fändi wahrschinlich String besser weu je nach Symptom macht nid aues glich sinn (und me chönnt s Datum o grad dri due, süsch müesst me wahrschinlich mega afo ungerscheide im Frontend...
    var max: Int // Same
    var average: Int // Same
    var covariance: Float // 👍
    var covarianceOverview: [[Int]] // Eventuell o wieder Double
    var questionType: QuestionType // Chönntsch mer vllt schneu sege wo i die liste mit weles was isch finde?
}



