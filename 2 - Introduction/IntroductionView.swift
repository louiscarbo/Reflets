//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct IntroductionView: View {
    @Binding var screenNumber: Int
    @State var rotationAngle: Double
    
    @State private var dialogueNumber = 0
    @State private var textOpacity = 0.0
    @State private var isAnimating = false
    
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
                    Text(dialogueData[dialogueNumber].buttonText)
                        .italic()
                        .opacity(0.7)
                        .font(.headline)
                }
            }
            .foregroundStyle(.black)
            .padding(20)
            .fontDesign(.serif)
            .opacity(textOpacity)
            HStack {
                Spacer()
                Button("Next"){
                    
                }
                .buttonStyle(IntentionButton())
                Spacer()
            }
        }
        .background {
            Image("Reflets")
                .resizable()
                .frame(width: 700, height: 700)
                .rotationEffect(Angle(degrees: rotationAngle))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                textOpacity = 1.0
            }
        }
        // Tap gesture to change the dialogue text and transitions
        .onTapGesture {
            // Prevents multiple taps
            guard isAnimating == false else { return }
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.6) {
                isAnimating = false
            }
            
            // Animations
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
    }
    
    // MARK: Dialogue Data
    let dialogueData = [
        DialogueData(
            dialogueText:
               """
               Hello there! Welcome to Reflets!
               I’m Reflecto, your guide for this creative experience.
               """
            , buttonText: "Tap anywhere to continue"
        ),
        DialogueData(
            dialogueText:
               """
               Here, you’ll create a unique self-portrait—one that reflects not just your appearance, but your emotions, experiences, and the things that inspire you.
               """
            , buttonText: "So, what’s next?"
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
    IntroductionView(screenNumber: .constant(1), rotationAngle: 0)
}
