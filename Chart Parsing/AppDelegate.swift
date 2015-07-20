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


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		// Insert code here to initialize your application
	}
	
	
	@IBAction func processButton(sender: AnyObject) {
		//Get the clipboard
		let pasteBoard = NSPasteboard.generalPasteboard()
		let theText = pasteBoard.stringForType("public.utf8-plain-text")
		
		//Get name, age, gender, and birthdate
		let ptNameAgeDOB = nameAgeDOB(theText!)
		let ptName = ptNameAgeDOB.0
		let ptAge = ptNameAgeDOB.1
		let ptDOB = ptNameAgeDOB.2

		var dxRegex = regexTheText(theText!, startOfText: "Diagnoses", endOfText: "Social")
		dxRegex = cleanTheSections(dxRegex, badBits: ["Diagnoses\n", "Chronic diagnoses\n", "No active Acute diagnoses.\n", "Acute diagnoses\n", "Social"])
		dxRegex = "DIAGNOSES:\n" + dxRegex
		
		var medRegex = regexTheText(theText!, startOfText: "Medications", endOfText: "Encounters")
		medRegex = cleanTheSections(medRegex, badBits: ["Medications\n", "Encounters"])
		medRegex = "MEDICATIONS:\n" + medRegex
		
		var nutritionRegex = regexTheText(theText!, startOfText: "Nutrition history", endOfText: "Advanced directives")
		nutritionRegex = cleanTheSections(nutritionRegex, badBits: ["Nutrition history\n", "Advanced directives"])
		nutritionRegex = "NUTRITION:\n" + nutritionRegex
		
		var socialRegex = regexTheText(theText!, startOfText: "Social history", endOfText: "Past medical history")
		socialRegex = cleanTheSections(socialRegex, badBits: ["Past medical history", "Social history (free text)\n", "Social history\n", "Smoking status\n"])
		socialRegex = "SOCIAL HISTORY:\n" + socialRegex
		//print(socialRegex)
		
		let finalFMHParameter = defineFinalParameter(theText!, firstParameter: "Preventive care", secondParameter: "Social history")
		var fmhRegex = regexTheText(theText!, startOfText: "Family health history", endOfText: finalFMHParameter)
		fmhRegex = cleanTheSections(fmhRegex, badBits: ["Family health history\n", "Preventive care", "Social history"])
		fmhRegex = "FAMILY HEALTH HISTORY:\n" + fmhRegex
		
		let finalAllergiesParameter = defineFinalParameter(theText!, firstParameter: "Family health history", secondParameter: "Preventive care")
		var basicAllergyRegex = regexTheText(theText!, startOfText: "\\nAllergies[^(free text)]", endOfText: "Medications")
		//print(basicAllergyRegex)
		basicAllergyRegex = cleanTheSections(basicAllergyRegex, badBits: ["Allergies\n", "Drug allergies\n", "Environmental allergies\n", "No environmental allergies recorded\n", "Food allergies\n", "Medications"])
		var freeAllergyRegex = regexTheText(theText!, startOfText: "Allergies \\(free text\\)", endOfText: finalAllergiesParameter)
		//print(freeAllergyRegex)
		freeAllergyRegex = cleanTheSections(freeAllergyRegex, badBits: ["Allergies (free text)\n", "Use structured allergies to receive interaction alerts\n\n", "Food allergies:\n", "Drug Allergies\n", "Family health history", "Preventive care"])
		let allergyResults = "ALLERGIES:\n" + basicAllergyRegex + "\n" + freeAllergyRegex
		
		let finalPreventiveParameter = defineFinalParameter(theText!, firstParameter: "Nutrition history", secondParameter: "Advanced directives")
		let basicPreventiveRegex = regexTheText(theText!, startOfText: "Preventive care", endOfText: finalPreventiveParameter)
		var preventiveRegex = regexTheText(basicPreventiveRegex, startOfText: "Preventive care", endOfText: "Social history")
		preventiveRegex = cleanTheSections(preventiveRegex, badBits: ["Preventive care\n", "Social history"])
		preventiveRegex = "PREVENTIVE CARE:\n" + preventiveRegex
		
		let medHistoryRegex = regexTheText(theText!, startOfText: "Past medical history", endOfText: "\\(free text\\)")
		var pshRegex = regexTheText(medHistoryRegex, startOfText: "Major events", endOfText: "Ongoing medical problems")
		pshRegex = cleanTheSections(pshRegex, badBits: ["Major events\n", "Ongoing medical problems", "PSH:\n", "PHS:\n"])
		pshRegex = "PAST SURGICAL HISTORY:\n" + pshRegex
		var pmhRegex = regexTheText(medHistoryRegex, startOfText: "Ongoing medical problems", endOfText: "\\(free text\\)")
		pmhRegex = cleanTheSections(pmhRegex, badBits: ["Ongoing medical problems\n", "Allergies (free text)", "PMH:\n", "PHM:\n"])
		pmhRegex = "PAST MEDICAL HISTORY:\n" + pmhRegex
		
		let finalResults = ("\(ptName)\n\(ptDOB)    \(ptAge)\n\n\(dxRegex)\n\n\(socialRegex)\n\n\(medRegex)\n\n\(nutritionRegex)\n\n\(allergyResults)\n\n\(fmhRegex)\n\n\(preventiveRegex)\n\n\(pshRegex)\n\n\(pmhRegex)")
		
		pasteBoard.clearContents()
		pasteBoard.setString(finalResults, forType: NSPasteboardTypeString)
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

