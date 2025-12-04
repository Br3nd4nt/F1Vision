//
//  RaceInfoHeader.swift
//  F1Vision
//
//  Created by br3nd4nt on 08.09.2025.
//

import SwiftUI

struct RaceInfoHeader: View {
    @ObservedObject private var viewModel: RaceViewModel

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
//                    Text("Lap \(viewModel.currentSnapshot?.lap ?? 0)")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                    Text(snapshot.timestamp)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            Divider()
        }
        .background(Color(.systemBackground))
    }
}
