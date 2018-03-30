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
