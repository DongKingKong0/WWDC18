
import SpriteKit
import GameKit

/// The main view
public class MainScene: SKScene {
    
    /// The default background color, should never appear on the screen
    let defaultBackgroundColor = SKColor(red: 0.0, green: 0.4, blue: 0.15, alpha: 1.0)
    /// These values are just node names and array keys
    let streetNodeName = "street"
    let streetPositionKey = "position"
    let streetTypeKey = "type"
    let streetRotationKey = "rotation"
    let isStreetKey = "isStreet"
    
    /// All textures for the streets
    var streetTextures = [SKTexture]()
    
    override public func didMove(to view: SKView) {
        super.didMove(to: view)
        setup()
    }
    
    /// Call once when executing playground
    func setup() {
        // Set background color
        backgroundColor = defaultBackgroundColor
        
        loadTextures()
        generateNewStreetMap()
        
        /*let node = SKSpriteNode(texture: SKTexture(imageNamed: "car/car-0.png"))
        
        node.name = "car-test"
        node.setScale(0.002)
        node.position = CGPoint(x: 0.5, y: 0.5)
        node.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        
        let rotation = SKAction.rotate(byAngle: 1, duration: 1)
        let repeatRotation = SKAction.repeatForever(rotation)
        node.run(repeatRotation)
        
        addChild(node)*/
    }
    
    /// This function just loads all street textures
    func loadTextures() {
        for i in 0 ... 5 {
            streetTextures.append(SKTexture(imageNamed: "street/street-\(i).png"))
        }
    }
    
    /// This function adds a SPECIFIC street node
    func addStreet(at position: CGPoint, type streetType: Int, rotation rotateAngle: Int) {
        /// Create new node with a texture from the street texture array
        let newStreet = SKSpriteNode(texture: streetTextures[streetType])
        
        /// This is the position for the new street node.
        /// We convert "position", witch is the position in the street matrix, to a value between 0 and 1.
        let newStreetPositionX = position.x / 10 + 0.05
        let newStreetPositionY = position.y / 10 + 0.05
        let newStreetPosition = CGPoint(x: newStreetPositionX, y: newStreetPositionY)
        
        /// The visual rotation of the street node
        let halfPi = CGFloat.pi / 2
        let rotation = SKAction.rotate(byAngle: halfPi * CGFloat(rotateAngle), duration: 0)
        
        // Set the node name to "street"
        newStreet.name = streetNodeName
        // Set the scale to 0.002, witch is the original size of the texture
        newStreet.setScale(0.002)
        // Move the new node to the new position
        newStreet.position = newStreetPosition
        // Set the anchor point to the center of the node
        newStreet.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        // Run the animation to rotate the node
        newStreet.run(rotation)
        
        // Write some Data in the userData of the street node
        newStreet.userData = NSMutableDictionary()
        // Set "isStreet" to 1
        newStreet.userData?.setValue(1, forKeyPath: isStreetKey)
        // Write position, type and rotation in the userData
        newStreet.userData?.setValue(position, forKeyPath: streetPositionKey)
        newStreet.userData?.setValue(streetType, forKeyPath: streetTypeKey)
        newStreet.userData?.setValue(rotateAngle, forKeyPath: streetRotationKey)
        
        addChild(newStreet)
    }
    
