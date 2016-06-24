//
//  Functions.swift
//  Chart Parsing
//
//  Created by Fool on 6/17/15.
//  Copyright (c) 2015 Fulgent Wake. All rights reserved.
//

import Cocoa
import Foundation

//Cribbed from raywenderlich.com.  Updated for Swift 2.0
extension String {
	func stringByTrimmingLeadingAndTrailingWhitespace() -> String {
		let leadingAndTrailingWhitespacePattern = "\\s*\\n"
		//The original pattern, which didn't work the way I wanted was:
		//"(?:^\\s+)|(?:\\s+$)"
		
		do {
			let regex = try RegularExpression(pattern: leadingAndTrailingWhitespacePattern, options: .dotMatchesLineSeparators)
			let range = NSMakeRange(0, self.characters.count)
			let trimmedString = regex.stringByReplacingMatches(in: self, options: .reportProgress, range:range, withTemplate:"\n")
			
			return trimmedString
		} catch _ {
			return self
		}
	}
}

//Get the name, age, and DOB from the text
func nameAgeDOB(_ theText: String) -> (String, String, String){
	var ptName = ""
	var ptAge = ""
	var ptDOB = ""
	let theSplitText = theText.components(separatedBy: "\n")
	
	var lineCount = 0
	if !theSplitText.isEmpty {
		for currentLine in theSplitText {
			if currentLine.range(of: "PRN: ") != nil {
				let ageLine = theSplitText[lineCount + 1]
				//let dobLine = theSplitText[lineCount + 4]
				ptName = theSplitText[lineCount - 1]
				ptAge = simpleRegExMatch(ageLine, theExpression: "^\\d*")
				//ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
			} else if currentLine.range(of: "DOB: ") != nil {
				let dobLine = currentLine
				ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
			}
			lineCount += 1
		}
	}
	return (ptName, ptAge, ptDOB)
	
}

//Check for the existence of certain strings in the text
//in order to determine the best string to use in the regexTheText function
func defineFinalParameter(_ theText: String, firstParameter: String, secondParameter: String) -> String {
	var theParameter = ""
	if theText.range(of: firstParameter) != nil {
		theParameter = firstParameter
	} else if theText.range(of: secondParameter) != nil {
		theParameter = secondParameter
	}
	return theParameter
}

//Check that the Diagnosis "Show by" is set to ICD-10
func checkForICD10(_ theText: String, window: NSWindow) -> Bool {
	var icd10bool = true
	let start = "Diagnoses  Show by"
	let end = "Chronic diagnoses"
	let regex = try! RegularExpression(pattern: "\(start).*?\(end)", options: RegularExpression.Options.dotMatchesLineSeparators)
	let length = theText.characters.count
	
	if let match = regex.firstMatch(in: theText, options: [], range: NSRange(location: 0, length: length)) {
		let theResult = (theText as NSString).substring(with: match.range)
		if !theResult.contains("ICD-10") {
			icd10bool = false
			//Create an alert to let the user know the diagnoses are not set to ICD10
			print("Not set to ICD10")
			//After notifying the user, break out of the program
			let theAlert = NSAlert()
			theAlert.messageText = "It appears Practice Fusion is not set to show ICD-10 diagnoses codes.  Please set the Show by option in the Diagnoses section to ICD-10 and try again."
			theAlert.beginSheetModal(for: window) { (NSModalResponse) -> Void in
				let returnCode = NSModalResponse
				print(returnCode)}
		}
	}
	return icd10bool
}
//Extract the text for the different sections from the complete text
func regexTheText(_ theText: String, startOfText: String, endOfText: String) -> String {
	var theResult = ""
	let regex = try! RegularExpression(pattern: "\(startOfText).*?\(endOfText)", options: RegularExpression.Options.dotMatchesLineSeparators)
	let length = theText.characters.count
	
	if let match = regex.firstMatch(in: theText, options: [], range: NSRange(location: 0, length: length)) {
		theResult = (theText as NSString).substring(with: match.range)
	}
	return theResult
}
	
//Clean extraneous text from the sections
func cleanTheSections(_ theSection:String, badBits:[String]) -> String {
	var cleanedText = theSection.stringByTrimmingLeadingAndTrailingWhitespace()
	for theBit in badBits {
		cleanedText = cleanedText.replacingOccurrences(of: theBit, with: "")
	}
	cleanedText = cleanedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	return cleanedText
}

//A basic regular expression search function
func simpleRegExMatch(_ theText: String, theExpression: String) -> String {
	var theResult = ""
	let regEx = try! RegularExpression(pattern: theExpression, options: [])
	let length = theText.characters.count
	
	if let match = regEx.firstMatch(in: theText, options: [], range: NSRange(location: 0, length: length)) {
		theResult = (theText as NSString).substring(with: match.range)
	}
	return theResult
}

//Adjust visit date values based on how far the visit is scheduled into the future
func addingDays (_ theDate: Date, daysToAdd: Int) -> Date {
	let components:DateComponents = DateComponents()
	(components as NSDateComponents).setValue(daysToAdd, forComponent: Calendar.Unit.day);
	let newDate = Calendar.current().date(byAdding: components, to: theDate, options: Calendar.Options(rawValue:0))
	return newDate!
}

//Add specific characters to the beginning of each line
func addCharactersToFront(_ theText:String, theCharacters:String) ->String {
	var returnText = ""
	var newTextArray = [String]()
	let textArray = theText.components(separatedBy: "\n")
	for line in textArray {
		let newLine = "- " + line
		newTextArray.append(newLine)
	}
	
	returnText = newTextArray.joined(separator: "\n")
	
	return returnText
}

//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(_ name: String) -> String {
	var fileLabellingName = String()
	var ptFirstName = ""
	var ptLastName = ""
	var ptMiddleName = ""
	var ptExtraName = ""
	let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
	
	func checkForMatchInSets(_ arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
		var result = false
		for item in arrayToCheckIn {
			if arrayToCheckFor.contains(item) {
				result = true
				break
			}
		}
		return result
	}
	
	let nameComponents = name.components(separatedBy: " ")
	
	let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
	
	if extraBitsCheck == true {
		ptLastName = nameComponents[nameComponents.count-2]
		ptExtraName = nameComponents[nameComponents.count-1]
	} else {
		ptLastName = nameComponents[nameComponents.count-1]
		ptExtraName = ""
	}
	
	if nameComponents.count > 2 {
	if nameComponents[nameComponents.count - 2] == "Van" {
		ptLastName = "Van " + ptLastName
	}
	}
	
	//Get first name
	ptFirstName = nameComponents[0]
	
	//Get middle name
	if (nameComponents.count == 3 && extraBitsCheck == true) || nameComponents.count < 3 {
		ptMiddleName = ""
	} else {
		ptMiddleName = nameComponents[1]
	}
	
	fileLabellingName = "\(ptLastName)\(ptFirstName)\(ptMiddleName)\(ptExtraName)"
	fileLabellingName = fileLabellingName.replacingOccurrences(of: " ", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "-", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "'", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "(", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: ")", with: "")
	fileLabellingName = fileLabellingName.replacingOccurrences(of: "\"", with: "")
	
	
return fileLabellingName
}
	
	//A way to extract text using mapping and filtering.  I've changed to using regular expressions
	//func extractTheText(theText: String, startOfText: String, endOfText: String) -> [String] {
	//		let theArray = theText.componentsSeparatedByString(startOfText)
	//			.map { $0.componentsSeparatedByString(endOfText) }
	//			.filter { $0.count > 1 }
	//			.map { $0[0] }
	//		return theArray
	//
	//}
	
