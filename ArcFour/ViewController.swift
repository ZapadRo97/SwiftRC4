//
//  ViewController.swift
//  ArcFour
//
//  Created by Florin Daniel on 02/05/2020.
//  Copyright © 2020 Florin Daniel. All rights reserved.
//

import Cocoa

//swift stuff for appending data to existing file
extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

class ViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var fileSizeInputField: NSTextField!
    @IBOutlet weak var locationInputField: NSTextField!
    @IBOutlet weak var locationSelectButton: NSButton!
    @IBOutlet weak var generateButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var keyTextField: NSTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fileSizeInputField.delegate = self
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        
        let range = NSRange(location: 0, length: textField.stringValue.utf16.count)
        let regex = try! NSRegularExpression(pattern: "[^0-9]")
        if (regex.firstMatch(in: textField.stringValue, options: [], range: range) != nil) {
            textField.stringValue = ""
        }
    }
    
    
    @IBAction func selectDirectoryAction(_ sender: Any) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Chose directory to save output";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseFiles = false;
        dialog.canChooseDirectories = true;

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let path: String = result!.path
                locationInputField.stringValue = path + "/output.rc4stream"
                // path contains the directory path e.g
                // /Users/ourcodeworld/Desktop/folder
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func generateFileAction(_ sender: Any) {
        let rc4 = RC4(key: keyTextField.stringValue)
        let fileUrl = URL(fileURLWithPath: locationInputField.stringValue)
        let fileSize = fileSizeInputField.intValue
        let increment = 100.0 / Double(fileSize)
        self.progressBar.doubleValue = 0
        generateButton.isEnabled = false
        DispatchQueue.global(qos:.default).async {
            
            for i in 0..<fileSize {
                //write in batches of 1mb
                var buffer = [UInt8]()
                //to not realloc memory aftear each append
                buffer.reserveCapacity(1024*1024)
                for _ in 0..<(1024*1024) {
                    let number = rc4.nextNumber()
                    buffer.append(number)
                }
                
                let data = Data(buffer)
                do {
                    if i == 0 {
                        try data.write(to: fileUrl)
                    } else {
                        try data.append(fileURL: fileUrl)
                    }
                }
                catch {
                    print("\(error)")
                }
                
                //increment progress bar
                DispatchQueue.main.async {
                self.progressBar.increment(by: increment)
                }
            }
            
            //reenable generate buton
            DispatchQueue.main.async {
                self.generateButton.isEnabled = true
            }
        }
    }
}

