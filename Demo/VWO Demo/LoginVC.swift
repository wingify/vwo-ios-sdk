
import Foundation
import UIKit
import VWO

class LoginVC: UIViewController {
    
    override func viewDidLoad() {
        print("view controller are  \(self.navigationController?.viewControllers)")
        
    }
    
    @IBAction func login(_ sender: Any) {

        let config = VWOConfig()
        config.disablePreview = true
        VWO.launch(apiKey: "20d11bb3c68db966715757f8cbeaf8b5-469557", config: VWOConfig(), completion: {
            print("vwo is launched")
            VWO.logLevel = .debug
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
               
                self.navigationController?.removeViewController(LoginVC.self)
            }
        }) { (err) in
            print("error occured while initializing VWO \(err)")
        }
    }
    
    @IBAction func valueForInt(_ sender: Any) {
        let value = VWO.stringFor(key: "heading", defaultValue: "")
        print("value of string is \(value)")
        
    }
    
    @IBAction func trackGoal(_ sender: Any) {
        VWO.trackConversion("upgrade-clicked")
        
    }
}


extension UINavigationController {
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParentViewController()
        }
    }
}
