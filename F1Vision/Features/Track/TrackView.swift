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
            if viewModel.isLoaded {
                TrackUIViewRepresentable(viewModel: viewModel)
            } else {
                Text("not loaded")
            }
        }.animation(.default, value: viewModel.isLoaded)
    }
}

struct TrackUIViewRepresentable: UIViewRepresentable {
    @ObservedObject private var viewModel: TrackViewModel

    init(viewModel: TrackViewModel) {
        self.viewModel = viewModel
    }

    func makeUIView(context _: Context) -> TrackUIView {
        let trackView = TrackUIView(viewModel)
        trackView.configureView()
        return trackView
    }

    func updateUIView(_ uiView: TrackUIView, context : Context) {
        uiView.configureView()
    }
}
