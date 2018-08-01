


import Foundation
import UIKit
//global
 // original server data as UTF8 string}
struct Constants {
    static  let globalWidth:CGFloat = UIScreen.main.bounds.size.width;
    static  let globalHeight:CGFloat = UIScreen.main.bounds.size.height;
    static  let scale = globalWidth/375.0;
    static  let topBarColor = UIColor(red: CGFloat(100 / 255.0), green: CGFloat(100 / 255.0), blue: CGFloat(0 / 255.0), alpha: 1.0);
   	static  let globalURL = "https://app.alarm.fo/";
    static  let dropUsers = ["Time Base","Performance","Investment","Others"];
    static  let dropBoolean = ["NO","YES"]
    
    static func grayColor(number: Double) -> UIColor{
        
        let returnedColor:UIColor = UIColor(red: CGFloat(number / 255.0), green: CGFloat(number / 255.0), blue: CGFloat(number / 255.0), alpha: 1.0);
        
        return returnedColor;
    }
    
    
    static func RGBColor(_  R:Double, _ G:Double, _ B:Double, _ alpha:CGFloat = 1.0) -> UIColor{
        
        let returnedColor:UIColor = UIColor(red: CGFloat(R / 255.0), green: CGFloat(G / 255.0), blue: CGFloat(B / 255.0), alpha: alpha);
        
        return returnedColor;
    }
    
    static func colorFromHex(_ rgbValue:UInt32, alpha : CGFloat = 1)->UIColor
        
    {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0xFF) / 255.0
        return UIColor(red:red, green:green, blue:blue, alpha: alpha)
    }


}
//Global variables
struct GlobalVariables {
    static let blue = UIColor.rbg(r: 129, g: 144, b: 255)
    static let purple = UIColor.rbg(r: 161, g: 114, b: 255)
}

//Extensions
extension UIColor{
    class func rbg(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        let color = UIColor.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
        return color
    }
}




extension UIViewController {
    
    func showPopupErrorMessage(_ chekErrorMessage:String){
    
        let alert = UIAlertController(title: "Alert", message: chekErrorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    
    }
    
    func letsControlFileds(_ localArray:[AnyObject])->String{
        
        var errorMessage = ""
        
        
        for i in 0..<localArray.count{
            
            
            
            if((localArray[i] as! UITextField).text == ""){
                
                return (localArray[i] as! UITextField).placeholder!
            }
            
        }
        
        
        return errorMessage
        
    }
}

extension UIView
{
    
    
    func setFrame(newX: CGFloat = 0, newY:CGFloat = 0, newWidth:CGFloat = 0, newHeight: CGFloat = 0)
    {
        
        if(newX != 0){
            
            self.frame = CGRect(x:newX,y:self.frame.origin.y, width:self.frame.size.width, height:self.frame.size.height)
            
        }
        
        if(newY != 0){
            
            self.frame = CGRect(x:self.frame.origin.x,y:newY, width:self.frame.size.width, height:self.frame.size.height)
            
        }
        
        if(newWidth != 0){
            
            self.frame = CGRect(x:self.frame.origin.x,y:self.frame.origin.y, width:newWidth, height:self.frame.size.height)
            
        }
        
        if(newHeight != 0){
            
            self.frame = CGRect(x:self.frame.origin.x,y:self.frame.origin.y, width:self.frame.size.width, height:newHeight)
            
        }
        
        
    }
}


class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.height / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}

//Enums
enum ViewControllerType {
    case welcome
    case conversations
}

enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
 }

enum MessageType {
    case photo
    case text
    case location
}

enum MessageOwner {
    case sender
    case receiver
}

enum TaskStatus {
    case done
    case undone
}

