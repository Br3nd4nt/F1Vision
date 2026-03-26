//
//  TelemetryTableUIViewRepresentable.swift
//  F1Vision
//
//  Created by br3nd4nt on 05.12.2025.
//

import SwiftUI

struct TelemetryTableUIViewRepresentable: UIViewControllerRepresentable {
    private let viewModel: RaceViewModel

    init(viewModel: RaceViewModel) {
        self.viewModel = viewModel
    }

    func makeUIViewController(context _: Context) -> TelemetryTableViewController {
        TelemetryTableViewController(viewModel: viewModel)
    }

    func updateUIViewController(_ vc: TelemetryTableViewController, context _: Context) {
        vc.configureView()
    }

    typealias UIViewControllerType = TelemetryTableViewController
}
