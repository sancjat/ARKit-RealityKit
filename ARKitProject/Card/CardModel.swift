//
//  CardModel.swift
//  ARKitProject
//
//  Created by Santosh Kumari on 24/10/22.
//

import Foundation
import ARKit


typealias SocialLinkData = (link: String, type: SocialLink)

/// The Information For The Business Card Node & Contact Details
struct BusinessCardData{
    
    var firstName: String
    var surname: String
    var position: String
    var company: String
    var address: BusinessAddress
    var website: SocialLinkData
    var phoneNumber: String
    var email: String
    var linkedAccount: SocialLinkData
}

/// The Associates Business Address
struct BusinessAddress{
    
    var street: String
    var city: String
    var state: String
    var postalCode: String
    var coordinates: (latittude: Double?, longtitude: Double?)
}

/// The Type Of Social Link
enum SocialLink: String{
    case Website
    case Linkedin
}

class Card: SCNNode {
    
    var nameTimer: Timer?
    var time = 0
    
    let Flipped_Rotation = SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(180))
    var interactiveButtons = [SCNNode]()
    
    var cardData: BusinessCardData!
    var cardType: String = ""
    var businessCardTarget: SCNNode!
    var firstNameText: SCNText!
    var surnameText: SCNText!
    var linkedAccountButton: SCNNode!   { didSet { linkedAccountButton.name = "Linkedin" } }
    var websiteButton: SCNNode!         { didSet { websiteButton.name = "Website"} }
    var phoneNumberButton: SCNNode!     { didSet { phoneNumberButton.name = "PhoneNumber" } }
    var textMessageButton: SCNNode!     { didSet { textMessageButton.name = "TextMessage" } }
    var emailButton: SCNNode!           { didSet { emailButton.name = "Email" } }
    var mapButton: SCNNode!             { didSet { emailButton.name = "Map" } }
    
    //---------------------
    //MARK: - Intialization
    //---------------------
    
    /// Creates The Business Card
    init(data: BusinessCardData, cardType: String) {
        
        super.init()
        
        //1. Set The Data For The Card
        self.cardData = data
        self.cardType = cardType
        
        //2. Extrapolate All The Nodes & Geometries
        guard let template = SCNScene(named: cardType.description),
            let cardRoot = template.rootNode.childNode(withName: "RootNode", recursively: false),
            let target = cardRoot.childNode(withName: "BusinessCardTarget", recursively: false),
            let firstNameText = cardRoot.childNode(withName: "FirstName", recursively: false)?.geometry as? SCNText,
            let surnameText = cardRoot.childNode(withName: "Surname", recursively: false)?.geometry as? SCNText,
            let linkedAccountButton = cardRoot.childNode(withName: "Linkedin", recursively: false),
            let websiteButton = cardRoot.childNode(withName: "Website", recursively: false),
            let phoneNumberButton = cardRoot.childNode(withName: "PhoneNumber", recursively: false),
            let textMessageButton = cardRoot.childNode(withName: "TextMessage", recursively: false),
            let emailButton = cardRoot.childNode(withName: "Email", recursively: false),
            let mapButton = cardRoot.childNode(withName: "Map", recursively: false)
            
        else { fatalError("Error Getting Business Card Node Data") }
        
        //4. Assign These To The BusinessCard Node
        self.businessCardTarget = target
        self.firstNameText = firstNameText
        self.firstNameText.flatness = 0
        self.surnameText = surnameText
        self.surnameText.flatness = 0
        self.linkedAccountButton = linkedAccountButton
        self.websiteButton = websiteButton
        self.phoneNumberButton = phoneNumberButton
        self.textMessageButton = textMessageButton
        self.emailButton = emailButton
        self.mapButton = mapButton
        
        //5. Add It To The Hieracy
        self.addChildNode(cardRoot)
        self.eulerAngles.x = -.pi / 2
        
        //5. Store All The Interactive Elements
        interactiveButtons.append(phoneNumberButton)
        interactiveButtons.append(textMessageButton)
        interactiveButtons.append(emailButton)
        interactiveButtons.append(linkedAccountButton)
        interactiveButtons.append(websiteButton)
        interactiveButtons.append(mapButton)
        
        //6. Setup The Elements
        setBaseConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Business Card Coder Not Implemented") }
    
    deinit { flushFromMemory() }
    
    //---------------------------
    //MARK: - Card Elements Setup
    //---------------------------
    
    /// Sets Up The Base Configuration Of The Business Card & Makes All Elements Invisible To The User
    func setBaseConfiguration(){
        
        //1. Inavalidate The Timer
        nameTimer?.invalidate()
        time = 0
        businessCardTarget.isHidden = true
        
        //2. Clear The Name Data
        self.firstNameText.string = ""
        self.surnameText.string = ""
        
        //4. Rotate All Our Interactive Buttons So We Cant See Them
        interactiveButtons.forEach{ $0.rotation = Flipped_Rotation }
    }
    
    //------------------------------
    //MARK: - Card Element Animation
    //------------------------------
    
    /// Aniumates All The Elements Of The Business Card & Makes Them Visible To The User
    func animateBusinessCard() {
        let rotationAsRadian = CGFloat(GLKMathDegreesToRadians(180))
        let flipAction = SCNAction.rotate(by: rotationAsRadian, around: SCNVector3(0, 1, 0), duration: 1.5)
        self.animateBaseElementsWithAction(flipAction)
    }

    /// Animates All Elements Except The User Profile Image
    ///
    /// - Parameter flipAction: SCNAction
    func animateBaseElementsWithAction(_ flipAction: SCNAction){
        
        //2. Animate The First Name & Surname
        self.animateTextGeometry(self.firstNameText, forName: self.cardData.firstName, completed: {
            
            self.animateTextGeometry(self.surnameText, forName: self.cardData.surname, completed: {
                
                //3. Animate All The Buttons
                self.interactiveButtons.forEach{ $0.runAction(flipAction)}
                
            })
        })
    }
    
    /// Animates The Presentation Of SCNText
    ///
    /// - Parameters:
    ///   - textGeometry: SCNText
    ///   - name: String
    ///   - completed: () -> Void
    func animateTextGeometry(_ textGeometry: SCNText, forName name: String, completed: @escaping () -> Void ){
        
        //1. Get The Characters From The Name
        let characters = Array(name)
        
        //2. Run The Name Animation
        nameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            
            //a. If The Current Time Doesnt Equal The Count Of Our Characters Then Continue To Animate Our Text
            if self?.time != characters.count {
                let currentText: String = textGeometry.string as! String
                textGeometry.string = currentText + String(characters[(self?.time)!])
                self?.time += 1
            }else{
                //b. Invalide The Timer, Reset The Variables & Escape
                timer.invalidate()
                self?.time = 0
                completed()
            }
        }
    }
    
    //---------------
    //MARK: - Cleanup
    //---------------

    /// Removes All SCNMaterials & Geometries From An SCNNode
    func flushFromMemory(){
        
        print("Cleaning Business Card")
        
        if let parentNodes = self.parent?.childNodes{ parentNodes.forEach {
            $0.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            $0.geometry = nil
            $0.removeFromParentNode()
            }
        }
        
        for node in self.childNodes{
            node.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            node.geometry = nil
            node.removeFromParentNode()
        }
    }
}
