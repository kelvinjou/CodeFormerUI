//
//  Home.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/27/23.
//

import SwiftUI

struct Home: View {
    @StateObject var viewModel = ViewModel()
    @State private var isSidebarExpanded = false // New state variable

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.enhancement) { item in
                    NavigationLink(item.name, tag: item.id, selection: $viewModel.selectedId) {
                        FileSelection()
                            .navigationTitle(item.name)
                    }
                }
                .listStyle(.sidebar)
            }
            
                
            Text("No selection")
        }
    }
}


struct Enhancements: Identifiable {
    let id = UUID().uuidString
    let name: String
}

final class ViewModel: ObservableObject {
  init(enhancement: [Enhancements] = ViewModel.defaultEnhancement) {
    self.enhancement = enhancement
    self.selectedId = enhancement[0].id
  }
  @Published var enhancement: [Enhancements]
  @Published var selectedId: String?
  static let defaultEnhancement: [Enhancements] = ["Enhance Image", "Face Color", "Face Inpainting"].map({ Enhancements(name: $0) })
}
