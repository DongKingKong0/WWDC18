//: # Random Street Generation - WWDC18
import SpriteKit
import PlaygroundSupport
//: Press and hold to move the car.
//:
//: This code is for presenting the streets in the Live View:
let width = 500
let height = 500

/// Value from 0 to 3
let carType = 0
/*:
 Possible car types:
 * 0 - red car
 * 1 - green car
 * 2 - yellow car
 * 3 - blue bus
 */
let spriteView = SKView(frame: CGRect(x: 0, y: 0, width: width, height: height))
spriteView.showsDrawCount = true
spriteView.showsNodeCount = true
spriteView.showsFPS = true

let mainScene = MainScene()
mainScene.setCarType(to: carType)
spriteView.presentScene(mainScene)

let page = PlaygroundPage.current
page.liveView = spriteView
/*:
 All possible textures for the street generation:
 
 ![a tree #0](street/street-0.png)
 
 ![a dead end #1](street/street-1.png)
 
 ![a curve #2](street/street-2.png)
 
 ![a normal street #3](street/street-3.png)
 
 ![I really don't know how this is called... a crossroad with three streets #4](street/street-4.png)
 
 ![a crossroad #5](street/street-5.png)
 */
//: [GitHub](https://github.com/DongKingKong0/WWDC18/)
//:
//: Some code from the [WWDC17 Crowd Simulator](https://github.com/neilsardesai/WWDC-Crowd-Simulator-2017/)
