//
//  CardReaderViewController.swift
//  ARKitProject
//
//  Created by Santosh Kumari on 24/10/22.
//

import UIKit
import ARKit
import MessageUI

class CardReaderViewController: UIViewController {
    
    @IBOutlet weak var augmentedRealityView: ARSCNView!
    var targetAnchor: ARImageAnchor?
    var augmentedRealitySession = ARSession()
    var businessCardPlaced = false
    var card: Card!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartSession()
    }
    
    override func didReceiveMemoryWarning() {
        print("Memory Warning")
        flushFromMemory()
        restartSession()
    }
    
    deinit {
        flushFromMemory()
    }
    
    func restartSession() {
        setupARSession()
        setUpCard()
    }
    
    func setupARSession() {
        //1. Setup Our Tracking Images
        guard let trackingImages =  ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            print("Folder not found")
            return
        }
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        
        //2. Configure & Run Our ARSession
        augmentedRealitySession = ARSession()
        augmentedRealityView.session = augmentedRealitySession
        augmentedRealitySession.delegate = self
        augmentedRealityView.delegate = self
        augmentedRealitySession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    /// Create Business Card
    func setUpCard(){
        
        //1. Create Our Card
        let businessCardData = BusinessCardData(firstName: "Santosh",
                                                surname: "Kumari",
                                                position: "Senior Software Engineer",
                                                company: "GlobalLogic",
                                                address: BusinessAddress(street: "Plot No.7, Oxygen Business Park SEZ, Tower, 3, Noida-Greater Noida Expy",
                                                                         city: "Noida", state: "Uttar Pradesh", postalCode: "201304",
                                                                         coordinates: (latittude: 28.538700, longtitude: 77.364710)),
                                                website: SocialLinkData(link: "https://www.globallogic.com", type: .Website),
                                                phoneNumber: "+1-408-273-8900",
                                                email: "info@globallogic.com",
                                                linkedAccount: SocialLinkData(link: "https://www.linkedin.com/company/globallogic/mycompany/verification/", type: .Linkedin))
        
        //2. Assign It To The Card Node
        card = Card(data: businessCardData, cardType: "art.scnassets/BusinessCardTemplateA.scn" )
       
    }
    
    
    func flushFromMemory() {
        print("Cleaning")
        card = nil
        targetAnchor = nil
        augmentedRealityView.session.delegate = nil
        augmentedRealitySession.delegate = nil
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


extension CardReaderViewController :  ARSessionDelegate, ARSCNViewDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        //1. Enumerate Our Anchors To See If We Have Found Our Target Anchor
        for anchor in anchors{

            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor {

                //2. If The ImageAnchor Is No Longer Tracked Then Reset The Business Card
                if !imageAnchor.isTracked{
                    businessCardPlaced = false
                    card.setBaseConfiguration()
                }else{

                    //3. Layout The Card Again
                    if !businessCardPlaced{
                        card.animateBusinessCard()
                        businessCardPlaced = true
                    }
                }
            }
        }
     }
    
    //MARK: -  ARSessionDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Check We Have A Valid Image Anchor
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //2. Get The Detected Reference Image
        let referenceImage = imageAnchor.referenceImage
        
        //3. Load Our Business Card
        if let matchedBusinessCardName = referenceImage.name, matchedBusinessCardName == "globalCard" && !businessCardPlaced{
            
            businessCardPlaced = true
            node.addChildNode(card)
            card.animateBusinessCard()
            targetAnchor = imageAnchor
            
        }
    }
}

//MARK: - SCNodes UserInteraction
extension CardReaderViewController : MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate  {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location & Perform An SCNHitTest To Detect Which Nodes We Have Touched
        guard let currentTouchLocation = touches.first?.location(in: self.augmentedRealityView),
            let touchResult = self.augmentedRealityView.hitTest(currentTouchLocation, options: nil).first?.node.name
            else { return }
        
        switch touchResult {
        case "PhoneNumber":
            callPhoneNumber(card.cardData.phoneNumber)
        case "TextMessage":
            sendSMSTo(card.cardData.phoneNumber)
        case "Email":
            sendEmailTo(card.cardData.email)
        case "Website":
            displaySites(url: card.cardData.website.link, type: .Website)
        case "Linkedin":
            displaySites(url: card.cardData.linkedAccount.link, type: .Linkedin)
        case "Map":
            displayLocation(cardBusinessAaddres: card.cardData.address)
        default: ()
        }
    
    }
    
    func callPhoneNumber(_ number: String){
        
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            print("Error Trying To Connect To Mobile Provider")
        }
    }
    
    
    func sendSMSTo(_ number: String){
        if MFMessageComposeViewController.canSendText(){
            let smsController = MFMessageComposeViewController()
            smsController.body = "Enquiry About Your Business"
            smsController.recipients = [number]
            smsController.messageComposeDelegate = self
            present(smsController, animated: true, completion: nil)
        }else{
            print("Error Loading SMS Composer")
        }
        
    }
    
    func sendEmailTo(_ recipient: String){
        
        if MFMailComposeViewController.canSendMail(){
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Enquiry About Your Business")
            mailComposer.setToRecipients([recipient])
            present(mailComposer, animated: true, completion: nil)
        }else{
            print("Error Loading Email Composer")
        }
        
    }
    
    /// Loads One Of The Website From Business Card
    func displaySites(url: String , type : SocialLink) {
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            print("Error Trying To Connect To Open URL")
        }
    }
    
    func displayLocation(cardBusinessAaddres : BusinessAddress) {
        guard let lat = cardBusinessAaddres.coordinates.latittude else {
           return
        }
        guard let long = cardBusinessAaddres.coordinates.longtitude else {
           return
        }
              
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(Double(lat)),\(Double(long))&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        else {
            //Open in browser
            if let urlDestination = URL.init(string: "https://www.google.co.in/maps/dir/?saddr=&daddr=\(Double(lat)),\(Double(long))&directionsmode=driving") {
                  UIApplication.shared.open(urlDestination, options: [:], completionHandler: nil)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
         controller.dismiss(animated: true)
    }
}
