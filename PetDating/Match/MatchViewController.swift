//
//  MatchViewController.swift
//  PetDating
//
//  Created by Trương Duy Tân on 08/09/2023.
//

import UIKit

class MatchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackGround()
    }
    
    func setBackGround(){
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Match2")!)
    }
}
