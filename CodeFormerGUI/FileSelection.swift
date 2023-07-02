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
    
    @State private var progressBarIsLoading = false
    
    //    let directoryURL = FileManager.default.homeDirectoryForCurrentUser
    //                .appendingPathComponent("a970")
    //                .appendingPathComponent("CodeFormer")
    //                .appendingPathComponent("results")
    //                .appendingPathComponent("ToBeProcessed_0.7")
    
    
    var body: some View {
        ZStack {
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
                                        Button("Select File(s)") {
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
                                                let folderURL = documentsURL
                                                    .appendingPathComponent(".CodeFormerGUI")
                                                    .appendingPathComponent("ToBeProcessed")
                                                do {
                                                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                                                    print(documentsURL)
                                                } catch {
                                                    print(error)
                                                }
                                                
                                                copyFile(sourcePath: "\(panel.url!.path)", filename: panel.url!.lastPathComponent)
                                                getSelectedUnprocessedImages()
                                            }
                                            
                                            
                                        }
                                    }
                                } else {
                                    VStack {
                                        ForEach(imageUrls, id: \.self) { url in
                                            HStack {
                                                ImageView(url: url)
                                                    .cornerRadius(10)
                                                    .frame(width: 125, height: 125)
                                                
                                                Spacer()
                                                Text(url.lastPathComponent)
                                                
                                            }.padding(.horizontal, 10)
                                            
                                        }
                                        
                                        Spacer()
                                        Button("Select More") {
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
                                                let folderURL = documentsURL
                                                    .appendingPathComponent(".CodeFormerGUI")
                                                    .appendingPathComponent("ToBeProcessed")
                                                do {
                                                    try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
                                                    print(documentsURL)
                                                } catch {
                                                    print(error)
                                                }
                                                copyFile(sourcePath: "\(panel.url!.path)", filename: panel.url!.lastPathComponent)
                                                getSelectedUnprocessedImages()
                                            }
                                            
                                            
                                        }
                                        .padding(10)
                                        
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
                                        
                                        copyFile(sourcePath: "\(url.path)", filename: url.lastPathComponent)
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
                                if !processedImageUrls.isEmpty {
                                    VStack {
                                    ForEach(processedImageUrls, id: \.self) { imageURL in
                                        HStack {
                                            ImageView(url: imageURL)
                                                .cornerRadius(10)
                                                .frame(width: 125, height: 125)
                                            
                                            Spacer()
                                            Text(imageURL.lastPathComponent)
                                        }
                                        
                                    }.padding(.horizontal, 10)
                                        
                                        Spacer()
                                        Divider()
                                            .background(Color.gray.opacity(0.5))
                                        HStack {
                                            Text("Save all to folder")
                                            Spacer()
                                            Image(systemName: "arrow.right")
                                                .aspectRatio(contentMode: .fit)
                                            Spacer(minLength: 0)
                                            Button(action: {
                                                let panel = NSOpenPanel()
                                                panel.canChooseFiles = false
                                                panel.canChooseDirectories = true
                                                panel.allowsMultipleSelection = false
                                                panel.canCreateDirectories = true
                                                panel.prompt = "Save here"
                                                
                                                panel.begin { response in
                                                    if response == NSApplication.ModalResponse.OK {
                                                        if let selectedFolderURL = panel.url {
                                                            // Handle the selected folder URL here
                                                            print("Selected Folder URL: \(selectedFolderURL)")
                                                        }
                                                    }
                                                }
                                            }) {
                                                Text("Choose Location")
                                                
                                            }
                                        }.padding(.horizontal)
                                    }
                                    
                                } else {
                                    Text("Result preview")
                                }
                            }
                        )
                }
                Button(action: {
                    
                    progressBarIsLoading = true
                    
                    /*TODO: create a temporary FileManager folder that stores all the user selected photos
                     then, create a small preview of all the selected photos
                     then click generate results (should have a loader) which it will get the newly processed images from results under codeformer
                     then have option to save it to a new path, and delete the old folder
                     
                     PREVIEW RESULTS BEFORE SAVING
                     
                     */
                    //                    python inference_codeformer.py -w 0.7 --input_path /Users/a970/Documents/old_photos
                    
                    // destination: /Users/a970/CodeFormer/results/old_photos_0.7/final_results
                    
                    DispatchQueue.global().async {
                        safeShell("cd /Users/\(NSUserName())/CodeFormer; /Users/\(NSUserName())/opt/anaconda3/bin/python /Users/\(NSUserName())/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/\(NSUserName())/Documents/.CodeFormerGUI/ToBeProcessed")
                        print(safeShell("cd /Users/\(NSUserName())/CodeFormer; /Users/\(NSUserName())/opt/anaconda3/bin/python /Users/\(NSUserName())/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/\(NSUserName())/Documents/.CodeFormerGUI/ToBeProcessed"))
                    }
                    resultsAreOut.toggle()
                    progressBarIsLoading = false
                    
                    getSelectedProcessedImages()
                    
                }) {
                    Text("Enhance")
                        .bold()
                }
                .buttonStyle(BlueButtonStyle(isButtonEnabled: imageUrls.isEmpty))
                .padding(.vertical, 10)
                if progressBarIsLoading {
                    Text("LOADING")
                }
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDisappear {
                removeDirectory()
            }
            .onAppear {
                print("Users/\(NSUserName())/Documents/.CodeFormerGUI/ToBeProcessed")
            }
            
            if progressBarIsLoading {
                ProgressView("Downloading")
                    .progressViewStyle(LinearProgressViewStyle())
            }
        }
    }
    
    
    func getSelectedProcessedImages() {
        do {
            let fileManager = FileManager.default
            if let rootURL = fileManager.urls(for: .userDirectory, in: .localDomainMask).first {
                let userURL = rootURL
                    .appendingPathComponent(NSUserName())
                    .appendingPathComponent("CodeFormer")
                    .appendingPathComponent("results")
                    .appendingPathComponent("ToBeProcessed_0.7")
                    .appendingPathComponent("final_results")
                
                
                let fileUrls = try FileManager.default.contentsOfDirectory(at: userURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                let imageUrls = fileUrls.filter { url in
                    url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
                }
                
                self.processedImageUrls = imageUrls
                print(processedImageUrls)
            } else {
                print("Unable to access the root folder.")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
    func getSelectedUnprocessedImages() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let appendedPath = documentDirectory
                .appendingPathComponent(".CodeFormerGUI")
                .appendingPathComponent("ToBeProcessed")
            let fileUrls = try FileManager.default.contentsOfDirectory(at: appendedPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            let imageUrls = fileUrls.filter { url in
                url.pathExtension.lowercased().contains("png") || url.pathExtension.lowercased().contains("jpg") || url.pathExtension.lowercased().contains("jpeg")
            }
            self.imageUrls = imageUrls
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func removeDirectory() {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentDirectory
                .appendingPathComponent(".CodeFormerGUI")
                .appendingPathComponent("ToBeProcessed")
            
            try fileManager.removeItem(at: folderURL)
            print("Directory removed successfully")
        } catch {
            print("Error removing directory: \(error.localizedDescription)")
        }
    }
    
    func copyFile(sourcePath: String, filename: String) {
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentDirectory
                .appendingPathComponent(".CodeFormerGUI")
                .appendingPathComponent("ToBeProcessed")
            try fileManager.copyItem(atPath: sourcePath, toPath: "\(folderURL.path)/\(filename)")
            print("File copied successfully")
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }
    
    func saveFileToUserDefinedDestination(destinationPath: String) {
        let fileManager = FileManager.default
        if let rootURL = fileManager.urls(for: .userDirectory, in: .localDomainMask).first {
            let userURL = rootURL
                .appendingPathComponent(NSUserName())
                .appendingPathComponent("CodeFormer")
                .appendingPathComponent("results")
                .appendingPathComponent("ToBeProcessed_0.7")
                .appendingPathComponent("final_results")
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

struct BlueButtonStyle: ButtonStyle {
    let isButtonEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(isButtonEnabled ? Color.blue.opacity(0.5) : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
