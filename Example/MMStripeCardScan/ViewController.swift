//
//  ViewController.swift
//  MMStripeCardScan
//
//  Created by egarroMADE on 06/27/2023.
//  Copyright (c) 2023 egarroMADE. All rights reserved.
//

import UIKit
import MMStripeCardScan

class ViewController: UIViewController {

    @IBOutlet weak var creditCardLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let cardScanSheet = CardScanSheet()
        cardScanSheet.present(from: self) { [weak self] result in
                    guard let strongSelf = self else { return }
                    switch result {
                        case .completed(let scannedCard, let expiryMonth, let expiryYear):
                        strongSelf.creditCardLabel.text = scannedCard.pan
                        
                        let expiryDate = [expiryMonth,expiryYear].compactMap { $0 }
                                                                 .joined(separator: "/")
                        strongSelf.expiryDateLabel.text = expiryDate
                    case .canceled:
                        print("scan canceled")
                    case .failed(let error):
                          print("scan failed: \(error.localizedDescription)")
                    }
                }
 
    }
}

