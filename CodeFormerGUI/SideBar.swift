//
//  SideBar.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/24/23.
//

import SwiftUI

//struct SideBar: View {
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(viewModel.fruits) { item in
//                    NavigationLink(item.name, tag: item.id, selection: $viewModel.selectedId) {
//                        Text(item.name)
//                            .navigationTitle(item.name)
//                    }
//                }
//            }
//            .listStyle(.sidebar)
//        }
//    }
//}

//struct SideBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SideBar()
//    }
//}

final class ViewModel: ObservableObject {
  init(fruits: [Fruit] = ViewModel.defaultFruits) {
    self.fruits = fruits
    self.selectedId = fruits[1].id
  }
  @Published var fruits: [Fruit]
  @Published var selectedId: String?
  static let defaultFruits: [Fruit] = ["Apple", "Orange", "Pear"].map({ Fruit(name: $0) })
}

struct Fruit: Identifiable {
    let id = UUID().uuidString
    let name: String
}
