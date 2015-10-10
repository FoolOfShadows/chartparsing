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

	@IBAction func processHelp(sender: AnyObject) {
		helpWindow.makeKeyAndOrderFront(self)
	}
	
	@IBAction func processCloseHelp(sender: AnyObject) {
		helpWindow.orderOut(self)
	}
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}
	
	
	@IBAction func processButton(sender: AnyObject) {
		//Get the info from the date scheduled popup menu
		let ptVisitDate = visitDayView.indexOfSelectedItem
		
		//Where to save the file
		var saveLocation = "Desktop"
		switch ptVisitDate {
		case 0:
			saveLocation = "WPCMSharedFiles/zDoctor Review/06 Dummy Files"
		case 1...3:
			saveLocation = "WPCMSharedFiles/zruss Review/Tomorrows Files"
		default:
			saveLocation = "Desktop"
		}
		
		//Get current date and format it
		let theCurrentDate = NSDate()
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		//let formattedDate = formatter.stringFromDate(theCurrentDate)
		
		//Get the visit date
		let visitDate = addingDays(theCurrentDate, daysToAdd: ptVisitDate)
		let internalVisitDate = formatter.stringFromDate(visitDate)
		let labelDateFormatter = NSDateFormatter()
		labelDateFormatter.dateFormat = "YYMMdd"
		let labelVisitDate = labelDateFormatter.stringFromDate(visitDate)
		
		
		//Get the clipboard to process
		let pasteBoard = NSPasteboard.generalPasteboard()
		let theText = pasteBoard.stringForType("public.utf8-plain-text")
		
		//Get name, age, gender, and birthdate
		let ptNameAgeDOB = nameAgeDOB(theText!)
		let ptName = ptNameAgeDOB.0
		let ptAge = ptNameAgeDOB.1
		let ptDOB = ptNameAgeDOB.2
		
		//Break apart components of patient name
		let ptFileLabelName = getFileLabellingName(ptName)
//		let ptNameComponents = ptName.componentsSeparatedByString(" ")
//		let ptFirstName = ptNameComponents[0]
//		var ptLastName = ptNameComponents[ptNameComponents.count - 1]
//		if ptNameComponents[ptNameComponents.count - 2] == "Van" {
//			ptLastName = "Van " + ptLastName
//		}
//		var ptMiddleName = ""
//		if ptNameComponents.count > 2 {
//			ptMiddleName = ptNameComponents[1]
//		}

		var dxRegex = regexTheText(theText!, startOfText: "\\nDiagnoses", endOfText: "Social")
		dxRegex = cleanTheSections(dxRegex, badBits: ["Diagnoses\n", "Chronic diagnoses\n", "No active Acute diagnoses.\n", "Acute diagnoses\n", "Social"])
		dxRegex = "DIAGNOSES:\n" + dxRegex
		
		var medRegex = regexTheText(theText!, startOfText: "\\nMedications", endOfText: "Encounters")
		medRegex = cleanTheSections(medRegex, badBits: ["Medications\n", "Encounters"])
		medRegex = addCharatersToFront(medRegex, theCharacters: "-  ")
		medRegex = "CURRENT MEDICATIONS:\n(- = currently taking; x = not currently taking; ? = unsure)\n" + medRegex
		
		var nutritionRegex = regexTheText(theText!, startOfText: "\\nNutrition history", endOfText: "Advanced directives")
		nutritionRegex = cleanTheSections(nutritionRegex, badBits: ["Nutrition history\n", "Advanced directives"])
		nutritionRegex = "NUTRITION:\n" + nutritionRegex
		
		var socialRegex = regexTheText(theText!, startOfText: "\\nSocial history", endOfText: "Past medical history")
		socialRegex = cleanTheSections(socialRegex, badBits: ["Past medical history", "Social history (free text)\n", "Social history\n", "Smoking status\n"])
		socialRegex = "SOCIAL HISTORY:\n" + socialRegex
		//print(socialRegex)
		
		let finalFMHParameter = defineFinalParameter(theText!, firstParameter: "Preventive care", secondParameter: "Social history")
		//print(finalFMHParameter)
		var fmhRegex = regexTheText(theText!, startOfText: "Family health history", endOfText: finalFMHParameter)
		fmhRegex = cleanTheSections(fmhRegex, badBits: ["Family health history\n", "Preventive care", "Social history"])
		fmhRegex = "FAMILY HEALTH HISTORY:\n" + fmhRegex
		//print(fmhRegex)
		
		let finalAllergiesParameter = defineFinalParameter(theText!, firstParameter: "Family health history", secondParameter: "Preventive care")
		var basicAllergyRegex = regexTheText(theText!, startOfText: "\\nAllergies[^(free text)]", endOfText: "Medications")
		//print(basicAllergyRegex)
		basicAllergyRegex = cleanTheSections(basicAllergyRegex, badBits: ["Allergies\n", "Drug allergies\n", "Environmental allergies\n", "No environmental allergies recorded\n", "Food allergies\n", "Medications"])
		var freeAllergyRegex = regexTheText(theText!, startOfText: "Allergies \\(free text\\)", endOfText: finalAllergiesParameter)
		freeAllergyRegex = cleanTheSections(freeAllergyRegex, badBits: ["Allergies (free text)\n", "ALLERGIES:", "ALLERGIES", "Use structured allergies to receive interaction alerts\n", "Food allergies:", "Food Allergies:", "Food Allergies", "Food allergies\n", "Environmental allergies:\n", "Environmental allergies\n", "Environmental Allergies\n", "Drug allergies:", "Drug allergies-", "Drug allergies", "No Known Drug Allergies", "No Known", "Drug Allergies:", "Drug Allergies", "Family health history", "Preventive care", "No food allergies recorded\n"])
		
		let allergyResults = "ALLERGIES:\n" + basicAllergyRegex + "\n" + freeAllergyRegex
		
		let finalPreventiveParameter = defineFinalParameter(theText!, firstParameter: "Nutrition history", secondParameter: "Advanced directives")
		//print(finalPreventiveParameter)
		let basicPreventiveRegex = regexTheText(theText!, startOfText: "Preventive care", endOfText: finalPreventiveParameter)
		//print(basicPreventiveRegex)
		let otherFinalPreventiveParameter = defineFinalParameter(basicPreventiveRegex, firstParameter: "Social history", secondParameter: "Advanced directives")
		var preventiveRegex = regexTheText(basicPreventiveRegex, startOfText: "Preventive care", endOfText: otherFinalPreventiveParameter)
		preventiveRegex = cleanTheSections(preventiveRegex, badBits: ["Preventive care\n", "Social history", "Advanced directives"])
		preventiveRegex = "PREVENTIVE CARE:\n" + preventiveRegex
		
		let finalMedHistoryParameter = defineFinalParameter(theText!, firstParameter: "(free text)", secondParameter: "Preventive care")
		let medHistoryRegex = regexTheText(theText!, startOfText: "Past medical history", endOfText: finalMedHistoryParameter)
		var pshRegex = regexTheText(medHistoryRegex, startOfText: "Major events", endOfText: "Ongoing medical problems")
		pshRegex = cleanTheSections(pshRegex, badBits: ["Major events\n", "Ongoing medical problems", "PSH:\n", "PHS:\n"])
		pshRegex = "PAST SURGICAL HISTORY:\n" + pshRegex
		var pmhRegex = regexTheText(medHistoryRegex, startOfText: "Ongoing medical problems", endOfText: finalMedHistoryParameter)
			//"\\(free text\\)")
		pmhRegex = cleanTheSections(pmhRegex, badBits: ["Ongoing medical problems\n", "Allergies (free text)", "Allergies (free text", "PMH:\n", "PHM:\n", "Preventive care"])
		pmhRegex = "PAST MEDICAL HISTORY:\n" + pmhRegex
		
		
		let visitBoilerplateText = "CC:  \n\nS:  \nProblems:  \nLocation:  \nSeverity:  \nQuality:  \nDuration:  \nTiming:  \nContext:  \nModifying factors:  \nAssociated symptoms:  \n\nNEW PMH:  \n\nA(Charge):  \n\nP(lan):  \n\nO(PE):  \n\n"
		
		let finalResults = ("\(ptName)\nDOB:  \(ptDOB)    Age:  \(ptAge)\nDate:  \(internalVisitDate)\n\n\(visitBoilerplateText)\(medRegex)\n\n\(allergyResults)\n\n\(preventiveRegex)\n\n\(pmhRegex)\n\n\(pshRegex)\n\n\(nutritionRegex)\n\n\(socialRegex)\n\n\(fmhRegex)\n\n\(dxRegex)")
		
		let fileName = "\(visitTimeView.stringValue) \(ptFileLabelName) PTVN \(labelVisitDate).txt"
		//Pushes the final output to the clipboard
//		pasteBoard.clearContents()
//		pasteBoard.setString(finalResults, forType: NSPasteboardTypeString)
		
		//Creates a file with the final output on the desktop
		let ptvnData = finalResults.dataUsingEncoding(NSUTF8StringEncoding)
		let newFileManager = NSFileManager.defaultManager()
		let savePath = NSHomeDirectory()
		newFileManager.createFileAtPath("\(savePath)/\(saveLocation)/\(fileName)", contents: ptvnData, attributes: nil)
		
		do {
			let testText = try String(contentsOfFile: "\(savePath)/\(saveLocation)/\(fileName)")
		} catch {
			
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

