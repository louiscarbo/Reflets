//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

// MARK: - IntroductionView
struct IntroductionView: View {
    @Binding var screenNumber: Int

    // Parallax (idea 4)
    @StateObject private var motion = MotionManager()

    // Dialogue
    @State private var dialogueNumber = 0
    @State private var titleComplete = false

    // Letter assembly + shimmer (idea 2)
    @State private var lettersVisible: [Bool] = Array(repeating: false, count: 7)
    @State private var shimmerOffset: CGFloat = -0.5

    // Haptics
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let notificationFeedback = UINotificationFeedbackGenerator()

    // MARK: Body
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            RefletsTitle(
                lettersVisible: lettersVisible,
                shimmerOffset: shimmerOffset
            )

            if titleComplete {
                VStack(alignment: .leading, spacing: 24) {
                    RevealingText(
                        text: dialogueData[dialogueNumber].dialogueText,
                        triggerID: dialogueNumber
                    )
                    .font(.title2)
                    .fontWidth(.expanded)
                    .foregroundStyle(.primary)
                    
                    HStack {
                        Spacer()
                        Button(dialogueData[dialogueNumber].buttonText) {
                            notificationFeedback.notificationOccurred(.success)
                            advanceDialogue()
                        }
                        .buttonStyle(IntentionButton())
                    }
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 32)
                .transition(.opacity)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ParallaxBackgroundView(roll: motion.roll, pitch: motion.pitch)
                .ignoresSafeArea()
        }
        .onAppear {
            motion.start()
            impactFeedback.prepare()
            notificationFeedback.prepare()
            startLetterAnimation()
            startShimmer()
        }
        .onDisappear {
            motion.stop()
        }
    }

    // MARK: Actions
    private func advanceDialogue() {
        if dialogueNumber < dialogueData.count - 1 {
            dialogueNumber += 1
        } else {
            screenNumber += 1
        }
    }

    private func startLetterAnimation() {
        // Use Task + MainActor for Swift 6 concurrency safety.
        // 1.2s initial pause, then each letter arrives 0.22s after the previous.
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            for i in 0..<7 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.58)) {
                    lettersVisible[i] = true
                }
                impactFeedback.impactOccurred(intensity: 0.45 + Double(i) * 0.08)
                try? await Task.sleep(for: .seconds(0.22))
            }
            // Wait for the last letter to settle, then reveal body text.
            try? await Task.sleep(for: .seconds(0.7))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                titleComplete = true
            }
        }
    }

    private func startShimmer() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.0))
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.5
            }
        }
    }

    // MARK: Dialogue Data
    let dialogueData = [
        DialogueData(
            dialogueText:
                "Reflets is French for \"reflections.\"\n\nThe things you surround yourself with say something about who you are — and who you want to become.\n\nWhat if your vision board actually existed in your space?",
            buttonText: "Show me"
        ),
        DialogueData(
            dialogueText:
                "Build an AR vision board — place objects that represent what you love, what you want, and who you're becoming. Arrange them freely in your real world.\n\nNot sure where to start? Challenges will give you a nudge.",
            buttonText: "Let's build it"
        )
    ]
}

// MARK: - RefletsTitle
private struct RefletsTitle: View {
    let lettersVisible: [Bool]
    let shimmerOffset: CGFloat

    private let letters: [Character] = Array("REFLETS")

    private let startOffsets: [CGSize] = [
        CGSize(width: -220, height:  -90),
        CGSize(width:   55, height: -260),
        CGSize(width:  260, height: -110),
        CGSize(width: -320, height:    0),
        CGSize(width:  210, height:  160),
        CGSize(width:  -90, height:  290),
        CGSize(width:  290, height:   90)
    ]

    private let titleFont = Font.system(size: 62, weight: .bold).width(.expanded)
    @State private var startDate = Date.now

    var body: some View {
        TimelineView(.animation) { timeline in
            letterStack
        }
    }

    private var letterStack: some View {
        HStack(spacing: 1) {
            ForEach(Array(letters.enumerated()), id: \.offset) { i, letter in
                Text(String(letter))
                    .font(titleFont)
                    .offset(lettersVisible[i] ? .zero : startOffsets[i])
                    .opacity(lettersVisible[i] ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.55),
                        value: lettersVisible[i]
                    )
            }
        }
    }
}

// MARK: - ParallaxBackgroundView
/// Three-layer background that shifts with device tilt via CoreMotion.
/// Deeper layers move less; closer layers move more, creating depth.
private struct ParallaxBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    private var isDarkMode: Bool { colorScheme == .dark }
    
    let roll: Double
    let pitch: Double

    /// Points of travel per radian of tilt, one value per depth layer.
    private let depths: [Double] = [70, 100]

    var lightGradient: [Color] {
        [Color(red: 255/255, green: 250/255, blue: 250/255),
         Color(red: 255/255, green: 220/255, blue: 180/255)]
    }
    
    var darkGradient: [Color] {
        [Color(red: 0/255, green: 5/255, blue: 5/255),
         Color(red: 60/255, green: 30/255, blue: 40/255)]
    }

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(
                    RadialGradient(
                        colors: isDarkMode ? darkGradient : lightGradient,
                        center: .center,
                        startRadius: 0, endRadius: 500
                    )
                )

            // Layer 2 — animated SF symbol grid
            AnimatedSymbolsLayer()
                .offset(x: roll * depths[1], y: pitch * depths[1])
        }
    }
}

