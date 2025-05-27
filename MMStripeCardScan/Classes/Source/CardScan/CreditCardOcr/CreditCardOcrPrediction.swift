//
//  CreditCardOcrPrediction.swift
//  ocr-playground-ios
//
//  Created by Sam King on 3/19/20.
//  Copyright © 2020 Sam King. All rights reserved.
//

import CoreGraphics
import Foundation

struct UxFrameConfidenceValues {
    let hasOcr: Bool
    let uxPan: Double
    let uxNoPan: Double
    let uxNoCard: Double

    func toArray() -> [Double] {
        return [hasOcr ? 1.0 : 0.0, uxPan, uxNoPan, uxNoCard]
    }
}

enum CenteredCardState {
    case numberSide
    case nonNumberSide
    case noCard

    func hasCard() -> Bool {
        return self == .numberSide || self == .nonNumberSide
    }
}

struct CreditCardOcrPrediction {
    let image: CGImage
    let ocrCroppingRectangle: CGRect
    let number: String?
    let expiryMonth: String?
    let expiryYear: String?
    let name: String?
    let dni: String?
    let computationTime: Double
    let numberBoxes: [CGRect]?
    let expiryBoxes: [CGRect]?
    let nameBoxes: [CGRect]?

    // this is only used by Card Verify and the Liveness check and filled in by the UxModel
    var centeredCardState: CenteredCardState?
    var uxFrameConfidenceValues: UxFrameConfidenceValues?

    init(
        image: CGImage,
        ocrCroppingRectangle: CGRect,
        number: String?,
        expiryMonth: String?,
        expiryYear: String?,
        name: String?,
        dni: String?,
        computationTime: Double,
        numberBoxes: [CGRect]?,
        expiryBoxes: [CGRect]?,
        nameBoxes: [CGRect]?,
        centeredCardState: CenteredCardState? = nil,
        uxFrameConfidenceValues: UxFrameConfidenceValues? = nil
    ) {

        self.image = image
        self.ocrCroppingRectangle = ocrCroppingRectangle
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.name = name
        self.dni = dni
        self.computationTime = computationTime
        self.numberBoxes = numberBoxes
        self.expiryBoxes = expiryBoxes
        self.nameBoxes = nameBoxes
        self.centeredCardState = centeredCardState
        self.uxFrameConfidenceValues = uxFrameConfidenceValues
    }

    func with(uxPrediction: UxModelOutput) -> CreditCardOcrPrediction {
        let uxFrameConfidenceValues: UxFrameConfidenceValues? = {
            if let (hasPan, hasNoPan, hasNoCard) = uxPrediction.confidenceValues() {
                let hasOcr = self.number != nil
                return UxFrameConfidenceValues(
                    hasOcr: hasOcr,
                    uxPan: hasPan,
                    uxNoPan: hasNoPan,
                    uxNoCard: hasNoCard
                )
            }
            return nil
        }()

        return CreditCardOcrPrediction(
            image: self.image,
            ocrCroppingRectangle: self.ocrCroppingRectangle,
            number: self.number,
            expiryMonth: self.expiryMonth,
            expiryYear: self.expiryYear,
            name: self.name,
            dni: self.dni,
            computationTime: self.computationTime,
            numberBoxes: self.numberBoxes,
            expiryBoxes: self.expiryBoxes,
            nameBoxes: self.nameBoxes,
            centeredCardState: uxPrediction.cardCenteredState(),
            uxFrameConfidenceValues: uxFrameConfidenceValues
        )
    }

    static func emptyPrediction(cgImage: CGImage) -> CreditCardOcrPrediction {
        CreditCardOcrPrediction(
            image: cgImage,
            ocrCroppingRectangle: CGRect(),
            number: nil,
            expiryMonth: nil,
            expiryYear: nil,
            name: nil,
            dni: nil,
            computationTime: 0.0,
            numberBoxes: nil,
            expiryBoxes: nil,
            nameBoxes: nil
        )
    }

    var expiryForDisplay: String? {
        guard let month = expiryMonth, let year = expiryYear else { return nil }
        return "\(month)/\(year)"
    }

    var expiryAsUInt: (UInt, UInt)? {
        guard let month = expiryMonth.flatMap({ UInt($0) }) else { return nil }
        guard let year = expiryYear.flatMap({ UInt($0) }) else { return nil }

        return (month, year)
    }

    var numberBox: CGRect? {
        let xmin = numberBoxes?.map { $0.minX }.min() ?? 0.0
        let xmax = numberBoxes?.map { $0.maxX }.max() ?? 0.0
        let ymin = numberBoxes?.map { $0.minY }.min() ?? 0.0
        let ymax = numberBoxes?.map { $0.maxY }.max() ?? 0.0
        return CGRect(x: xmin, y: ymin, width: (xmax - xmin), height: (ymax - ymin))
    }

