# Final year project

All applications require the use of an Apple ID to install on-device. For testing purposes, open the projects within Xcode, select the project within the left side-panel and click on the ‘Signing and Capabilities’ tab. Here, an existing team can be selected, or a new team can be created by signing into an existing Apple ID. For help regarding this, please refer to [Apple’s Developer Documentation](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7). 


Pre-requisites for Design Studio on the iPad:
* Xcode running on macOS 10.14.4 or later
* 10.5 inch iPad Pro running iOS 13 or later
* Connected Apple Pencil


Please note that the Design Studio iPad app, has the project name ‘CanvasDrawingApp’. A variety of models that were also tested are included within this project, in the 'Models’ folder. For a detailed user guide, please refer to page 119 of my final report.

After downloading and opening the Xcode project, plug in your 10.5 inch iPad Pro into your laptop. Within Xcode, select your iPad from the devices panel and press the ‘Run’ button, or simply use the keyboard shortcut ‘Command-R’. As before,[ Apple’s Developer Documentation](https://help.apple.com/xcode/mac/current/#/dev60b6fbbc7) can be referred to for any assistance

It is important to note that for the TestBench, models need to be imported into the Xcode project for investigation. These models need to be of the format ‘.mlmodel’. The model class names need to be specified in the `predictRandomForest()` and `predictImage()` methods, on lines 29 and 50 respectively.
 
Design Studio mac extension project for code generation, has the file name ‘ReceiveDataFromiPad’

This application is required for the generation of Swift code. Permissions need to be granted to save the generated ‘ViewController.swift’ file on your Desktop. This can be done by enabling the ‘Hardened runtime’ from the ‘Signing and Capabilities’ tab in Xcode and removing the ‘Sandboxing’ option. Please note that your local WiFi and Bluetooth are being used to transmit data from your iPad to your mac. Please ensure that both these connections are turned on. This can be done within the Settings application on your iPad or the System Preferences on your mac.
