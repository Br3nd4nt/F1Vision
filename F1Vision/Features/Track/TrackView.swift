//
//  TrackView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct TrackView: View {
    @ObservedObject var viewModel: TrackViewModel

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
