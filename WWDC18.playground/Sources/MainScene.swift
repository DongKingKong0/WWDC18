
import SpriteKit
import GameKit


public class MainScene: SKScene {
    
    let defaultBackgroundColor = SKColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0)
    
    var streetTextures = [SKTexture]()
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        setup()
    }
    
    func setup() {
        backgroundColor = defaultBackgroundColor
        
        loadTextures()
        
        for i in 0 ... 9 {
            for j in 0 ... 9 {
                addStreet(at: CGPoint(x: i, y: j), type: GKRandomSource.sharedRandom().nextInt(upperBound: 6), rotation: 0)
            }
        }
    }
    
    func loadTextures() {
        for i in 0 ... 5 {
            streetTextures.append(SKTexture(imageNamed: "street/street-\(i).png"))
        }
    }
    
    func addStreet(at position: CGPoint, type streetType: Int, rotation rotateAngle: Int) {
        let newStreet = SKSpriteNode(texture: streetTextures[streetType])
        
        let newStreetPositionX = position.x / 10 + 0.05
        let newStreetPositionY = position.y / 10 + 0.05
        let newStreetPosition = CGPoint(x: newStreetPositionX, y: newStreetPositionY)
        
        let halfPi = CGFloat.pi / 2;
        let rotation = SKAction.rotate(byAngle: halfPi * CGFloat(rotateAngle), duration: 0)
        
        newStreet.name = "street"
        newStreet.setScale(0.002)
        newStreet.position = newStreetPosition
        newStreet.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        newStreet.run(rotation)
        
        newStreet.userData = NSMutableDictionary()
        newStreet.userData?.setValue(position, forKeyPath: "position")
        newStreet.userData?.setValue(streetType, forKeyPath: "type")
        newStreet.userData?.setValue(rotateAngle, forKeyPath: "rotation")
        
        print(newStreet.userData?.value(forKey: "position") ?? "Oooops, an error occured.")
        print(newStreet.userData?.value(forKey: "type") ?? "Oooops, an error occured.")
        print(newStreet.userData?.value(forKey: "rotation") ?? "Oooops, an error occured.")
        print()
        
        addChild(newStreet)
    }
}
