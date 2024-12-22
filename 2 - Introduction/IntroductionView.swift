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
                    .font(.system(.title))
                    .padding(.bottom, 30)
                
                HStack {
                    Spacer()
                    Spacer()
                    Button(dialogueData[dialogueNumber].buttonText) {
                        hapticFeedback.notificationOccurred(.success)
                        withAnimation(.easeInOut(duration: 1.5)) {
                            textOpacity = 0.0
                        }
                        withAnimation(.easeInOut(duration: 0.1).delay(1.5)) {
                            if dialogueNumber < dialogueData.count - 1 {
                                dialogueNumber+=1
                            } else {
                                screenNumber+=1
                            }
                        }
                        withAnimation(.easeInOut(duration: 2.0).delay(1.6)) {
                            textOpacity = 1.0
                        }
                    }
                    .buttonStyle(IntentionButton())
                }
            }
            .foregroundStyle(.black)
            .padding(20)
            .fontDesign(.serif)
            .opacity(textOpacity)
        }
        .background {
            Image("Reflets")
                .resizable()
                .frame(width: 700, height: 700)
                .rotationEffect(Angle(degrees: rotationAngle))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 120.0)
                            .repeatForever(autoreverses: false)
                    ) { rotationAngle = 360 }
                }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                textOpacity = 1.0
            }
        }
    }
    
    // MARK: Dialogue Data
    let dialogueData = [
        DialogueData(
            dialogueText:
               """
               Hello there! Welcome to Reflets!
               I’m Reflecto, your guide for this creative experience.
               """
            , buttonText: "Hello Reflecto!"
        ),
        DialogueData(
            dialogueText:
               """
               Here, you’ll create a unique self-portrait—one that reflects not just your appearance, but your emotions, experiences, and the things that inspire you.
               """
            , buttonText: "Sounds exciting!"
        ),
        DialogueData(
            dialogueText:
                """
                We’ll start by picking an intention—something to focus on as you create. Don’t worry, it’s super easy, and there’s no wrong way to do it!
                """
                , buttonText: "Let’s get started!"
        ),
        DialogueData(
            dialogueText:
                """
                Think of it as the focus for your self-portrait—what you want it to reflect about you.
                
                I’ve prepared a few intentions to help guide you. Or, if you’re feeling creative, you can pick your own path and go freeform!
                """
                , buttonText: "I’m ready!"
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
