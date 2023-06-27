//
//  FileSelection.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/23/23.
//

import SwiftUI
import Cocoa

struct FileSelection: View {
    @State var filename = "Filename"
    @State var path: [URL] = [URL]()
    @State var showFileChooser = false
    
    @State private var message = "Drag"
    
    @State private var imageUrls: [URL] = []

    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .overlay(
                        VStack {
//                            if path != nil {
//                                Image(nsImage: getSavedImage(named: "\(path!.path)/\(filename)"))
//                                getSavedImage(named: "\(path)/\(filename)")
//                            } else {
                                Image(systemName: "square.and.arrow.down.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                
                                Text("Drag or select a file")
                                Button("select file(s)") {
                                    let panel = NSOpenPanel()
                                    panel.allowsMultipleSelection = false
                                    panel.canChooseDirectories = false
                                    panel.allowedContentTypes = ["png", "jpg", "jpeg"]
                                    if panel.runModal() == .OK {
                                        let path = panel.url?.deletingLastPathComponent() // /Users/a970/Documents/
                                        self.filename = panel.url?.lastPathComponent ?? "<none>" // blurry.png

                                        self.path.append((panel.url)!)
                                        print(panel.url?.path)
                                        
                                        let documentsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                                        let folderURL = documentsURL.appendingPathComponent("ToBeProcessed")
                                        do {
                                            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                                            print(documentsURL)
                                        } catch {
                                            print(error)
                                        }
                                    }

                                    copyFile(sourcePath: "\(panel.url!.path)", destinationPath: "/Users/a970/Documents/ToBeProcessed/\(panel.url!.lastPathComponent)")
//                                    let openPanel = NSOpenPanel()
//                                    openPanel.canChooseFiles = false
//                                    openPanel.canChooseDirectories = true
//                                    openPanel.allowsMultipleSelection = false
//                                    openPanel.canCreateDirectories = false
//
//                                    openPanel.begin { response in
//                                        guard response == .OK, let selectedUrl = openPanel.url else {
//                                            // User canceled or no folder was selected
//                                            return
//                                        }
//
//                                        // Handle the selected folder URL here
//                                        print("Selected folder: \(selectedUrl.path)")
//                                        self.path = selectedUrl
//                                    }
                                }
//                            }
                        }
                        
                        
                    )
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    print("url: \(url.lastPathComponent)")
                                    self.filename = url.lastPathComponent
                                }
                            }
                            return true
                        }
                        return false
                    }
                Image(systemName: "arrow.right")
                    .aspectRatio(contentMode: .fit)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .overlay(Text("Result preview"))
            }
            
            Text(filename)
            Button("Select Folder") {
                let openPanel = NSOpenPanel()
                openPanel.canChooseFiles = false
                openPanel.canChooseDirectories = true
                openPanel.allowsMultipleSelection = false
                openPanel.canCreateDirectories = false

                openPanel.begin { response in
                    guard response == .OK, let selectedUrl = openPanel.url else {
                        // User canceled or no folder was selected
                        return
                    }
                    

                    // Handle the selected folder URL here
                    print("Selected folder: \(selectedUrl.path)")
                }
            }
            Button("Save destination | GO") {
                do {
                    /*TODO: create a temporary FileManager folder that stores all the user selected photos
                     then, create a small preview of all the selected photos
                     then click generate results (should have a loader) which it will get the newly processed images from results under codeformer
                     then have option to save it to a new path, and delete the old folder
                     
                     PREVIEW RESULTS BEFORE SAVING
                    
                     */
//                    python inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/old_photos
                    
                    // destination: /Users/a970/CodeFormer/results/old_photos_0.7/final_results
                    try safeShell("cd /Users/a970/CodeFormer; /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/old_photos")
                    print(try safeShell("cd /Users/a970/CodeFormer; /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/old_photos"))
                    
                } catch {
                    print(error)
                }

            }
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func showSavePanel() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png, .jpeg]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save your image"
        savePanel.message = "Choose a folder and a name to store the image"
        savePanel.nameFieldLabel = "Image file name:"
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
    func getSelectedUnprocessedImages(named: String) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let imageUrls = fileUrls.filter { url in
                url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
            }
            self.imageUrls = imageUrls
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func copyFile(sourcePath: String, destinationPath: String) {
            let fileManager = FileManager.default
            
            do {
                try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
                print("File copied successfully")
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
}

struct FileSelection_Previews: PreviewProvider {
    static var previews: some View {
        FileSelection()
    }
}

//typealias UIImage = NSImage
//
//// Step 2: You might want to add these APIs that UIImage has but NSImage doesn't.
//extension NSImage {
//    var cgImage: CGImage? {
//        var proposedRect = CGRect(origin: .zero, size: size)
//
//        return cgImage(forProposedRect: &proposedRect,
//                       context: nil,
//                       hints: nil)
//    }
//
//    convenience init?(named name: String) {
//        self.init(named: Name(name))
//    }
//}


//func createFolder() {
//        let fileManager = FileManager.default
//        let folderName = "ToBeProcessed"
//        let destinationURL = URL(fileURLWithPath: "/path/to/your/desired/location/")
//        let folderURL = destinationURL.appendingPathComponent(folderName)
//
//        do {
//            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
//            print("Folder created successfully")
//            print("Folder path: \(folderURL.path)")
//        } catch {
//            print("Error creating folder: \(error.localizedDescription)")
//        }
//    }



/*
import SwiftUI

struct ContentView: View {
    @State private var imageUrls: [URL] = []
    
    var body: some View {
        VStack {
            if imageUrls.isEmpty {
                Button("Select Images") {
                    loadImageUrls()
                }
            } else {
                List(imageUrls, id: \.self) { url in
                    ImageView(url: url)
                        .frame(height: 150)
                }
            }
        }
    }
    
    func loadImageUrls() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileUrls = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let imageUrls = fileUrls.filter { url in
                url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
            }
            self.imageUrls = imageUrls
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
}

struct ImageView: View {
    var url: URL
    
    var body: some View {
        if let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Text("Unable to load image")
        }
    }
}

'''
