//
//  VerifyFrames.swift
//  StripeCardScan
//
//  Created by Jaime Park on 11/19/21.
//

import Foundation
@_spi(STP) import MMStripeCore

struct VerifyFrames: Encodable {
    let clientSecret: String
    /// A base64 encoding of 5 `VerificationFramesData` entries
    let verificationFramesData: String
}
