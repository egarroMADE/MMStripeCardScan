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
    @IBOutlet weak var dniLabel: UILabel!
    
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
                        case .completed(let scannedCard):
                        strongSelf.creditCardLabel.text = scannedCard.pan //This could be nil
                        //This could be an empty string:
                        let expiryDate = [scannedCard.expiryMonth,scannedCard.expiryYear].compactMap { $0 }
                                                                 .joined(separator: "/")
                        strongSelf.expiryDateLabel.text = expiryDate
                        strongSelf.dniLabel.text = scannedCard.dni //This could be nil
                    case .canceled:
                        print("scan canceled")
                    case .failed(let error):
                          print("scan failed: \(error.localizedDescription)")
                    }
                }
 
    }
}

