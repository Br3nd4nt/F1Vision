//
//  TrackView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct TrackView: View {
    @ObservedObject private var viewModel: TrackViewModel

    init(viewModel: TrackViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TrackUIViewRepresentable(viewModel: viewModel)
                .onAppear {
                    Task {
                        await viewModel.getTrackData()
                    }
                }
        }
    }
}
