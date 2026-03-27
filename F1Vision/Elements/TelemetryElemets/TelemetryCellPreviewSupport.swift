#if DEBUG
import SwiftUI
import UIKit

@MainActor
enum TelemetryCellPreviewSupport {
    static let defaultTableHeight: CGFloat = 1200

    static func sizeForTelemetryColumn(
        _ column: Int,
        tableHeight: CGFloat = defaultTableHeight
    ) -> CGSize {
        let service = SSEService()
        let viewModel = RaceViewModel(sseService: service)
        let delegate = TelemetryTableCollectionViewDelegate(viewModel: viewModel)

        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: 1200, height: tableHeight),
            collectionViewLayout: layout
        )
        collectionView.layoutMargins = .zero

        return delegate.collectionView(
            collectionView,
            layout: layout,
            sizeForItemAt: IndexPath(item: column, section: 0)
        )
    }

    static func rowHeight(tableHeight: CGFloat = defaultTableHeight, rowCount: CGFloat = 22) -> CGFloat {
        tableHeight / max(rowCount, 1)
    }
}

@MainActor
struct UIKitViewPreview<UIViewType: UIView>: UIViewRepresentable {
    let view: UIViewType

    func makeUIView(context _: Context) -> UIViewType { view }
    func updateUIView(_: UIViewType, context _: Context) {}
}
#endif

