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
		//"(?:^\\s+)|(?:\\s+$)"
		
		do {
			let regex = try NSRegularExpression(pattern: leadingAndTrailingWhitespacePattern, options: .DotMatchesLineSeparators)
			let range = NSMakeRange(0, self.characters.count)
			let trimmedString = regex.stringByReplacingMatchesInString(self, options: .ReportProgress, range:range, withTemplate:"\n")
			
			return trimmedString
		} catch _ {
			return self
		}
	}
}

//Get the name, age, and DOB from the text
func nameAgeDOB(theText: String) -> (String, String, String){
	var ptName = ""
	var ptAge = ""
	var ptDOB = ""
	let theSplitText = theText.componentsSeparatedByString("\n")
	
	var lineCount = 0
	if !theSplitText.isEmpty {
		for currentLine in theSplitText {
			if currentLine.rangeOfString("PRN: ") != nil {
				let ageLine = theSplitText[lineCount + 1]
				//let dobLine = theSplitText[lineCount + 4]
				ptName = theSplitText[lineCount - 1]
				ptAge = simpleRegExMatch(ageLine, theExpression: "^\\d*")
				//ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
			} else if currentLine.rangeOfString("DOB: ") != nil {
				let dobLine = currentLine
				ptDOB = simpleRegExMatch(dobLine, theExpression: "\\d./\\d./\\d*")
			}
			lineCount++
		}
	}
	return (ptName, ptAge, ptDOB)
	
}

//Check for the existence of certain strings in the text
//in order to determine the best string to use in the regexTheText function
func defineFinalParameter(theText: String, firstParameter: String, secondParameter: String) -> String {
	var theParameter = ""
	if theText.rangeOfString(firstParameter) != nil {
		theParameter = firstParameter
	} else if theText.rangeOfString(secondParameter) != nil {
		theParameter = secondParameter
	}
	return theParameter
}

//Extract the text for the different sections from the complete text
func regexTheText(theText: String, startOfText: String, endOfText: String) -> String {
	var theResult = ""
	let regex = try! NSRegularExpression(pattern: "\(startOfText).*?\(endOfText)", options: NSRegularExpressionOptions.DotMatchesLineSeparators)
	let length = theText.characters.count
	
	if let match = regex.firstMatchInString(theText, options: [], range: NSRange(location: 0, length: length)) {
		theResult = (theText as NSString).substringWithRange(match.range)
	}
	return theResult
}
	
//Clean extraneous text from the sections
func cleanTheSections(theSection:String, badBits:[String]) -> String {
	var cleanedText = theSection.stringByTrimmingLeadingAndTrailingWhitespace()
	for theBit in badBits {
		cleanedText = cleanedText.stringByReplacingOccurrencesOfString(theBit, withString: "")
	}
	cleanedText = cleanedText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	return cleanedText
}

//A basic regular expression search function
func simpleRegExMatch(theText: String, theExpression: String) -> String {
	var theResult = ""
	let regEx = try! NSRegularExpression(pattern: theExpression, options: [])
	let length = theText.characters.count
	
	if let match = regEx.firstMatchInString(theText, options: [], range: NSRange(location: 0, length: length)) {
		theResult = (theText as NSString).substringWithRange(match.range)
	}
	return theResult
}

//Adjust visit date values based on how far the visit is scheduled into the future
func addingDays (theDate: NSDate, daysToAdd: Int) -> NSDate {
	let components:NSDateComponents = NSDateComponents()
	components.setValue(daysToAdd, forComponent: NSCalendarUnit.Day);
	let newDate = NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: theDate, options: NSCalendarOptions(rawValue:0))
	return newDate!
}

//Add specific characters to the beginning of each line
func addCharatersToFront(theText:String, theCharacters:String) ->String {
	var returnText = ""
	var newTextArray = [String]()
	let textArray = theText.componentsSeparatedByString("\n")
	for line in textArray {
		let newLine = "- " + line
		newTextArray.append(newLine)
	}
	
	returnText = newTextArray.joinWithSeparator("\n")
	
	return returnText
}

//Parse a string containing a full name into it's components and returns
//the version of the name we use to label files
func getFileLabellingName(name: String) -> String {
	var fileLabellingName = String()
	var ptFirstName = ""
	var ptLastName = ""
	var ptMiddleName = ""
	var ptExtraName = ""
	let extraNameBits = ["Sr", "Jr", "II", "III", "IV", "MD"]
	
	func checkForMatchInSets(arrayToCheckIn: [String], arrayToCheckFor: [String]) -> Bool {
		var result = false
		for item in arrayToCheckIn {
			if arrayToCheckFor.contains(item) {
				result = true
				break
			}
		}
		return result
	}
	
	let nameComponents = name.componentsSeparatedByString(" ")
	
	let extraBitsCheck = checkForMatchInSets(nameComponents, arrayToCheckFor: extraNameBits)
	
	if extraBitsCheck == true {
		ptLastName = nameComponents[nameComponents.count-2]
		ptExtraName = nameComponents[nameComponents.count-1]
	} else {
		ptLastName = nameComponents[nameComponents.count-1]
		ptExtraName = ""
	}
	
	if nameComponents[nameComponents.count - 2] == "Van" {
		ptLastName = "Van " + ptLastName
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
	fileLabellingName = fileLabellingName.stringByReplacingOccurrencesOfString(" ", withString: "")
	fileLabellingName = fileLabellingName.stringByReplacingOccurrencesOfString("-", withString: "")
	fileLabellingName = fileLabellingName.stringByReplacingOccurrencesOfString("'", withString: "")
	fileLabellingName = fileLabellingName.stringByReplacingOccurrencesOfString("(", withString: "")
	fileLabellingName = fileLabellingName.stringByReplacingOccurrencesOfString(")", withString: "")
	
	
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
	
