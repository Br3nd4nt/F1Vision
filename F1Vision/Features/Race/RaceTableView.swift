//
//  RaceTableView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct RaceTableView: View {
    @ObservedObject var viewModel: RaceViewModel

    var body: some View {
        VStack {
            if let currentSnapshot = viewModel.currentSnapshot {
                // Race Info Header
                RaceInfoHeader(snapshot: currentSnapshot)

                // Drivers Table
                DriversTable(drivers: currentSnapshot.driverStates)
            } else {
                Text("No race data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct RaceInfoHeader: View {
    let snapshot: RaceSnapshot

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Lap \(snapshot.lap)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(snapshot.timestamp)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("\(snapshot.driverStates.count) Drivers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)

            Divider()
        }
        .background(Color(.systemBackground))
    }
}

struct DriversTable: View {
    let drivers: [DriverState]

    var body: some View {
        List {
            ForEach(drivers.sorted(by: { $0.position < $1.position }), id: \.driverId.id) { driver in
                DriverTableRow(driver: driver)
            }
        }
        .listStyle(PlainListStyle())
    }
}
