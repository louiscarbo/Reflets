//  Created by Louis Carbo Estaque on 02/12/2023.

import SwiftUI

struct DialogueView: View {
    @Binding var dialogueNumber: Int
    
    @Binding var topView: AnyView?
    @Binding var dialogueText: String
    @Binding var buttonText: String
    
    // Needed for the writing animation effect
    @State private var displayedText: String = ""

    var body: some View {        
        ZStack {
            Rectangle()
                .foregroundStyle(Color(red: 1, green: 248/255, blue: 240/255))
                .ignoresSafeArea()
                .foregroundColor(.yellow)
            VStack {
                Spacer()
                topView
                    .padding()
                Spacer()
                HStack {
                    RoundedRectangle(cornerRadius: 30)
                        .padding()
                        .frame(height: 210)
                        .foregroundStyle(
                            Color(red: 1, green: 207/255, blue: 153/255)
                        )
                        .overlay(alignment: .top) {
                            Text(displayedText)
                                .clipped()
                                .padding(35)
                                .font(.title)
                                .multilineTextAlignment(.leading)
                            
                                // Allows the writing animation effect
                                .onAppear {
                                    updateDisplayedText()
                                }
                                .onChange(of: dialogueText) { newText in
                                    updateDisplayedText(newText: newText)
                                }
                        }
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 100)
                        .padding(.trailing)
                }
                
                Button {
                    withAnimation {
                        dialogueNumber += 1
                    }
                } label: {
                    Text(buttonText)
                        .frame(maxWidth: .infinity)
                }
                .font(.title3)
                .bold()
                .buttonBorderShape(.roundedRectangle(radius: 20))
                .buttonStyle(.borderedProminent)
                .padding([.bottom, .horizontal])
            }
        }
    }
    
    func updateDisplayedText(newText: String = "") {
        displayedText = ""
        if !newText.isEmpty {
            newText.enumerated().forEach {
                index, character in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    displayedText += String(character)
                }
            }
        } else {
            dialogueText.enumerated().forEach {
                index, character in
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                    displayedText += String(character)
                }
            }
        }
    }
}
