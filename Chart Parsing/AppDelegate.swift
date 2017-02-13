//
//  AppDelegate.swift
//  Chart Parsing
//
//  Created by Fool on 6/17/15.
//  Copyright (c) 2015 Fulgent Wake. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var helpWindow: NSWindow!

	@IBOutlet weak var visitTimeView: NSTextField!
	@IBOutlet weak var visitDayView: NSPopUpButton!

	@IBAction func processHelp(_ sender: AnyObject) {
		helpWindow.makeKeyAndOrderFront(self)
	}
	
	@IBAction func processCloseHelp(_ sender: AnyObject) {
		helpWindow.orderOut(self)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
	}
	
	@IBAction func processButton(_ sender: AnyObject) {
		//Get the info from the date scheduled popup menu
		let ptVisitDate = visitDayView.indexOfSelectedItem
		
		//Where to save the file
		var saveLocation = "Desktop"
		switch ptVisitDate {
		case 0:
			saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
		case 1...4:
			saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
		default:
			saveLocation = "Desktop"
		}
		
		//Get current date and format it
		let theCurrentDate = Date()
		let formatter = DateFormatter()
		formatter.dateStyle = DateFormatter.Style.short
		//let formattedDate = formatter.stringFromDate(theCurrentDate)
		
		//Get the visit date
		let visitDate = addingDays(theCurrentDate, daysToAdd: ptVisitDate)
		let internalVisitDate = formatter.string(from: visitDate)
		let labelDateFormatter = DateFormatter()
		labelDateFormatter.dateFormat = "yyMMdd"
		let labelVisitDate = labelDateFormatter.string(from: visitDate)
		//print("\(visitDate), \(internalVisitDate), \(labelVisitDate)")
		
		
		//Get the clipboard to process
		let pasteBoard = NSPasteboard.general()
		let theText = pasteBoard.string(forType: "public.utf8-plain-text")
		if checkForICD10(theText!, window: window) == true {
		if !theText!.contains("Flowsheets") {
			//Create an alert to let the user know the clipboard doesn't contain
			//the correct PF data
			print("You broke it!")
			//After notifying the user, break out of the program
			let theAlert = NSAlert()
			theAlert.messageText = "It doesn't look like you've copied the correct bits out of Practice Fusion.\nPlease try again or click the help button for complete instructions.\nIf the problem continues, please contact the administrator."
			theAlert.beginSheetModal(for: window) { (NSModalResponse) -> Void in
				let returnCode = NSModalResponse
				print(returnCode)}
		} else {
		
		//Get name, age, gender, and birthdate
		let ptNameAgeDOB = nameAgeDOB(theText!)
		let ptName = ptNameAgeDOB.0
		let ptAge = ptNameAgeDOB.1
		let ptDOB = ptNameAgeDOB.2
		
		//Break apart components of patient name
		let ptFileLabelName = getFileLabellingName(ptName)

		//Get the diagnosis info
		var dxRegex = regexTheText(theText!, startOfText: dxStartOfText, endOfText: dxEndOfText)
		dxRegex = cleanTheSections(dxRegex, badBits: dxBadBits)
		dxRegex = "DIAGNOSES:\n" + dxRegex
		
		//Get the medicine info
		var medRegex = regexTheText(theText!, startOfText: medStartOfText, endOfText: medEndOfText)
		medRegex = cleanTheSections(medRegex, badBits: medBadBits)
		medRegex = addCharactersToFront(medRegex, theCharacters: "-  ")
		medRegex = "CURRENT MEDICATIONS:\n(- = currently taking; x = not currently taking; ? = unsure)\n" + medRegex
		
		//Get the nutrition info
		var nutritionRegex = regexTheText(theText!, startOfText: nutritionStartOfText, endOfText: nutritionEndOfText)
		nutritionRegex = cleanTheSections(nutritionRegex, badBits: nutritionBadBits)
		nutritionRegex = "NUTRITION:\n" + nutritionRegex
		
		//Get the social info
		var socialRegex = regexTheText(theText!, startOfText: socialStartOfText, endOfText: socialEndOfText)
		socialRegex = cleanTheSections(socialRegex, badBits: socialBadBits)
		socialRegex = "SOCIAL HISTORY:\n" + socialRegex
		//print(socialRegex)
		
		//Get the family history info
		let finalFMHParameter = defineFinalParameter(theText!, firstParameter: fmhEndOfTextFirstParameter, secondParameter: fmhEndOfTextSecondParameter)
		//print(finalFMHParameter)
		var fmhRegex = regexTheText(theText!, startOfText: fmhStartOfText, endOfText: finalFMHParameter)
		fmhRegex = cleanTheSections(fmhRegex, badBits: fmhBadBits)
		fmhRegex = "FAMILY HEALTH HISTORY:\n" + fmhRegex
		//print(fmhRegex)
		
		//Get the allergy info
		var basicAllergyRegex = regexTheText(theText!, startOfText: basicAllergyStartOfText, endOfText: basicAllergyEndOfText)
		//print(basicAllergyRegex)
		basicAllergyRegex = cleanTheSections(basicAllergyRegex, badBits: basicAllergyBadBits)
		
			
		let finalAllergiesParameter = defineFinalParameter(theText!, firstParameter: freeAllergyEndOfTextFirstParameter, secondParameter: freeAllergyEndOfTextSecondParameter)
		var freeAllergyRegex = regexTheText(theText!, startOfText: freeAllergyStartOfText, endOfText: finalAllergiesParameter)
		//print("Free Allergies \(freeAllergyRegex)")
		freeAllergyRegex = cleanTheSections(freeAllergyRegex, badBits: freeAllergyBadBits)
		let allergyResults = "ALLERGIES:\n" + basicAllergyRegex + "\n" + freeAllergyRegex
		
		//Get the preventive info
		let finalPreventiveParameter = defineFinalParameter(theText!, firstParameter: preventiveEndOfTextFirstParameter, secondParameter: preventiveEndOfTextSecondParameter)
		print(finalPreventiveParameter)
		let basicPreventiveRegex = regexTheText(theText!, startOfText: preventiveStartOfText, endOfText: finalPreventiveParameter)
		//print(basicPreventiveRegex)
		let otherFinalPreventiveParameter = defineFinalParameter(basicPreventiveRegex, firstParameter: otherPreventiveEndOfTextFirstParameter, secondParameter: preventiveEndOfTextSecondParameter)
		var preventiveRegex = regexTheText(basicPreventiveRegex, startOfText: preventiveStartOfText, endOfText: otherFinalPreventiveParameter)
		preventiveRegex = cleanTheSections(preventiveRegex, badBits: preventiveBadBits)
		preventiveRegex = "PREVENTIVE CARE:\n" + preventiveRegex
		
		//Get the PMH & PSH info
		let finalMedHistoryParameter = defineFinalParameter(theText!, firstParameter: medhistoryEndOfTextFirstParameter, secondParameter: medhistoryEndOfTextSecondParameter)
		let medHistoryRegex = regexTheText(theText!, startOfText: medhistoryStartOfText, endOfText: finalMedHistoryParameter)
		var pshRegex = regexTheText(medHistoryRegex, startOfText: pshStartOfText, endOfText: pshEndOfText)
		pshRegex = cleanTheSections(pshRegex, badBits: pshBadBits)
		pshRegex = "PAST SURGICAL HISTORY:\n" + pshRegex
		var pmhRegex = regexTheText(medHistoryRegex, startOfText: pmhStartOfText, endOfText: finalMedHistoryParameter)
			//"\\(free text\\)")
		pmhRegex = cleanTheSections(pmhRegex, badBits: pmhBadBits)
		pmhRegex = "PAST MEDICAL HISTORY:\n" + pmhRegex
		
		//Create the PTVN template
		let finalResults = ("\(ptName)\nDOB:  \(ptDOB)    Age:  \(ptAge)\nDate:  \(internalVisitDate)\n\n\(visitBoilerplateText)\(medRegex)\n\n\(allergyResults)\n\n\(preventiveRegex)\n\n\(pmhRegex)\n\n\(pshRegex)\n\n\(nutritionRegex)\n\n\(socialRegex)\n\n\(fmhRegex)\n\n\(dxRegex)")
		
		let fileName = "\(visitTimeView.stringValue) \(ptFileLabelName) PTVN \(labelVisitDate).txt"
		//Pushes the final output to the clipboard
//		pasteBoard.clearContents()
//		pasteBoard.setString(finalResults, forType: NSPasteboardTypeString)
		
		//Creates a file with the final output on the desktop
		let ptvnData = finalResults.data(using: String.Encoding.utf8)
		let newFileManager = FileManager.default
		let savePath = NSHomeDirectory()
		newFileManager.createFile(atPath: "\(savePath)/\(saveLocation)/\(fileName)", contents: ptvnData, attributes: nil)
		
		do {
			let testText = try String(contentsOfFile: "\(savePath)/\(saveLocation)/\(fileName)")
		} catch {
			
		}
			}
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}


}

