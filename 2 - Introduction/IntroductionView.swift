//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct IntroductionView: View {
    @Binding var screenNumber: Int
    
    @State private var rotationAngle: Double = 0
    @State private var dialogueNumber = 0
    @State private var textOpacity = 0.0
    let hapticFeedback = UINotificationFeedbackGenerator()
    
    //MARK: View
    var body: some View {
        VStack(alignment: .leading) {
            // Text VStack, used to apply opacity to the text only
            VStack(alignment: .leading) {
                Text(dialogueData[dialogueNumber].dialogueText)
                    .font(.title)
                    .fontWidth(.expanded)
                    .padding(.bottom, 30)
                
                HStack {
                    Spacer()
                    Spacer()
                    Button(dialogueData[dialogueNumber].buttonText) {
                        hapticFeedback.notificationOccurred(.success)
                        withAnimation(.easeInOut(duration: 1)) {
                            textOpacity = 0.0
                        }
                        withAnimation(.easeInOut(duration: 0.1).delay(1)) {
                            if dialogueNumber < dialogueData.count - 1 {
                                dialogueNumber+=1
                            } else {
                                screenNumber+=1
                            }
                        }
                        withAnimation(.easeInOut(duration: 1).delay(1.1)) {
                            textOpacity = 1.0
                        }
                    }
                    .buttonStyle(IntentionButton())
                }
            }
            .foregroundStyle(.black)
            .padding(20)
            .opacity(textOpacity)
        }
        .background {
            Image("Reflets")
                .resizable()
                .frame(width: 800, height: 800)
                .rotationEffect(Angle(degrees: rotationAngle))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                textOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 120.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
    
    // MARK: Dialogue Data
    let dialogueData = [
        DialogueData(
            dialogueText:
                """
                Welcome to Reflets!

                In this experience, you’ll build an AR vision board—a space to bring your dreams, ideas, and inspirations to life.
                """
            , buttonText: "Sounds interesting!"
        ),
        DialogueData(
            dialogueText:
                """
                Here’s how it works: You’ll pick objects that represent things you love, things you want, or things that inspire you, and arrange them in AR freely.

                Don’t worry, we’ve prepared some fun challenges to help you get started!
                """
            , buttonText: "Let's get started!"
        )
    ]
}

struct DialogueData {
    var dialogueText: String
    var buttonText: String
}

#Preview {
    IntroductionView(screenNumber: .constant(1))
}