    /// This function GENERATES a street node
    func generateStreet (at position: CGPoint) {
        /// We need this for generating the new node
        var type = 0
        var rotation = 0
        /// This array lists the available connections
        var connections = [Bool]()
        /// How many connections do we have?
        var connectionCount = 0
        
        // Check for all 4 directions (bottom, right, top, left) if there's a connection and write them in the "connections" array.
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x, y: position.y - 1), atSide: 2))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x + 1, y: position.y), atSide: 3))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x, y: position.y + 1), atSide: 0))
        connections.append(streetNodeHasConnection(node: CGPoint(x: position.x - 1, y: position.y), atSide: 1))
        
        // Count how many connections we have to decide witch type this node should be
        for i in 0 ... 3 {
            connectionCount += connections[i] ? 1 : 0
        }
        
        switch connectionCount {
        // case 0 would be the same as default, so I removed it
        
        // Dead end
        case 1:
            type = 1
            // Get the index of the first (and only) element in the "connections" array that is true
            if let firstPositiveIndex = connections.index(where: {$0 == true}) {
                // Rotate node in this direction
                rotation = firstPositiveIndex
            }
        // This could be a normal street or a curve
        case 2:
            // Here I just check for every possible combination of connections.
            // I didn't find a better way to do this, but I'm sure there is one.
            if connections[0] {
                if connections[1] {
                    type = 2
                    rotation = 1
                } else if connections[3] {
                    type = 2
                } else {
                    type = 3
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
        // A crossroad with three streets or somethig that looks like that: ┴
        case 3:
            type = 4
            // Get the index of the first (and only) element in the "connections" array that is false (the only side that has no connection)
            if let firstNegativeIndex = connections.index(where: {$0 == false}) {
                // Rotate node in this direction
                rotation = firstNegativeIndex
            }
        // Just a normal crossroad
        case 4:
            type = 5
            // Rotate in random direction
            rotation = Int(arc4random_uniform(4))
        // A lonely tree...
        default:
            type = 0
            rotation = 0
        }
        
        // Add the new street
        addStreet(at: position, type: type, rotation: rotation)
    }
    
    /// Generates a new 10*10 street matrix
    func generateNewStreetMap () {
        for i in 0 ... 9 {
            for j in 0 ... 9 {
                generateStreet(at: CGPoint(x: i, y: j))
            }
        }
    }
    
    /// This function returns a street node that already exists.
    /// If the node doesn't exist, it will return a SKSpriteNode with isStreet = 0 in the userData
    func getStreetNode(at position: CGPoint) -> SKSpriteNode {
        /// The node to return
        var returnNode = SKSpriteNode()
        // Set isStreet to 0
        returnNode.userData = NSMutableDictionary()
        returnNode.userData?.setValue(0, forKeyPath: isStreetKey)
        
        // Do this code for all nodes with name "street"
        enumerateChildNodes(withName: streetNodeName) {
            (node, stop) in
            // Test if the current node is at the right position
            if node.userData?.value(forKey: self.streetPositionKey) as! CGPoint == position {
                // Street node is always a SKSpriteNode
                returnNode = node as! SKSpriteNode
            }
        }
        // Return the node
        return returnNode
    }
    
    /// This function returns an attribute of a street node at a specific position
    func getStreetAttribute(at position: CGPoint, key attributeKey: String) -> Int {
        /// The street node at "position"
        let node = getStreetNode(at: position)
        // Convert isStreet (0 or 1) from Int to Bool
        if node.userData?.value(forKey: isStreetKey) as! Bool {
            // An attribute of a street node is always an Int (isStreet, type, rotation).
            // Position is used to call the function, and asking for the position of an element at a specific position makes no sense.
            return node.userData?.value(forKey: attributeKey) as! Int
        }
        // If the node isn't a street node, witch means it doesn't exist, return a negative value
        return -1
    }
    
    /// Counts how many EXISTNG neighbors a street node has (bottom, right, top, left)
    func getNeighborStreetNodeCount(at position: CGPoint) -> Int {
        /// These are the "isStreet" values (if the node exists) for every neighbor (0 or 1)
        let bottomStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x, y: position.y - 1), key: isStreetKey)
        let rightStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x + 1, y: position.y), key: isStreetKey)
        let topStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x, y: position.y + 1), key: isStreetKey)
        let leftStreetNodeExists = getStreetAttribute(at: CGPoint(x: position.x - 1, y: position.y), key: isStreetKey)
        
        // Count how many neighbor nodes we have
        let neighborNodeCount = bottomStreetNodeExists + rightStreetNodeExists + topStreetNodeExists + leftStreetNodeExists
        
        // return that value
        return neighborNodeCount
    }
    
    /// This function returns true if a street node has a connection on one side
    func streetNodeHasConnection(node position: CGPoint, atSide side: Int) -> Bool {
        /// Use isStreet to check if the node exists
        let nodeExists = getStreetAttribute(at: position, key: isStreetKey)
        /// The type of the street node
        let nodeType = getStreetAttribute(at: position, key: streetTypeKey)
        /// The rotation of the street node
        let nodeRotation = getStreetAttribute(at: position, key: streetRotationKey)
        /// Bool to return
        var returnValue = false
        
        // If the node exists, check for connection
        if nodeExists == 1 {
            switch nodeType {
            // case 0 is the same as default so I removed it
            
            // Dead End
            case 1:
                // Return true if the side we want to know is the same as the rotation (by default bottom)
                if side == nodeRotation {
                    returnValue = true
                }
            // A curve
            case 2:
                // If side is the same as the node rotation or 1 less, return true
                if side == nodeRotation || side == (nodeRotation + 3) % 4 {
                    returnValue = true
                }
            // This is just a normal street
            case 3:
                // If we want to have one of the two sides with connection, return true
                if side == nodeRotation || abs(side - nodeRotation) == 2 {
                    returnValue = true
                }
            // That crossroad with three streets...
            case 4:
                // Return true, but only if we don't want to have the side without connection (by default bottom)
                if side != nodeRotation {
                    returnValue = true
                }
            // A normal crossroad
            case 5:
                // Always return true
                returnValue = true
            // A lonely tree
            default:
                // A lonely tree has no streets anywhere
                returnValue = false
            }
        // If the node doesn't exist return a random value
        } else {
            // 2:3 random value
            if arc4random_uniform(3) > 0 {
                returnValue = true
            }
        }
        // Return the value
        return returnValue
    }
    
    /// This function is called once every frame and does nothing
    override public func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        //nothing to do here
    }
}
