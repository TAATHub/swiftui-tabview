import SwiftUI

struct ListView: View {
    @StateObject private var viewModel: ListViewModel
    
    let onHeightChanged: (Int, CGFloat) -> Void
    
    init(viewModel: ListViewModel, onHeightChanged: @escaping (Int, CGFloat) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onHeightChanged = onHeightChanged
    }
    
    var body: some View {
        LazyVStack() {
            ForEach(viewModel.items, id: \.self) { item in
                viewModel.color
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .id(item)
                    .onAppear {
                        viewModel.currentId = item
                    }
            }
            
            // TabViewをScrollViewの中に入れたことで、Lazyではなくなり、ここもすぐに実行されてしまう
//            FooterLoadingView(isVisible: true) {
//                print("onPageEnd")
//            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        onHeightChanged(viewModel.id, proxy.size.height)
                    }
                    .onChange(of: proxy.size, perform: { size in
                        onHeightChanged(viewModel.id, size.height)
                    })
            }
        )
    }
}

@MainActor
final class ListViewModel: ObservableObject {
    @Published private(set) var items: [String]
    @Published var currentId: String?
    
    let id: Int
    let color: Color
    let pageSize: Int
    
    init(id: Int, color: Color, pageSize: Int) {
        self.id = id
        self.color = color
        self.pageSize = pageSize
        self.items = []
        
        for _ in 0..<pageSize {
            self.items.append(UUID().uuidString)
        }
    }
    
    func onPageEnd() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        for _ in 0..<pageSize {
            items.append(UUID().uuidString)
        }
    }
}
