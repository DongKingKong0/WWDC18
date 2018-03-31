//: Playground - noun: a place where people can play
import SpriteKit
import PlaygroundSupport

let width = 500
let height = 500

let spriteView = SKView(frame: CGRect(x: 0, y: 0, width: width, height: height))
spriteView.showsDrawCount = true
spriteView.showsNodeCount = true
spriteView.showsFPS = true

let mainScene = MainScene()
spriteView.presentScene(mainScene)

let page = PlaygroundPage.current
page.liveView = spriteView
/*:
 All possible textures for the street generation:
 
 ![a tree #0](street/street-0.png)
 
 ![a street that ends somewhere #1](street/street-1.png)
 
 ![a curve #2](street/street-2.png)
 
 ![a normal street #3](street/street-3.png)
 
 ![I really don't know how this is called... a crossroad with three streets #4](street/street-4.png)
 
 ![a crossroad #5](street/street-5.png)
 */
//: [GitHub](https://github.com/DongKingKong0/WWDC18/)
