//
//  AddHomeController.swift
//  Podcasts
//
//  Created by Artyom Schiopu on 7/22/18.
//  Copyright © 2018 2018 BZG Inc. All rights reserved.
//

import UIKit

class AddHomeController: UIViewController, UITableViewDataSource {

    
    @IBOutlet var tableView:UITableView!

    var numberOFTables = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOFTables = UserDefaults.standard.object(forKey: "deletedTables") as! [String]
       
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOFTables.count
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mainCell = UITableViewCell()
        return mainCell
    }
}
