import SpriteKit
import SwiftUI

class GameScene: SKScene {
    var gameModel: GameModel?
    
    // Game objects
    private var player: SKShapeNode!
    private var ground: SKShapeNode!
    private var obstacles: [SKShapeNode] = []
    private var backgroundShapes: [SKShapeNode] = []
    private var particleEmitter: SKEmitterNode?
    
    // Game state
    private var isGrounded = true
    private var isDead = false
    private var velocityY: CGFloat = 0
    private var difficultyLevel: Float = 1.0
    private var timeSinceLastSpawn: TimeInterval = 0
    private var spawnInterval: TimeInterval = 1.5
    private var obstacleSpeed: CGFloat = 300
    private var lastUpdateTime: TimeInterval = 0
    private var scoredObstacles: Set<SKShapeNode> = []
    
    // Physics constants
    private let gravity: CGFloat = 1200
    private let jumpForce: CGFloat = -450
    private let maxFallSpeed: CGFloat = 800
    private let groundY: CGFloat = 0 // Will be set in didMove
    
    // Screen dimensions
    private var screenWidth: CGFloat = 0
    private var screenHeight: CGFloat = 0
    
    override func didMove(to view: SKView) {
        screenWidth = size.width
        screenHeight = size.height
        
        setupPhysics()
        setupBackground()
        setupGround()
        setupPlayer()
        setupParticles()
        
        // Set ground Y position
        // Ground is at bottom 80 points
        // Player starts at x=100, y=groundY + playerRadius
    }
    
    private func setupPhysics() {
        physicsWorld.gravity = .zero // We handle gravity manually
        physicsWorld.contactDelegate = self
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
        
        // Create floating background shapes
        for _ in 0..<8 {
            let shapeType = Int.random(in: 0...2)
            let shapeNode: SKShapeNode
            let size = CGFloat.random(in: 30...80)
            
            switch shapeType {
            case 0:
                shapeNode = SKShapeNode(circleOfRadius: size)
            case 1:
                shapeNode = SKShapeNode(rectOf: CGSize(width: size, height: size))
            default:
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: -size))
                path.addLine(to: CGPoint(x: size * 0.866, y: size * 0.5))
                path.addLine(to: CGPoint(x: -size * 0.866, y: size * 0.5))
                path.closeSubpath()
                shapeNode = SKShapeNode(path: path)
            }
            
            shapeNode.fillColor = SKColor(
                red: CGFloat.random(in: 0.2...0.5),
                green: CGFloat.random(in: 0.3...0.6),
                blue: CGFloat.random(in: 0.5...0.8),
                alpha: CGFloat.random(in: 0.05...0.15)
            )
            shapeNode.strokeColor = .clear
            shapeNode.zPosition = -5
            
            let x = CGFloat.random(in: 0...screenWidth)
            let y = CGFloat.random(in: 0...screenHeight)
            shapeNode.position = CGPoint(x: x, y: y)
            
            addChild(shapeNode)
            backgroundShapes.append(shapeNode)
            
            // Floating animation
            let floatAction = SKAction.sequence([
                SKAction.moveBy(x: 0, y: CGFloat.random(in: 20...50), duration: CGFloat.random(in: 4...8)),
                SKAction.moveBy(x: 0, y: -CGFloat.random(in: 20...50), duration: CGFloat.random(in: 4...8))
            ])
            shapeNode.run(SKAction.repeatForever(floatAction))
            
