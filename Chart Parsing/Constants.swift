//
//  Constants.swift
//  PTVN Builder
//
//  Created by Fool on 2/1/16.
//  Copyright © 2016 Fulgent Wake. All rights reserved.
//

import Foundation

let dxStartOfText = "\\nDiagnoses"
let dxEndOfText = "Social"
let dxBadBits = ["Chronic diagnoses\n", "No active Acute diagnoses.\n", "Acute diagnoses\n", "Diagnoses", "Social", "Term\n", "Show by"]

let medStartOfText = "\\nMedications"
let medEndOfText = "Encounters"
let medBadBits = ["Medications\n", "Encounters", " Show historical"]

let nutritionStartOfText = "\\nNutrition history"
let nutritionEndOfText = "Advanced directives"
let nutritionBadBits = ["Nutrition history\n", "Advanced directives"]

let socialStartOfText = "\\nSocial history\\nSmoking status"
let socialEndOfText = "Past medical history"
let socialBadBits = ["Past medical history", "Social history (free text)\n", "Social history\n", "Smoking status\n"]

let fmhStartOfText = "Family health history"
let fmhEndOfTextFirstParameter = "Preventive care"
let fmhEndOfTextSecondParameter = "Social history"
let fmhBadBits = ["Family health history\n", "Preventive care", "Social history"]

//let basicAllergyStartOfText = "\nAllergies\\nDrug allergies"
let basicAllergyStartOfText = "\nAllergies\n"
let basicAllergyEndOfText = "Medications"
let basicAllergyBadBits = ["Drug allergies\n", "Environmental allergies\n", "No environmental allergies recorded\n", "Food allergies\n", "Allergies\n", "Medications", "You have previously recorded allergies in a free-text note", "To receive interaction alerts, record the note in a structured format here. Record",  "(free-text note) Delete"]
let freeAllergyEndOfTextFirstParameter = "Family health history"
let freeAllergyEndOfTextSecondParameter = "Preventive care"
let freeAllergyStartOfText = "Allergies\nUse structured"
let freeAllergyBadBits = ["Allergies (free text)\n", "ALLERGIES:", "ALLERGIES", "Use structured allergies to receive interaction alerts\n", "Food allergies:", "Food Allergies:", "Food Allergies", "Food allergies\n", "Food Allergies\n", "Environmental allergies:\n", "Environmental allergies: ", "Environmental allergies\n", "Environmental Allergies\n", "Drug allergies:", "Drug allergies-", "Drug allergies", "No Known Drug Allergies", "No Known", "Drug Allergies:", "Drug Allergies", "Family health history", "Preventive care", "No food allergies recorded\n", "Allergies\n"]

let preventiveEndOfTextFirstParameter = "Nutrition history"
let preventiveEndOfTextSecondParameter = "Advance directives"
let preventiveStartOfText = "Preventive care"
let otherPreventiveEndOfTextFirstParameter = "Social history"
let preventiveBadBits = ["Preventive care\n", "Social history", "Advance directives"]

let medhistoryEndOfTextFirstParameter = "Family health history\n" //was "Allergies\n"
let medhistoryEndOfTextSecondParameter = "Preventive care" //can probably get rid of this
let medhistoryStartOfText = "Past medical history"

let pshStartOfText = "Major events"
let pshEndOfText = "Ongoing medical problems"
let pshBadBits = ["Major events\n", "Ongoing medical problems", "PSH:\n", "PHS:\n"]

let pmhStartOfText = "Ongoing medical problems"
//Use this?
let pmhEndOfText = "Family health history"
let pmhBadBits = ["Ongoing medical problems\n", "Allergies (free text)", "Allergies\n", "PMH:\n", "PHM:\n", "Preventive care", "Family health history"]

let visitBoilerplateText = "CC:  \nProblems:  \n\n\nS:  \n\nLocation:  \nSeverity:  \nQuality:  \nDuration:  \nTiming:  \nContext:  \nModifying factors:  \nAssociated symptoms:  \n\n\nNEW PMH:  \n\n\nA(Charge):  \n\n\nP(lan):  \n\n**Rx**  \n\n\nO(PE):  \n\n\n"





