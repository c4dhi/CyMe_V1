//
//  DiscoverView.swift
//  CyMe
//
//  Created by Marinja Principe on 17.04.24.
//

import SwiftUI
import SigmaSwiftStatistics

let x = Sigma.average([1, 3, 8])
// Result: 4

struct DiscoverView: View {
    @ObservedObject var viewModel: DiscoverViewModel
    
    var body: some View {
        Text("This is the descover page \(x)")
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView(viewModel: DiscoverViewModel())
    }
}