            // Rotation
            let rotateAction = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: CGFloat.random(in: 10...20))
            shapeNode.run(SKAction.repeatForever(rotateAction))
        }
    }
    
    private func setupGround() {
        ground = SKShapeNode(rectOf: CGSize(width: screenWidth * 2, height: 80))
        ground.fillColor = SKColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = -1
        ground.position = CGPoint(x: screenWidth, y: 40)
        addChild(ground)
    }
    
    private func setupPlayer() {
        // Create ball with glow
        let ballRadius: CGFloat = 24
        
        // Glow
        let glow = SKShapeNode(circleOfRadius: ballRadius + 4)
        glow.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 0.15)
        glow.strokeColor = .clear
        glow.zPosition = 9
        glow.position = .zero
        
        // Main ball
        player = SKShapeNode(circleOfRadius: ballRadius)
        player.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1.0)
        player.strokeColor = .clear
        player.zPosition = 10
        player.position = CGPoint(x: 100, y: 700) // Will be adjusted
        
        // Physics body for collision
        player.physicsBody = SKPhysicsBody(circleOfRadius: 22)
        player.physicsBody?.isDynamic = false // We control position manually
        player.physicsBody?.categoryBitMask = 0x1
        player.physicsBody?.contactTestBitMask = 0x2
        player.physicsBody?.collisionBitMask = 0
        
        // Add glow as child
        player.addChild(glow)
        
        addChild(player)
    }
    
    private func setupParticles() {
        let emitter = SKEmitterNode()
        emitter.particleTexture = createParticleTexture()
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 15
        emitter.particleLifetime = 0.3
        emitter.particleLifetimeRange = 0.1
        emitter.particlePositionRange = CGVector(dx: 10, dy: 10)
        emitter.particleSpeed = 50
        emitter.particleSpeedRange = 50
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -2.0
        emitter.particleScale = 0.3
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.5
        emitter.particleColor = SKColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor(red: 1.0, green: 0.4, blue: 0.5, alpha: 0.5),
                SKColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 0.0)
            ],
            times: [0, 1]
        )
        emitter.emissionAngle = .pi
        emitter.emissionAngleRange = .pi / 4
        emitter.zPosition = 8
        emitter.targetNode = self
        
        particleEmitter = emitter
        player.addChild(emitter)
        emitter.isHidden = true
    }
    
    private func createParticleTexture() -> SKTexture {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(ovalIn: rect)
            UIColor.white.setFill()
            path.fill()
        }
        return SKTexture(image: image)
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let model = gameModel, model.gameState == .playing else { return }
        guard !isDead else { return }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Apply gravity
        velocityY += gravity * deltaTime
        velocityY = min(velocityY, maxFallSpeed)
        
        // Update player position
        var newY = player.position.y + velocityY * deltaTime
        
        // Ground collision
        if newY <= 700 {
            newY = 700
            velocityY = 0
            if !isGrounded {
                isGrounded = true
                onLand()
            }
        }
        
        player.position.y = newY
        
        // Move obstacles
        for obstacle in obstacles {
            obstacle.position.x -= obstacleSpeed * deltaTime
            
            // Check scoring
            if scoredObstacles.insert(obstacle).inserted && obstacle.position.x < 50 {
                gameModel.addScore()
                difficultyLevel = min(difficultyLevel + 0.05, 3.0)
                obstacleSpeed = 300 * difficultyLevel
                spawnInterval = 1.5 / difficultyLevel
            }
            
            // Remove off-screen obstacles
            if obstacle.position.x < -100 {
                obstacle.removeFromParent()
                scoredObstacles.remove(obstacle)
                obstacles.removeAll { $0 === obstacle }
            }
        }
        
        // Spawn new obstacles
        timeSinceLastSpawn += deltaTime
        if timeSinceLastSpawn >= spawnInterval {
            spawnObstacle()
            timeSinceLastSpawn = 0
            // Add some randomness
            spawnInterval = (1.5 / difficultyLevel) * CGFloat.random(in: 0.8...1.2)
        }
        
        // Parallax background
        for shape in backgroundShapes {
            shape.position.x -= obstacleSpeed * deltaTime * 0.1
            if shape.position.x < -100 {
                shape.position.x = screenWidth + 100
            }
        }
    }
    
    func jump() {
        guard isGrounded, !isDead else { return }
        
        velocityY = jumpForce
        isGrounded = false
        onJump()
        particleEmitter?.isHidden = false
    }
    
    private func onJump() {
        // Squash animation
        let squashY = SKAction.scaleY(to: 0.6, duration: 0.08)
        squashY.timingMode = .easeOut
        let stretchX = SKAction.scaleX(to: 1.4, duration: 0.08)
        stretchX.timingMode = .easeOut
        
        let squashGroup = SKAction.group([squashY, stretchX])
        
        let bounceY = SKAction.scaleY(to: 1.0, duration: 0.15)
        bounceY.timingMode = .easeOut
        let bounceX = SKAction.scaleX(to: 1.0, duration: 0.15)
        bounceX.timingMode = .easeOut
        
        let bounceGroup = SKAction.group([bounceY, bounceX])
        
        player.run(SKAction.sequence([squashGroup, bounceGroup]))
    }
    
    private func onLand() {
        let squashY = SKAction.scaleY(to: 0.85, duration: 0.05)
        squashY.timingMode = .easeOut
        let stretchX = SKAction.scaleX(to: 1.15, duration: 0.05)
        stretchX.timingMode = .easeOut
        
        let squashGroup = SKAction.group([squashY, stretchX])
        
        let bounceY = SKAction.scaleY(to: 1.0, duration: 0.1)
        bounceY.timingMode = .easeOut
        let bounceX = SKAction.scaleX(to: 1.0, duration: 0.1)
        bounceX.timingMode = .easeOut
        
        let bounceGroup = SKAction.group([bounceY, bounceX])
        
        player.run(SKAction.sequence([squashGroup, bounceGroup]))
        particleEmitter?.isHidden = true
    }
    
    func die() {
        isDead = true
        
        // Death animation - fade and shrink
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let shrink = SKAction.scale(to: 0.1, duration: 0.3)
        let deathGroup = SKAction.group([fadeOut, shrink])
        deathGroup.timingMode = .easeIn
        
        player.run(deathGroup)
        particleEmitter?.isHidden = true
        
        // Notify game model
        gameModel?.gameOver()
    }
    
    func resetPlayer() {
        isDead = false
        isGrounded = true
        velocityY = 0
        player.position = CGPoint(x: 100, y: 700)
        player.setScale(1.0)
        player.alpha = 1.0
        particleEmitter?.isHidden = true
    }
    
    private func spawnObstacle() {
        let obstacleType = pickObstacleType()
        
        switch obstacleType {
        case 0:
            spawnTopBottomPair()
        case 1:
            spawnSingleMiddle()
        default:
            spawnDoubleGap()
        }
    }
    
    private func pickObstacleType() -> Int {
        if difficultyLevel < 1.3 {
            return 0
        } else if difficultyLevel < 1.8 {
            return Int.random(in: 0...1)
        } else {
            return Int.random(in: 0...2)
        }
    }
    
    private func spawnTopBottomPair() {
        let gapSize = max(140, min(200, 180 / difficultyLevel))
        let topHeight = CGFloat.random(in: 100...(screenHeight - gapSize - 100))
        let bottomY = topHeight + gapSize
        let bottomHeight = screenHeight - bottomY
        
        // Top obstacle (non-scoring)
        let topObstacle = createObstacle(width: 40, height: topHeight)
        topObstacle.position = CGPoint(x: screenWidth + 50, y: topHeight / 2)
        topObstacle.userData = ["scores": false]
        addChild(topObstacle)
        obstacles.append(topObstacle)
        
        // Bottom obstacle (scoring)
        let bottomObstacle = createObstacle(width: 40, height: bottomHeight)
        bottomObstacle.position = CGPoint(x: screenWidth + 50, y: bottomY + bottomHeight / 2)
        bottomObstacle.userData = ["scores": true]
        addChild(bottomObstacle)
        obstacles.append(bottomObstacle)
    }
    
    private func spawnSingleMiddle() {
        let height = CGFloat.random(in: 150...250)
        let yPos = CGFloat.random(in: (height / 2 + 50)...(screenHeight - height / 2 - 50))
        
        let obstacle = createObstacle(width: 40, height: height)
        obstacle.position = CGPoint(x: screenWidth + 50, y: yPos)
        obstacle.userData = ["scores": true]
        addChild(obstacle)
        obstacles.append(obstacle)
    }
    
    private func spawnDoubleGap() {
        let gapSize = max(110, min(160, 150 / difficultyLevel))
        let topHeight = CGFloat.random(in: 80...((screenHeight - 2 * gapSize) / 2))
        let middleY = topHeight + gapSize
        let middleHeight = CGFloat.random(in: 80...150)
        let bottomY = middleY + middleHeight + gapSize
        let bottomHeight = screenHeight - bottomY
        
        // Top (non-scoring)
        let topObstacle = createObstacle(width: 40, height: topHeight)
        topObstacle.position = CGPoint(x: screenWidth + 50, y: topHeight / 2)
        topObstacle.userData = ["scores": false]
        addChild(topObstacle)
        obstacles.append(topObstacle)
        
        // Middle (scoring)
        let middleObstacle = createObstacle(width: 40, height: middleHeight)
        middleObstacle.position = CGPoint(x: screenWidth + 50, y: middleY + middleHeight / 2)
        middleObstacle.userData = ["scores": true]
        addChild(middleObstacle)
        obstacles.append(middleObstacle)
        
        // Bottom (non-scoring)
        let bottomObstacle = createObstacle(width: 40, height: bottomHeight)
        bottomObstacle.position = CGPoint(x: screenWidth + 50, y: bottomY + bottomHeight / 2)
        bottomObstacle.userData = ["scores": false]
        addChild(bottomObstacle)
        obstacles.append(bottomObstacle)
    }
    
    private func createObstacle(width: CGFloat, height: CGFloat) -> SKShapeNode {
        let rect = CGRect(x: -width/2, y: -height/2, width: width, height: height)
        let node = SKShapeNode(rect: rect)
        node.fillColor = SKColor(red: 0.25, green: 0.65, blue: 0.95, alpha: 1.0)
        node.strokeColor = .clear
        node.zPosition = 5
        
        // Add gradient-like appearance using a shader
        let gradientShader = SKShader(source: """
            void main() {
                float v = v_tex_coord.y;
                vec4 top = vec4(0.25, 0.65, 0.95, 1.0);
                vec4 bottom = vec4(0.15, 0.45, 0.75, 1.0);
                gl_FragColor = mix(bottom, top, v) * u_color;
            }
        """)
        node.shader = gradientShader
        
        // Physics body
        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = 0x2
        node.physicsBody?.contactTestBitMask = 0x1
        node.physicsBody?.collisionBitMask = 0
        
        return node
    }
    
    func clearObstacles() {
        for obstacle in obstacles {
            obstacle.removeFromParent()
        }
        obstacles.removeAll()
        scoredObstacles.removeAll()
    }
    
    func resetDifficulty() {
        difficultyLevel = 1.0
        obstacleSpeed = 300
        spawnInterval = 1.5
        timeSinceLastSpawn = 0
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let model = gameModel, model.gameState == .playing else { return }
        guard !isDead else { return }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Check if player collided with obstacle
        if (bodyA.categoryBitMask == 0x1 && bodyB.categoryBitMask == 0x2) ||
           (bodyA.categoryBitMask == 0x2 && bodyB.categoryBitMask == 0x1) {
            die()
        }
    }
}

struct GameSceneView: UIViewRepresentable {
    @ObservedObject var gameModel: GameModel
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: .zero)
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60
        
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameModel = gameModel
        
        skView.presentScene(scene)
        
        // Store scene reference for tap handling
        context.coordinator.scene = scene
        skView.gestureRecognizers?.forEach { skView.removeGestureRecognizer($0) }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        skView.addGestureRecognizer(tapGesture)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Game state updates are handled by the scene
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        weak var scene: GameScene?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            scene?.jump()
        }
    }
}