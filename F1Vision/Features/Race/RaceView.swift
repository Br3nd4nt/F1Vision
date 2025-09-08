//
//  RaceView.swift
//  F1Vision
//
//  Created by br3nd4nt on 25.08.2025.
//

import SwiftUI

struct RaceView: View {
    @ObservedObject private var viewModel: RaceViewModel
    @ObservedObject private var trackViewModel: TrackViewModel

    init(viewModel: RaceViewModel, trackViewModel: TrackViewModel) {
        self.viewModel = viewModel
        self.trackViewModel = trackViewModel
    }

    var body: some View {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading race data...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            viewModel.refreshData()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    RaceTableView(viewModel: viewModel)
                }
            }

        .onAppear {
            viewModel.setTrackViewModel(trackViewModel)
        }
    }
}