    var expiryBox: CGRect? {
        return expiryBoxes.flatMap { $0.first }
    }

    var numberBoxesInFullImageFrame: [CGRect]? {
        guard let boxes = numberBoxes else { return nil }
        let cropOrigin = ocrCroppingRectangle.origin
        return boxes.map {
            CGRect(
                x: $0.origin.x + cropOrigin.x,
                y: $0.origin.y + cropOrigin.y,
                width: $0.size.width,
                height: $0.size.height
            )
        }
    }

    static func likelyExpiry(_ string: String) -> (String, String)? {
        guard let regex = try? NSRegularExpression(pattern: "^.*(0[1-9]|1[0-2])[./]([1-2][0-9])$")
        else {
            return nil
        }

        let result = regex.matches(in: string, range: NSRange(string.startIndex..., in: string))

        if result.count == 0 {
            return nil
        }

        guard let nsrange1 = result.first?.range(at: 1),
            let range1 = Range(nsrange1, in: string)
        else { return nil }
        guard let nsrange2 = result.first?.range(at: 2),
            let range2 = Range(nsrange2, in: string)
        else { return nil }

        return (String(string[range1]), String(string[range2]))
    }

    static func pan(_ text: String) -> String? {
        let digitsAndSpace = text.reduce(true) { $0 && (($1 >= "0" && $1 <= "9") || $1 == " ") }
        let number = text.compactMap { $0 >= "0" && $0 <= "9" ? $0 : nil }.map { String($0) }
            .joined()

        guard digitsAndSpace else { return nil }
        guard CreditCardUtils.isValidNumber(cardNumber: number) else { return nil }
        return number
    }
    
    static func dni(_ text: String) -> String? {
        // Split the input into lines
        guard text.contains("<") else { return nil }
        
        let line1 = text.prefix(30)
        let line2 = text.dropFirst(30).prefix(30)
        //let line3 = text.dropFirst(60).prefix(30)
        
        // Extract fields as per MRZ spec
        //let docType = line1.prefix(2)
        let nationality = line1.dropFirst(2).prefix(3)
        let serialNumber = line1.dropFirst(5).prefix(9)
        let field3CheckDigit = line1.dropFirst(14).prefix(1)
        let dniNumber = line1.dropFirst(15).prefix(9)
        let stuffing1 = line1.dropFirst(24).prefix(6)
        
        let dob = line2.prefix(6)
        let dobCheckDigit = line2.dropFirst(6).prefix(1)
        let sex = line2.dropFirst(7).prefix(1)
        let expiry = line2.dropFirst(8).prefix(6)
        let expiryCheckDigit = line2.dropFirst(14).prefix(1)
        //let nationality2 = line2.dropFirst(15).prefix(3)
        let stuffing2 = line2.dropFirst(18).prefix(11)
        let overallCheckDigit = line2.dropFirst(29).prefix(1)
        
        guard stuffing1.allSatisfy({ $0 == "<" }) && stuffing2.allSatisfy({ $0 == "<" }) else {
            return nil
        }
        print ("All stuffings correct!")
        
        guard nationality == "ESP" else {
            return nil
        }
        print ("Nationality correct!")
        
        // Compute and compare check digits
        guard
            isValidCheckDigit(for: String(serialNumber), expected: field3CheckDigit),
            isValidCheckDigit(for: String(dob), expected: dobCheckDigit),
            isValidCheckDigit(for: String(expiry), expected: expiryCheckDigit),
            isValidCheckDigit(for: String(serialNumber) + field3CheckDigit + dniNumber + dob + dobCheckDigit + expiry + expiryCheckDigit, expected: overallCheckDigit)
        else {
            return nil
        }
        print ("All validation digits correct!")
        
        // Validate gender:
        guard sex == "M" || sex == "F" || sex == "<" else {
            return nil
        }
        print("Gender correct!")
        print("DNI found!")
        
        return text
    }
    
    private static func isValidCheckDigit(for data: String, expected: Substring) -> Bool {
        guard let expectedDigit = Int(expected) else { return false }
        return computeCheckDigit(data) == expectedDigit
    }
        
    // ICAO 9303 check digit computation
    private static func computeCheckDigit(_ input: String) -> Int {
        let weights = [7, 3, 1]
        var sum = 0
        
        for (i, char) in input.enumerated() {
            let value: Int
            switch char {
            case "0"..."9":
                value = Int(String(char))!
            case "A"..."Z":
                value = Int(char.asciiValue! - Character("A").asciiValue! + 10)
            case "<":
                value = 0
            default:
                return -1 // Invalid character
            }
            sum += value * weights[i % 3]
        }
        return sum % 10
    }
    
}
