//  Created by Louis Carbo Estaque on 27/11/2023.

import SwiftUI

struct IntroductionView: View {
    @Binding var screenNumber: Int
    
    @State private var dialogueNumber = 0
    
    var body: some View {
        ZStack {
            DialogueView(
                dialogueNumber: $dialogueNumber,
                topView: .constant(contentArray[dialogueNumber].topView),
                dialogueText: .constant(contentArray[dialogueNumber].dialogueText),
                buttonText: .constant(contentArray[dialogueNumber].buttonText)
            )
            Button("Next view") {
                withAnimation {
                    screenNumber += 1
                }
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .font(.title3)
            .bold()
        }
    }
    
    let contentArray: [DialogueData] = [
        DialogueData(
            dialogueText: "Hi! I’m Reflecto, your guide in Reflets, an exciting experiment of self-discovery through arts!",
            buttonText: "Nice to meet you!"
        ),
        DialogueData(
            dialogueText: "Today, I’ll help you embrace your uniqueness and boost your self-confidence through the magical world of self-portraiture!",
            buttonText: "OK"
        ),
        DialogueData(
            dialogueText: "Together, we’re going to team up to create your very own 3D self portrait in Augmented Reality, or AR!",
            buttonText: "Great!"
        ),
        DialogueData(
            dialogueText: "But first, what are even self-portraits?"
        ),
        DialogueData(
            dialogueText: "Self-portraits are a way for you to represent yourself as you see yourself. This includes not only your physical appearance, but also your personality, your thoughts, and your emotions.",
            buttonText: "OK"
        ),
        DialogueData(
            dialogueText: "By creating your own self-portrait, you gain a better understanding of how you treat and see yourself. This is the first step towards improving your self-confidence and self-esteem!",
            buttonText: "OK"
        ),
        DialogueData(
            dialogueText: "Now that you know the magic behind self-portraits, let's draw inspiration from some of the most renowned artists in history. Check out these incredible examples!",
            buttonText: "OK, I’m ready to create my own self portrait!"
        ),
        DialogueData(
            dialogueText: "Now, it's your turn! I'll guide you through a few questions, then we'll take a quick selfie, and finally, the fun part – creating your own 3D self-portrait! Ready?",
            buttonText: "Yes"
        ),
        DialogueData(
            dialogueText: "Remember, this is all about embracing your creativity, no matter your level of artistic skills – so be kind to yourself and let's have some fun!",
            buttonText: "OK, let’s get started!"
        )
    ]
}

struct DialogueData {
    var topView: AnyView?
    var dialogueText = ""
    var buttonText = "Next"
}

#Preview {
    IntroductionView(screenNumber: .constant(1))
}
