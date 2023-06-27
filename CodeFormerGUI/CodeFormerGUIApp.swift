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
            FileSelection().frame(minWidth: 500, maxWidth: 1000, minHeight: 350, maxHeight: 550)
//                .onAppear {
//                    PythonLibrary.useLibrary(at: "/opt/anaconda3/bin/python3")
//                }
        }
    }
}
