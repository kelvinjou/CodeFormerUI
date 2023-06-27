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
    @State private var processedImageUrls: [URL] = []
    
    @State private var resultsAreOut = false
    
    let directoryURL = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("a970")
                .appendingPathComponent("CodeFormer")
                .appendingPathComponent("results")
                .appendingPathComponent("ToBeProcessed_0.7")
    
    
    var body: some View {
        VStack {
            HStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.secondary.opacity(0.5))
                    .overlay(
                        VStack {
                            if imageUrls.isEmpty {
                                VStack {
                                    Image(systemName: "square.and.arrow.down.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                    
                                    Text("Drag or select a file")
                                    Button("select file(s)") {
                                        let panel = NSOpenPanel()
                                        panel.allowsMultipleSelection = false
                                        panel.canChooseDirectories = false
                                        //                                    panel.allowedContentTypes = ["png", "jpg", "jpeg"]
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
                                        getSelectedUnprocessedImages()
                                    }
                                }
                            } else {
                                VStack {
                                    List(imageUrls, id: \.self) { url in
                                        HStack {
                                            ImageView(url: url)
                                                .frame(width: 125, height: 125)
                                            Text(url.lastPathComponent)
                                            
                                        }
                                        
                                    }

                                    Spacer()
                                    Button("select file(s)") {
                                        let panel = NSOpenPanel()
                                        panel.allowsMultipleSelection = false
                                        panel.canChooseDirectories = false
                                        //                                    panel.allowedContentTypes = ["png", "jpg", "jpeg"]
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
                                        getSelectedUnprocessedImages()
                                    }
                                
                                }

                            }
                            
                        }
                        
                    )
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    print("url: \(url.lastPathComponent)")
                                    self.filename = url.lastPathComponent
                                    
                                    copyFile(sourcePath: "\(url.path)", destinationPath: "/Users/a970/Documents/ToBeProcessed/\(url.lastPathComponent)")
                                    getSelectedUnprocessedImages()
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
                    .overlay(
                        VStack {
                            if resultsAreOut {
                                ForEach(getImageURLs(), id: \.self) { imageURL in
                                    loadImage(from: imageURL)
                                }
                            } else {
                                Text("Result preview")
                            }
                        }
                    )
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
                    try safeShell("cd /Users/a970/CodeFormer; /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/ToBeProcessed")
                    print(try safeShell("cd /Users/a970/CodeFormer; /Users/a970/opt/anaconda3/bin/python /Users/a970/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/ToBeProcessed"))
                    resultsAreOut.toggle()
                    
                    
                } catch {
                    print(error)
                }

            }.padding()
            
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onDisappear {
            removeDirectory(atPath: "/Users/a970/Documents/ToBeProcessed/")
        }
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
    
    func getImageURLs() -> [URL] {
            do {
                let fileUrls = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
                let imageUrls = fileUrls.filter { url in
                    url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
                }
                return imageUrls
            } catch {
                print("Error: \(error.localizedDescription)")
                return []
            }
        }
    
    
    func getSelectedUnprocessedImages() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let appendedPath = documentDirectory.appendingPathComponent("toBeProcessed")
            let fileUrls = try FileManager.default.contentsOfDirectory(at: appendedPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            let imageUrls = fileUrls.filter { url in
                url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
            }
            self.imageUrls = imageUrls
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    func removeDirectory(atPath path: String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
            print("Directory removed successfully")
        } catch {
            print("Error removing directory: \(error.localizedDescription)")
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
    
    @ViewBuilder
    func loadImage(from imageURL: URL) -> some View {
        if let image = NSImage(contentsOf: imageURL) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
        } else {
            Text("Image not found")
        }
    }
}

struct FileSelection_Previews: PreviewProvider {
    static var previews: some View {
        FileSelection()
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
