//
//  DriverTableRow.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct DriverTableRow: View {
    let driver: DriverState

    var body: some View {
        HStack(spacing: 12) {
            // Position
            Text("\(driver.position)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(width: 30, alignment: .center)

            // Driver Info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(driver.driverId.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("(\(driver.driverId.code))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text(driver.driverId.team)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Telemetry Data
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 16) {
                    VStack(alignment: .trailing) {
                        Text("Speed")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(driver.speed)) km/h")
                            .font(.caption)
                            .fontWeight(.medium)
                    }

                    VStack(alignment: .trailing) {
                        Text("Sector")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(driver.sector)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }

                // Tyre Info
                HStack(spacing: 8) {
                    Circle()
                        .fill(tyreColor(for: driver.tyre.compound.rawValue))
                        .frame(width: 12, height: 12)

                    Text("\(driver.tyre.compound) - \(driver.tyre.age) laps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    private func tyreColor(for compound: String) -> Color {
        switch compound.lowercased() {
        case "soft":
            return .red
        case "medium":
            return .yellow
        case "hard":
            return .white
        case "intermediate":
            return .green
        case "wet":
            return .blue
        default:
            return .gray
        }
    }
}

#Preview {
    let info: DriverInfo = .init(
        id: "HAM44",
        name: "Lewis Hamilton",
        code: "HAM",
        number: 44,
        team: "Ferrari",
        teamColorHex: "#ED1131",
        country: "GB"
    )

    let tyre: TyreState = .init(
        compound: .soft,
        age: 1,
        fresh: true
    )

    let state: DriverState = .init(
        driverId: info,
        lap: 1,
        position: 1,
        distance: 1,
        speed: 1,
        sector: 1,
        intervalToLeader: 0,
        intervalToAhead: 0,
        pitStatus: false,
        drsActive: false,
        tyre: tyre
    )

    DriverTableRow(driver: state)
}
