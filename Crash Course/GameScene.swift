//
//  GameScene.swift
//  Crash Course
//
//  Created by Kyle Haptonstall on 3/1/16.
//  Copyright (c) 2016 Kyle Haptonstall. All rights reserved.
//


import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    //MARK: - Class Variables
    let planets:[String] = [
        "Earth",
        "Moon",
        "Jupiter",
        "Mars",
        "Mercury",
        "Neptune",
        "Pluto",
        "Uranus"
    ]
    
    let earthGroup:UInt32 = 1
    let meteorGroup:UInt32 = 2
    var earth = SKSpriteNode()
    var scoreLabel = UILabel()
    var score = 0
    
    
    //MARK: - Init
    override func didMoveToView(view: SKView) {

        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        
        // Setup background
        let bgImage = SKSpriteNode(imageNamed: "Background.png")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgImage)
        
       addEarth()
        
        let gravField = SKFieldNode.radialGravityField()
        gravField.position.x = earth.position.x
        gravField.position.y = earth.position.y
        gravField.region = SKRegion(radius: 150)
        gravField.enabled = true
        gravField.strength = 1.0
        gravField.physicsBody?.allowsRotation = true

        self.addChild(gravField)
        
        addPlanets()
     
        setupScoreLabel()
    }
    
    
    //MARK: - Class Methods
    
    /**
     Sets the user score label in the upper left corner of the view
     
     */
    func setupScoreLabel(){
        scoreLabel.frame = CGRectMake(50, 0, 100, 44)
        scoreLabel.textColor = UIColor.whiteColor()
        scoreLabel.text = "Score: \(score)"
        self.view?.addSubview(scoreLabel)
    }
    
    
    /**
     Updates user score based on the planet that was hit. If Earth was hit, game over
     
     - parameter planetName: Name of the planet hit
     */
    func updateScore(planetName:String){
        if planetName != "Earth"{
            score += 100
            scoreLabel.text = "Score: \(score)"
        }
        else{
            self.userInteractionEnabled = false
            let gameOverLabel = UILabel(frame: CGRectMake(0,0, self.size.width, 100))
            gameOverLabel.center = self.view!.center
            gameOverLabel.textColor = UIColor.whiteColor()
            gameOverLabel.textAlignment = .Center
            gameOverLabel.font = gameOverLabel.font.fontWithSize(70)
            gameOverLabel.text = "GAME OVER"
            self.view?.addSubview(gameOverLabel)
        }
    }
    
    
    /**
     Adds Earth the the game scene
     */
    func addEarth(){
        earth = SKSpriteNode(imageNamed: "Earth")
        earth.name = "Earth"
        earth.position = CGPointMake(self.size.width/2 - 100, self.size.height/2)
        earth.xScale = 0.3
        earth.yScale = 0.3
        
        
        earth.physicsBody = SKPhysicsBody(circleOfRadius: earth.frame.width / 2)
        earth.physicsBody?.affectedByGravity = false
        earth.physicsBody?.mass = 0
        earth.physicsBody?.dynamic = false
        earth.physicsBody?.friction = 0.0
        
        earth.physicsBody?.categoryBitMask = earthGroup
        earth.physicsBody?.collisionBitMask = meteorGroup
        earth.physicsBody?.contactTestBitMask = meteorGroup
        earth.physicsBody!.usesPreciseCollisionDetection = true
        
        earth.zPosition = 10
        self.addChild(earth)
    }
    
    /**
     Adds the rest of the planets in the planets array to the game scene
     */
    func addPlanets(){
        for i in 1..<planets.count{
            let planet = SKSpriteNode(imageNamed: planets[i])
            planet.name = planets[i]
            planet.position.x = earth.position.x + (75 * CGFloat(i))
          
            let randomY = randomBetweenNumbers(earth.position.y - 150, secondNum: earth.position.y + 150)
            
            planet.position.y = CGFloat(randomY)
            planet.xScale = 0.2
            planet.yScale = 0.2
            
            planet.physicsBody = SKPhysicsBody(circleOfRadius: planet.frame.width / 2)
            
            planet.physicsBody?.affectedByGravity = false
            planet.physicsBody?.mass = 0
            planet.physicsBody?.dynamic = false
            planet.physicsBody!.usesPreciseCollisionDetection = true
            
            planet.physicsBody?.categoryBitMask = earthGroup
            planet.physicsBody?.collisionBitMask = meteorGroup
            planet.physicsBody?.contactTestBitMask = meteorGroup
            planet.zPosition = 10
            
            self.addChild(planet)
        }
    }
    
    
    /**
     Called when a meteor hits a planet. Animates the planet explosion and removes the meteor from the view.
     
     - parameter contact: SKPhysicsContact
     */
    func didBeginContact(contact: SKPhysicsContact) {
       
        guard let node = contact.bodyB.node as? SKSpriteNode else { return }

        if contact.bodyA.categoryBitMask == meteorGroup{
            contact.bodyA.node!.removeFromParent()
            if contact.bodyB.node!.name != nil{
                let name = contact.bodyB.node!.name!
                node.texture = SKTexture(image: UIImage(named: "Cracked\(name)")!)
                animateExplosion(node)
                updateScore(name)
            }
        }
    }
    
    
    /**
     Animates the explosion of a planet
     
     - parameter node: The planet that was hit
     */
    func animateExplosion(node:SKSpriteNode ){
        let explosion1 = SKTexture(image: UIImage(named: "Cloud1")!)
        let explosion2 = SKTexture(image: UIImage(named: "Cloud2")!)
        
        let animation = SKAction.sequence([
            SKAction.waitForDuration(0.1, withRange: 0.1),
            SKAction.animateWithTextures([explosion1, explosion2], timePerFrame: 0.1)
            ])
        
        let explosion = SKAction.repeatAction(animation, count: 10)
        
        node.runAction(explosion)
        node.runAction(explosion) {
            node.removeFromParent()
        }
    }
  
    
    /**
     Helper function to generate a random number within a range
     
     - parameter firstNum: First number in the range
     - parameter secondNum: Second number in the range
     */
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    /**
     Called whenever user touches screen. Send a meteor out horizontally from the given touch position.
     
     - parameter touches: Set of touches
     - parameter event: UIEvent
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let meteor = SKSpriteNode(imageNamed: "Meteor")
            
            let randomScale = randomBetweenNumbers(0.09, secondNum: 0.15)
            meteor.xScale = randomScale
            meteor.yScale = randomScale
            meteor.position = location
            
            meteor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(meteor.frame.size.width, meteor.frame.size.height))
            
            meteor.physicsBody?.affectedByGravity = true
            meteor.physicsBody?.mass = 20
            meteor.physicsBody?.categoryBitMask = meteorGroup
            meteor.physicsBody?.fieldBitMask = earthGroup
            meteor.physicsBody!.usesPreciseCollisionDetection = true
            meteor.physicsBody!.friction = 0.0
            meteor.physicsBody!.dynamic = true
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:4)
            
            meteor.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(meteor)
            
            meteor.physicsBody?.applyImpulse(CGVector(dx: 300 * meteor.physicsBody!.mass, dy: 0))
            
            
        }
    }
    

}
