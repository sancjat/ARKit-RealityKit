//
//  MainViewController.swift
//  ARKitProject
//
//  Created by Santosh Kumari on 24/10/22.
//

import UIKit

class MainViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Types.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mycell", for: indexPath)
        let label = cell.viewWithTag(1) as! UILabel
        if let types = Types.element(at: indexPath.row) {
            label.text = types.description
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let types = Types.element(at: indexPath.row) {
            if types == .FaceTracking || types == .RealWorldTracking {
                let vc = getStoryBoard(vcName: "ViewController") as! ViewController
                vc.type = Types.element(at: indexPath.row)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = getStoryBoard(vcName: "CardReaderViewController") as! CardReaderViewController
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}


