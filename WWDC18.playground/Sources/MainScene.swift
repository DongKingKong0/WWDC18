
import SpriteKit
import GameKit


public class MainScene: SKScene {
    
    let defaultBackgroundColor = SKColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0)
    let streetNodeName = "street"
    let streetPositionKey = "position"
    let streetTypeKey = "type"
    let streetRotationKey = "rotation"
    let isStreetKey = "isStreet"
    
    var streetTextures = [SKTexture]()
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        setup()
    }
    
    func setup() {
        backgroundColor = defaultBackgroundColor
        
        loadTextures()
        generateNewStreetMap()
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
        
        let halfPi = CGFloat.pi / 2
        let rotation = SKAction.rotate(byAngle: halfPi * CGFloat(rotateAngle), duration: 0)
        
        newStreet.name = streetNodeName
        newStreet.setScale(0.002)
        newStreet.position = newStreetPosition
        newStreet.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        newStreet.run(rotation)
        
        newStreet.userData = NSMutableDictionary()
        newStreet.userData?.setValue(1, forKeyPath: isStreetKey)
        newStreet.userData?.setValue(position, forKeyPath: streetPositionKey)
        newStreet.userData?.setValue(streetType, forKeyPath: streetTypeKey)
        newStreet.userData?.setValue(rotateAngle, forKeyPath: streetRotationKey)
        
        print(newStreet.userData?.value(forKey: streetPositionKey) ?? "Oooops, an error occured.")
        print(newStreet.userData?.value(forKey: streetTypeKey) ?? "Oooops, an error occured.")
        print(newStreet.userData?.value(forKey: streetRotationKey) ?? "Oooops, an error occured.")
        print()
        
        addChild(newStreet)
    }
    
    func generateStreet (at position: CGPoint) {
        var type = 0
        var rotation = 0
        var connections = [Bool]()
        var connectionCount = 0
        
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x, y: position.y - 1), atSide: 2))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x + 1, y: position.y), atSide: 3))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x, y: position.y + 1), atSide: 0))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x - 1, y: position.y), atSide: 1))
        print(connections)
        
        for i in 0 ... 3 {
            connectionCount += connections[i] ? 1 : 0
        }
        print(connectionCount)
        
        switch connectionCount {
        case 0:
            type = 0
            rotation = 0
        case 1:
            type = 1
            if let firstPositiveIndex = connections.index(where: {$0 == true}) {
                rotation = firstPositiveIndex
            }
        case 2:
            if connections[0] {
                if connections[1] {
                    type = 2
                    rotation = 1
                } else if connections[3] {
                    type = 2
                    rotation = 0
                } else {
                    type = 3
                    rotation = 0
                }
            } else if connections[1] {
                if connections[2] {
                    type = 2
                    rotation = 2
                } else {
                    type = 3
                    rotation = 1
                }
            } else {
                type = 2
                rotation = 3
            }
        case 3:
            type = 4
            if let firstNegativeIndex = connections.index(where: {$0 == false}) {
                rotation = firstNegativeIndex
            }
        case 4:
            type = 5
            rotation = 1
        default:
            type = 0
            rotation = 0
        }
        
        addStreet(at: position, type: type, rotation: rotation)
    }
    
    func generateNewStreetMap () {
        for i in 0 ... 9 {
            for j in 0 ... 9 {
                generateStreet(at: CGPoint(x: i, y: j))
            }
        }
    }
    
    func getStreetNode(at position: CGPoint) -> SKSpriteNode {
        var returnNode = SKSpriteNode()
        returnNode.userData = NSMutableDictionary()
        returnNode.userData?.setValue(0, forKeyPath: isStreetKey)
        
        enumerateChildNodes(withName: streetNodeName) {
            (node, stop) in
            if node.userData?.value(forKey: self.streetPositionKey) as! CGPoint == position {
                returnNode = node as! SKSpriteNode
            }
        }
        return returnNode
    }
    
    func getStreetAttribute(at position: CGPoint, key attributeKey: String) -> Int {
        let node = getStreetNode(at: position)
        if node.userData?.value(forKey: isStreetKey) as! Bool {
            return node.userData?.value(forKey: attributeKey) as! Int
        }
        return -1
    }
    
    func getNeighborStreetNodeCount(at position: CGPoint) -> Int {
        let bottomStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x, y: position.y - 1), key: isStreetKey)
        let rightStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x + 1, y: position.y), key: isStreetKey)
        let topStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x, y: position.y + 1), key: isStreetKey)
        let leftStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x - 1, y: position.y), key: isStreetKey)
        let neighborNodeCount = bottomStreetNodeExists + rightStreetNodeExists + topStreetNodeExists + leftStreetNodeExists
        
        return neighborNodeCount
    }
    
    func streetNodeHasConnection(node position: CGPoint, atSide side: Int) -> Bool {
        let nodeExists = getStreetAttribute(at: position, key: isStreetKey)
        let nodeType = getStreetAttribute(at: position, key: streetTypeKey)
        let nodeRotation = getStreetAttribute(at: position, key: streetRotationKey)
        var returnValue = false
        
        if nodeExists == 1 {
            switch nodeType {
            case 0:
                returnValue = false
            case 1:
                if side == nodeRotation {
                    returnValue = true
                }
            case 2:
                if side == nodeRotation {
                    returnValue = true
                } else if nodeRotation < 2 {
                    if abs(side - nodeRotation) == 3 {
                        returnValue = true
                    }
                } else {
                    if abs(side - nodeRotation) == 1 {
                        returnValue = true
                    }
                }
            case 3:
                if side == nodeRotation || abs(side - nodeRotation) == 2 {
                    returnValue = true
                }
            case 4:
                if side != nodeRotation {
                    returnValue = true
                }
            case 5:
                returnValue = true
            default:
                returnValue = false
            }
        } else {
            if arc4random_uniform(3) > 0 {
                returnValue = true
            }
        }
        return returnValue
    }
    
    override public func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        //nothing to do here
    }
}
