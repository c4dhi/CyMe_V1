//
//  SymptomInsightsView.swift
//  CyMe
//
//  Created by Marinja Principe on 03.06.24.
//

// SymptomInsightsView.swift
// CyMe
//
// Created by Marinja Principe on 03.06.24.
//

import SwiftUI

struct SymptomInsightsView: View {
    var hints: [String]

    var body: some View {
        if hints.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(hints, id: \.self) { hint in
                    Text(hint)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SymptomInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        SymptomInsightsView(hints: ["Most frequent in period phase", "Second hint example"])
    }
}
