//
//  ContentView.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/1/23.
//

import SwiftUI
import PythonKit

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
        Button(action: {
            
            
            print(Python.versionInfo)
        }) {
            Text("Activate Python")
        }
        
        Button(action: {
            do {
                try safeShell("""
                    cd /Users/a970/CodeFormer;
                    /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/basicsr/setup.py develop;
                    /Users/a970/opt/anaconda3/bin/pip install dlib;
                   
                   
                    /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/scripts/download_pretrained_models.py facelib;
                    /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/scripts/download_pretrained_models.py CodeFormer;
                
                """)
                print(
//                    which python, pip
                    try safeShell("""
                        cd /Users/a970/CodeFormer;
                        /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/basicsr/setup.py develop;
                        /Users/a970/opt/anaconda3/bin/pip install dlib;
                    
                    
                        /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/scripts/download_pretrained_models.py facelib
                        /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/scripts/download_pretrained_models.py CodeFormer
                    
                    """),
                    try safeShell("/Users/a970/opt/anaconda3/bin/python --version")
                )
            } catch {
                print("ERROR: \(error)")
            }
        }) {
            Text("Download neccessary components")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
