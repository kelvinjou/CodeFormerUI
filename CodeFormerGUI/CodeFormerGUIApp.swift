//
//  CodeFormerGUIApp.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/1/23.
//

import SwiftUI
import PythonKit

@main
struct CodeFormerGUIApp: App {
    var body: some Scene {
        WindowGroup {
            Home()
//            FileSelection()
                .frame(minWidth: 600, maxWidth: 1000, minHeight: 400, maxHeight: 650)

        }
    }
}
