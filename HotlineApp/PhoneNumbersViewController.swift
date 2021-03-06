//
//  PhoneNumbersViewController.swift
//  HotlineApp
//
//  Created by Alex Yang on 4/22/17.
//  Copyright © 2017 Alex Yang. All rights reserved.
//

import UIKit

class PhoneNumbersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var Footer: UIView!
    
    @IBOutlet weak var ActivityUpdate: UIBarButtonItem!
    var tag: Int?
    var indicator: UIActivityIndicatorView?
    @IBOutlet weak var tableView: UITableView!
    var colormaker = ColorCreator()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Activate the footer for UI aesthetic purposes
        self.tableView.tableFooterView = Footer
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.isHidden = false
        
        
        //Setup the activityIndicator for update status
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        ActivityUpdate.customView = indicator
        
        
        //Setup listener for reloading data
        let nc = NotificationCenter.default // Note that default is now a property, not a method call
        nc.addObserver(forName:Notification.Name(rawValue:"test"),
                       object:nil, queue:nil) {
                        notification in
                        self.indicator?.stopAnimating()
                        self.tableView.reloadData()
                        print("reloaded")
        }    }
    
    //If the update button is tapped
    @IBAction func UpdateTapped(_ sender: UIBarButtonItem) {
        indicator?.startAnimating()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"update"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barTintColor =  colormaker.UIColorFromHex(hex: 0xEB5757)
        self.navigationController?.navigationBar.tintColor =  colormaker.UIColorFromHex(hex: 0xFDE6E8)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:colormaker.UIColorFromHex(hex: 0xFDE6E8)]
       
        switch tag! {
        case 0:
            self.title = "Medical Hotlines"
        case 1:
            self.title = "Animal Hotlines"
        case 2:
            self.title = "Abuse Hotlines"
        case 3:
            self.title = "Self Care Hotlines"
        case 4:
            self.title = "Trafficking Hotlines"
        case 5:
            self.title = "Other Hotlines"
        default: break
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var test = Categories.categoryDict[tag!]! as [String: [[String]]]
        return test["Load"]!.count
    }
    
    //Decides how each row will look like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell") as! TableCellSubclass
        let array =  (Categories.categoryDict[tag!]?["Load"])!
        cell.Name.text = array[indexPath.item][0]
        if(array[indexPath.item][3] == "Online") {
            cell.Hours.text = "Hours: "+array[indexPath.item][2]
            cell.Status.text = array[indexPath.item][3]
        } else if(array[indexPath.item][3] == "None") {
            cell.Status.text = "Hours not listed"
            cell.Status.textColor = colormaker.UIColorFromHex(hex: 0xF2994A)
            cell.Hours.text = ""
        } else if (array[indexPath.item][3] == "Variable"){
            let timechecker = OfflineOnlineChecker()
            cell.Hours.text =  "Hours: "+array[indexPath.item][2]
            if(timechecker.check(timein: Int(array[indexPath.item][5])!,timeout: Int(array[indexPath.item][6])!)){
                cell.Status.text = "Online"
            } else {
                cell.Status.text = "Offline"
                cell.Status.textColor = colormaker.UIColorFromHex(hex: 0xEB5757)
                
            }
        }
        cell.Call.setTitle(array[indexPath.item][1], for: .normal)
        
        cell.National.text = array[indexPath.item][4]
        
        return cell
    }
    
    
    //Buttons that call a number
    
    @IBAction func Call911(_ sender: Any) {
        guard let number = URL(string: "telprompt://" + "911") else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    @IBAction func Call(_ sender: UIButton) {
        print(sender.currentTitle!)
        guard let number = URL(string: "telprompt://" + sender.currentTitle!) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    
}
