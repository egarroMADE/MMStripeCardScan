//
//  String+Localized.swift
//  StripeCore
//
//  Created by Mel Ludowise on 8/4/21.
//  Copyright © 2021 Stripe, Inc. All rights reserved.
//

import Foundation

@_spi(STP) extension String {
    public enum Localized {
        public static var close: String {
            return STPLocalizedString("Close", "Text for close button")
        }

        public static var tryAgain: String {
            return STPLocalizedString("Try again", "Text for a retry button")
        }

        public static var scan_card_title_capitalization: String {
            STPLocalizedString("Scan Card", "Text for button to scan a credit card")
        }

        public static var scan_card: String {
            STPLocalizedString("Scan card", "Button title to open camera to scan credit/debit card")
        }

        public static var scan_card_privacy_link_text: String {
            // THIS STRING SHOULD NOT BE MODIFIED
            STPLocalizedString(
                "Please position your card within the rectangle above. OnBoard will use the camera to automatically extract and populate only the card information required on the form.",
                "Informational text informing the user how to scan and what OnBoard uses the scanned information for"
            )
        }

        public static func scanCardExpectedPrivacyLinkText() -> NSAttributedString? {
            let stringData = Data(String.Localized.scan_card_privacy_link_text.utf8)
            let stringOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue,
            ]

            return try? NSAttributedString(
                data: stringData,
                options: stringOptions,
                documentAttributes: nil
            )
        }
    }
}
