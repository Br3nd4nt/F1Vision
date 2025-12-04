//
//  RaceTableView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct RaceTableView: View {
    @ObservedObject private var viewModel: RaceViewModel

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
//            if let currentSnapshot = viewModel.currentSnapshot {
//                // Race Info Header
//                RaceInfoHeader(viewModel: viewModel)
//
//                // Drivers Table
//                Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 6) {
//                    // Header
//                    GridRow {
//                        Text("Pos").bold()
//                            .frame(width: 30, alignment: .leading)
//                            .gridColumnAlignment(.leading)
//                        Text("Driver").bold()
//                        Text("Interval").bold()
//                        Text("Leader").bold()
//                        Text("Tyre").bold()
//                        Text("Speed").bold()
//                    }
//
//                    Divider()
//
//                    // Rows
////                    ForEach(currentSnapshot.driverStates) { driver in
////                        DriverTableRow(driver: driver)
////                    }
//                }
//                .padding(.horizontal)
//            } else {
//                Text("No race data available")
//                    .foregroundColor(.secondary)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
        }
    }
}
