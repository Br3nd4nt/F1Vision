//
//  RaceInfoHeader.swift
//  F1Vision
//
//  Created by br3nd4nt on 08.09.2025.
//

import SwiftUI

struct RaceInfoHeader: View {
    let snapshot: RaceSnapshot

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Lap \(snapshot.lap)")
                        .font(.title2)
                        .fontWeight(.bold)
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
