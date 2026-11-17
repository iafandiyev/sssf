import SwiftUI

struct ContentView: View {
    @StateObject private var gameModel = GameModel()
    @State private var showGameOver = false
    
    var body: some View {
        ZStack {
            GameSceneView(gameModel: gameModel)
                .ignoresSafeArea()
            
            if gameModel.gameState == .menu {
                StartScreenView(bestScore: gameModel.bestScore) {
                    gameModel.startGame()
                }
            }
            
            if gameModel.gameState == .playing {
                HUDView(score: gameModel.currentScore)
            }
            
            if gameModel.gameState == .gameOver {
                GameOverView(
                    finalScore: gameModel.currentScore,
                    bestScore: gameModel.bestScore,
                    isNewBest: gameModel.isNewBest,
                    onRestart: {
                        gameModel.restartGame()
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

enum GameState {
    case menu
    case playing
    case gameOver
}

class GameModel: ObservableObject {
    @Published var gameState: GameState = .menu
    @Published var currentScore: Int = 0
    @Published var bestScore: Int = 0
    @Published var isNewBest: Bool = false
    
    private let bestScoreKey = "miniJumpBestScore"
    
    init() {
        loadBestScore()
    }
    
    func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: bestScoreKey)
    }
    
    func saveBestScore() {
        UserDefaults.standard.set(bestScore, forKey: bestScoreKey)
    }
    
    func startGame() {
        currentScore = 0
        isNewBest = false
        gameState = .playing
    }
    
    func addScore() {
        currentScore += 1
    }
    
    func gameOver() {
        gameState = .gameOver
        isNewBest = false
        if currentScore > bestScore {
            bestScore = currentScore
            isNewBest = true
            saveBestScore()
        }
    }
    
    func restartGame() {
        gameState = .menu
    }
}

struct StartScreenView: View {
    let bestScore: Int
    let onStart: () -> Void
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.14)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("MINI JUMP")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.98, green: 0.95, blue: 0.9))
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                
                Text("BEST: \(bestScore)")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.6))
                
                Spacer().frame(height: 20)
                
                Button(action: onStart) {
                    Text("TAP TO START")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.2, green: 0.6, blue: 0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.15, green: 0.5, blue: 0.8), lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
                
                Spacer().frame(height: 30)
                
                Text("Tap anywhere to jump\nAvoid obstacles")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.4))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 100)
        }
    }
}

struct HUDView: View {
    let score: Int
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(score)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1, green: 1, blue: 1, opacity: 0.9))
                    .shadow(color: .black, radius: 3, x: 0, y: 0)
                    .padding(.top, 20)
                    .padding(.trailing, 20)
            }
            Spacer()
        }
    }
}

struct GameOverView: View {
    let finalScore: Int
    let bestScore: Int
    let isNewBest: Bool
    let onRestart: () -> Void
    
    @State private var animateNewBest = false
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.14)
                .ignoresSafeArea()
                .opacity(0.95)
            
            VStack(spacing: 15) {
                Text("GAME OVER")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.98, green: 0.95, blue: 0.9))
                    .shadow(color: .black, radius: 2, x: 0, y: 2)
                
                Text("SCORE: \(finalScore)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.6))
                
                Text("BEST: \(bestScore)")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(Color(red: 0.7, green: 0.65, blue: 0.6))
                
                if isNewBest {
                    Text("NEW BEST!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1, green: 0.85, blue: 0.2))
                        .shadow(color: Color(red: 0.8, green: 0.5, blue: 0.1), radius: 2, x: 0, y: 2)
                        .opacity(animateNewBest ? 1 : 0)
                        .animation(
                            Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: animateNewBest
                        )
                        .onAppear { animateNewBest = true }
                }
                
                Spacer().frame(height: 40)
                
                Button(action: onRestart) {
                    Text("PLAY AGAIN")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.2, green: 0.6, blue: 0.9))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.15, green: 0.5, blue: 0.8), lineWidth: 2)
                                )
                        )
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 100)
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}