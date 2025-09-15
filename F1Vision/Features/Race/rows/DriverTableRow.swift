//
//  DriverTableRow.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct DriverTableRow: View {
    let driver: DriverState

    var positionTextToDisplay: String {
        if driver.position < 10 {
            return "\(driver.position) "
        }
        return "\(driver.position)"
    }
    var interval: String {
        if let time = driver.intervalToAhead {
            return "+\(time)"
        }
        return "leader"
    }
    var leader: String {
        if let time = driver.intervalToLeader {
            return "+\(time)"
        }
        return "leader"
    }

    var body: some View {
        GridRow {
            positionNumber
                .frame(width: 28, alignment: .trailing)
            driverInfo
            intervalView
            leaderView
            tyreView
            speedView
        }
        .background(Configuration.debugMode ? Color.blue.opacity(0.2) : Color.clear)
        .background(Color(.systemBackground))
    }

    // MARK: - elements
    var positionNumber: some View {
        Text(positionTextToDisplay)
            .font(.system(.title2, design: .monospaced))
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .frame(width: 28, alignment: .trailing)
            .background(Configuration.debugMode ? Color.green.opacity(0.5) : Color.clear)
    }

    var driverInfo: some View {
        Text(driver.driverId.code)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(Color(hex: driver.driverId.teamColorHex).isLight ? .black : .white)
            .padding(4)
            .frame(maxWidth: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: driver.driverId.teamColorHex))
            )
            .foregroundColor(.white)
            .background(Configuration.debugMode ? Color.green.opacity(0.5) : Color.clear)
    }

    var intervalView: some View {
        Text(interval)
//            .font(.caption)
            .fontWeight(.medium)
            .background(Configuration.debugMode ? Color.green.opacity(0.5) : Color.clear)
    }

    var leaderView: some View {
        Text(leader)
//            .font(.caption)
            .fontWeight(.medium)
            .background(Configuration.debugMode ? Color.green.opacity(0.5) : Color.clear)
    }

    var tyreView: some View {
        Text("\(driver.tyre.age % 100)")
//            .font(.caption)
            .font(.system(.body, design: .monospaced))
            .fontWeight(.bold)
            .padding(3)
            .frame(maxWidth: 30)
            .foregroundStyle(Color(compound: driver.tyre.compound).isLight ? .black : .white)
            .background(
                Circle().fill(Color(compound: driver.tyre.compound))
            )
    }

    var speedView: some View {
        Text("\(Int(driver.speed)) km/h")
            .font(.caption)
            .fontWeight(.medium)
            .background(Configuration.debugMode ? Color.green.opacity(0.5) : Color.clear)
    }
}

// MARK: - previews

#Preview {
    let table = VStack {
        ForEach(0..<20, id: \.self) {position in
            DriverTableRow(driver: DriverState(
                driverId: DriverInfo(
                    id: "HAM44",
                    name: "Lewis Hamilton",
                    code: "HAM",
                    number: 44,
                    team: "Mercedes",
                    teamColorHex: "#ED1C24",
                    country: "GBR"
                ),
                lap: 97,
                position: position + 1,
                distance: 401.2,
                speed: 238.8,
                sector: 3,
                intervalToLeader: 22.1,
                intervalToAhead: 2.7,
                pitStatus: false,
                drsActive: false,
                tyre: TyreState(
                    compound: .intermediate,
                    age: 19,
                    fresh: false
               )
            ))
        }
    }
//        .padding()
        .padding(.vertical)
    HStack {
        table
        table
    }
}
#Preview {
    let a = DriverTableRow(driver: DriverState(
        driverId: DriverInfo(
            id: "HAM44",
            name: "Lewis Hamilton",
            code: "HAM",
            number: 44,
            team: "Mercedes",
            teamColorHex: "#00D2BE",
            country: "GBR"
        ),
        lap: 97,
        position: 0,
        distance: 401.2,
        speed: 238.8,
        sector: 3,
        intervalToLeader: 22.1,
        intervalToAhead: 2.7,
        pitStatus: false,
        drsActive: false,
        tyre: TyreState(
            compound: .intermediate,
            age: 19,
            fresh: false
        )
    ))
        .padding()
        .background(Color.pink.opacity(0.05))
    HStack {
        a
        a
    }
}
