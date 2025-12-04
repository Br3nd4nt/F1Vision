//
//  RaceTableView.swift
//  F1Vision
//
//  Created by br3nd4nt on 04.12.2025.
//

import SwiftUI

struct RaceTableView: View {
    @ObservedObject private var viewModel: RaceViewModel

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        if viewModel.isLoaded {
            Table(viewModel.drivers) {
                TableColumn("position", value: \.positionString)
                    .width(80)
                TableColumn("driver", value: \.name)
                TableColumn("speed", value: \.speedSring)
                TableColumn("gear", value: \.gearString)
            }
        } else {
            EmptyView()
        }
    }
}
