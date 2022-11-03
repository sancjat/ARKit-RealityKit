//
//  Utility.swift
//  ARKitProject
//
//  Created by Santosh Kumari on 24/10/22.
//

import Foundation
import UIKit

enum Types : Int, CaseIterable {
    case FaceTracking
    case RealWorldTracking
    case CardReader
    
    var description: String {
           switch self {
           case .FaceTracking:
               return "Face Recognizer"
           case .RealWorldTracking:
               return "Real World Object Placement"
           case .CardReader:
               return "Business Card Reader"
        }
    }
    
    static func element(at index: Int) -> Types? {
       let elements = [Types.FaceTracking, Types.RealWorldTracking, Types.CardReader]

       if index >= 0 && index < elements.count {
          return elements[index]
       } else {
          return nil
       }
    }
}


func getStoryBoard(vcName : String) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: vcName)
    return vc
}