// MARK: - AnimatedSymbolsLayer
private struct AnimatedSymbolsLayer: View {
    @Environment(\.colorScheme) var colorScheme
    private var isDarkMode: Bool { colorScheme == .dark }
    
    private let allSymbols = [
        "paintbrush.pointed", "paintbrush", "photo", "camera", "trophy",
        "medal", "music.microphone", "theatermask.and.paintbrush",
        "lightbulb.max", "fireworks", "balloon.2", "party.popper",
        "crown", "movieclapper", "eyeglasses", "sunglasses",
        "gamecontroller", "paintpalette", "swatchpalette", "binoculars",
        "globe.europe.africa", "rainbow", "leaf", "camera.macro",
        "bubble.left.and.text.bubble.right", "star", "sparkles",
        "sun.max", "moon", "cloud.sun", "heart", "figure.2.left.holdinghands",
        "figure.badminton", "figure.wave", "figure.gymnastics", "figure.surfing",
        "eyes", "nose", "mouth", "mustache", "brain", "ear", "hourglass",
        "figure.2.and.child.holdinghands"
    ]

    private let count   = 180
    private let columns = 12
    private let size: CGFloat = 70

    // The parent now ONLY needs to care about the initial grid layout
    @State private var symbols: [String] = []

    var body: some View {
        ZStack {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: columns),
                spacing: 5
            ) {
                ForEach(symbols.indices, id: \.self) { i in
                    // Delegate the animation logic to a subview
                    JigglingSymbol(
                        symbolName: symbols[i],
                        size: size
                    )
                }
            }
            .fixedSize()
            .rotationEffect(.degrees(-10))
        }
        .offset(y: -50)
        .opacity(isDarkMode ? 0.15 : 0.08)
        .onAppear {
            guard symbols.isEmpty else { return }
            symbols = (0..<count).compactMap { _ in allSymbols.randomElement() }
        }
    }
}

// MARK: - JigglingSymbol
/// An isolated view that manages its own rotation, scale, and animation loop.
private struct JigglingSymbol: View {
    let symbolName: String
    let size: CGFloat
    
    private let palette: [Color] = [.orange, .pink, .purple, .yellow, .red]

    // Local state: Updating this ONLY redraws this single icon
    @State private var rotation: Double = Double.random(in: -50...50)
    @State private var scale: Double = 1.0
    @State private var color: Color = .orange

    var body: some View {
        Image(systemName: symbolName)
            .foregroundStyle(color)
            .font(.system(size: size))
            .frame(width: size, height: size)
            .padding(20)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .onAppear {
                color = palette.randomElement() ?? .orange
                startJiggling()
            }
    }

    private func startJiggling() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Double.random(in: 0...15.0)))

            // 2. Loop endlessly while the view exists
            while !Task.isCancelled {
                // Pop and rotate
                withAnimation(.spring(response: 0.3, dampingFraction: 0.38)) {
                    rotation = Double.random(in: -180...180)
                    scale = Double.random(in: 1.1...1.3)
                }

                // Wait for the spring to reach its peak
                try? await Task.sleep(for: .seconds(0.35))

                // Settle the scale back down
                withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                    scale = 1.0
                    color = palette.randomElement() ?? .orange
                }

                // Rest for a random interval before the next jiggle
                try? await Task.sleep(for: .seconds(Double.random(in: 5.0...15.0)))
            }
        }
    }
}

// MARK: - RevealingText
/// Reveals text character by character. The full text is rendered invisibly
/// so the layout space is always fully reserved — no height jumps.
private struct RevealingText: View {
    let text: String
    let triggerID: Int

    @State private var revealed = 0
    @State private var currentTask: Task<Void, Never>?

    var body: some View {
        Text(text)
            .opacity(0)
            .overlay(alignment: .topLeading) {
                Text(String(text.prefix(revealed)))
            }
            .onAppear { startRevealing() }
            .onChange(of: triggerID) {
                revealed = 0
                startRevealing()
            }
    }

    private func startRevealing() {
        currentTask?.cancel()
        currentTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            for i in 0...text.count {
                guard !Task.isCancelled else { return }
                revealed = i
                try? await Task.sleep(for: .milliseconds(40))
            }
        }
    }
}

// MARK: - DialogueData
struct DialogueData {
    var dialogueText: String
    var buttonText: String
}

#Preview {
    IntroductionView(screenNumber: .constant(1))
}
