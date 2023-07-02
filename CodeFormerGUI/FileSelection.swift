//
//  FileSelection.swift
//  CodeFormerGUI
//
//  Created by Kelvin J on 6/23/23.
//

import SwiftUI
import Cocoa
import AppKit

struct FileSelection: View {
    @State var filename = "Filename"
    @State var path: [URL] = [URL]()
    @State var showFileChooser = false
    
    @State private var message = "Drag"
    
    @State private var imageUrls: [URL] = []
    @State private var processedImageUrls: [URL] = []
        
    @State private var progressBarIsLoading = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack {
                        Text("Source")
                            .font(.title)
                            .bold()
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
                                                        .frame(width: 175, height: 131.25)
                                                    
                                                    Text(url.lastPathComponent)
                                                    Spacer()
                                                    Image(systemName: "minus.circle.fill")
                                                        .aspectRatio(contentMode: .fit)
                                                        .onTapGesture {
                                                            withAnimation {
                                                                removeFileFromProcess(filename: url.lastPathComponent)
                                                            }
                                                            
                                                        }
                                                    
                                                }
                                                
                                            }.padding(.horizontal, 10)
                                            
                                            
                                            
                                            Spacer()
                                            Button("Select More") {
                                                let panel = NSOpenPanel()
                                                panel.allowsMultipleSelection = false
                                                panel.canChooseDirectories = false
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
                    }
                    
                    Image(systemName: "arrow.right")
                        .aspectRatio(contentMode: .fit)
                    VStack {
                        Text("Processed Output")
                            .font(.title)
                            .bold()
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
                                                        .frame(width: 175, height: 131.25)
                                                    
                                                    
                                                    Text(imageURL.lastPathComponent)
                                                    Spacer()
                                                    Button(action: {
                                                        locateFileInFinder(url: imageURL)
                                                    }) {
                                                        Image(systemName: "magnifyingglass.circle.fill")
                                                            .aspectRatio(contentMode: .fit)
                                                    }
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
                                                                for img in processedImageUrls {
                                                                    saveFileToUserDefinedDestination(destinationPath: selectedFolderURL, filename: img.lastPathComponent)
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                }) {
                                                    Text("Choose Location")
                                                }
                                            }.padding(10)
                                        }
                                        
                                    } else {
                                        Text("Result preview")
                                    }
                                }
                            )
                    }
                    
                }
                Button(action: {
                    
                    DispatchQueue.global().async {
                        progressBarIsLoading = true
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                        resultsAreOut.toggle()
//                        progressBarIsLoading = false
//
//                        getSelectedProcessedImages()
//                    }
                        safeShell("cd /Users/\(NSUserName())/CodeFormer; /Users/\(NSUserName())/opt/anaconda3/bin/python /Users/\(NSUserName())/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/\(NSUserName())/Documents/.CodeFormerGUI/ToBeProcessed")
                        print(safeShell("cd /Users/\(NSUserName())/CodeFormer; /Users/\(NSUserName())/opt/anaconda3/bin/python /Users/\(NSUserName())/CodeFormer/inference_codeformer.py -w 0.7 --input_path /Users/\(NSUserName())/Documents/.CodeFormerGUI/ToBeProcessed"))
                        
                        progressBarIsLoading = false
                        
                        getSelectedProcessedImages()
                    }
                }) {
                    Text("Enhance")
                        .bold()
                }
                .buttonStyle(BlueButtonStyle(isButtonEnabled: imageUrls.isEmpty))
                .padding(.vertical, 10)
                
                
                 
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
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 250, height: 50)
                        .foregroundColor(Color.gray.opacity(0.95))
                    
                    
                        .overlay(
                            ProgressView("Enhancing... This may take a while")
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                        )
                }.padding()
                
            }
        }
    }
    
    func locateFileInFinder(url: URL) {
            // Provide the URL of the file you want to locate
            let fileURL = url

            let workspace = NSWorkspace.shared
            workspace.activateFileViewerSelecting([fileURL])
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
            
            
            let rootURL = try FileManager.default.url(for: .userDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let sourcePath = rootURL
                    .appendingPathComponent(NSUserName())
                    .appendingPathComponent("CodeFormer")
                    .appendingPathComponent("results")
                    .appendingPathComponent("ToBeProcessed_0.7")
                    .appendingPathComponent("final_results")
                try fileManager.removeItem(at: sourcePath)
                print("CodeFormer Library Directory removed successfully")
            
        } catch {
            print("Error removing directory: \(error.localizedDescription)")
        }
    }
    
    func removeFileFromProcess(filename: String) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let folderURL = documentDirectory
                .appendingPathComponent(".CodeFormerGUI")
                .appendingPathComponent("ToBeProcessed")
                .appendingPathComponent(filename)
            try fileManager.removeItem(at: folderURL)
            
            let elementToRemove = folderURL
            imageUrls.removeAll { $0 == elementToRemove }
            print("Image removed successfully from .CodeFormerGUI")

            
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
    
    func saveFileToUserDefinedDestination(destinationPath: URL, filename: String) {
        let fileManager = FileManager.default
        if let rootURL = fileManager.urls(for: .userDirectory, in: .localDomainMask).first {
            do {
                let sourcePath = rootURL
                    .appendingPathComponent(NSUserName())
                    .appendingPathComponent("CodeFormer")
                    .appendingPathComponent("results")
                    .appendingPathComponent("ToBeProcessed_0.7")
                    .appendingPathComponent("final_results")
                print("the given dest path: ", destinationPath.path)
                try FileManager.default.copyItem(atPath: sourcePath.path, toPath: "\(destinationPath.path)/\(filename)")
                print("Files copied successfully")
            } catch {
                print("Error copying files:", error.localizedDescription)
            }
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

