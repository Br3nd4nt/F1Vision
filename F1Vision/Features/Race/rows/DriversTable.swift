//
//  DriversTable.swift
//  F1Vision
//
//  Created by br3nd4nt on 08.09.2025.
//

import SwiftUI

struct DriversTable: View {
    let drivers: [DriverState]

    var body: some View {
        List {
            ForEach(drivers.sorted { $0.position < $1.position }, id: \.driverId.id) { driver in
                DriverTableRow(driver: driver)
            }
        }
        .listStyle(PlainListStyle())
    }
}
