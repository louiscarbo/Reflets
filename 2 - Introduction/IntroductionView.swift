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
                In this experience, you’ll create a self-portrait that’s all about you.
                """
            , buttonText: "Sounds great!"
        ),
        DialogueData(
            dialogueText:
                """
                This isn’t just any self-portrait—it’s one that reflects your emotions, your experiences, and the things that inspire you.
                Don’t worry, no art skills are needed—just your imagination!
                """
            , buttonText: "I’m ready!"
        ),
        DialogueData(
            dialogueText:
                """
                To start, you’ll choose an intention for your artwork. Think of it as a focus that helps make your self-portrait meaningful and uniquely yours.
                """
            , buttonText: "Let’s do this!"
        ),
        DialogueData(
            dialogueText:
                """
                You can pick from intentions we’ve prepared to guide you, or go freeform if you’re feeling creative.
                Ready to start creating something amazing?
                """
            , buttonText: "Yes, I’m ready!"
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
