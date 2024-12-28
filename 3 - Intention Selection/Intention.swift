//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 27/12/2024.
//

import Foundation

struct Intention: Equatable, Hashable {
    var title: String
    var comment: String
    var prompts: [String]
    var challenges: [Challenge]
}

struct Challenge: Equatable, Hashable {
    var title: String
    var content: String
}

enum Intentions: CaseIterable {
    case proud, me, future, memory, home, other

    var details: Intention {
        switch self {
        case .proud:
            return Intention(
                title: "What I’m proud of",
                comment: "Pride is powerful! Exploring what makes you proud can be a great confidence boost. I’ll be here to guide you!",
                prompts: [
                    "Imagine a trophy or symbol of your success—can you add it to your surroundings?",
                    "Try adding something tall or elevated—something that symbolizes standing tall with pride.",
                    "What’s something you’ve done recently that felt meaningful? How can you represent it here?"
                ],
                challenges: [
                    Challenge(
                        title: "Trophy Challenge",
                        content: "Add an object or symbol that represents your biggest achievement. Where would you place it to show its importance?"
                    ),
                    Challenge(
                        title: "Pride in Progress",
                        content: "Represent something you’re proud of that’s still a work in progress. How can you show its potential?"
                    )
                ]
            )
        case .me:
            return Intention(
                title: "What makes me, me",
                comment: "You’re one of a kind! Let’s explore what makes you, you—I’ll help with prompts to spark your reflection.",
                prompts: [
                    "What’s a habit, passion, or object that feels central to who you are? Can you add it?",
                    "If your personality were a shape or texture, what would it be?",
                    "Imagine your favorite color or pattern filling the space around you. Can you reflect that here?",
                    "Try layering objects to show different sides of yourself—what combinations feel right?"
                ],
                challenges: [
                    Challenge(
                        title: "Three Traits",
                        content: "Represent three parts of your personality using different objects or colors. Arrange them to show how they interact."
                    ),
                    Challenge(
                        title: "Daily Life, Daily You",
                        content: "Add three objects that represent your daily routines or habits. Arrange them to reflect their importance.")
                ]
            )
        case .future:
            return Intention(
                title: "Me, 10 years from now",
                comment: "Dreaming about the future is exciting! Don’t worry, I’ll be here to guide your reflection.",
                prompts: [
                    "What’s one thing you hope for your future self? How can you show it here?",
                    "Imagine a path leading into your surroundings. What would it look like if it represented your journey?",
                    "Try placing an object in the far distance—what’s waiting for you there in 10 years?"
                ],
                challenges: [
                    Challenge(
                        title: "Path Challenge",
                        content: "Create a path that represents your journey to the future. What obstacles or opportunities would you include?"
                    ),
                    Challenge(
                        title: "Dream Big",
                        content: "Add an object that symbolizes your future self’s biggest dream. Make it the centerpiece of your artwork!"
                    )
                ]
            )
        case .memory:
            return Intention(
                title: "A memory I cherish",
                comment: "Your favorite moments tell a story. Let’s reflect on one—I’ll help you capture it in your artwork!",
                prompts: [
                    "What’s a memory that makes you smile?",
                    "Who or what was part of that moment?",
                    "Why is it so meaningful to you?"
                ],
                challenges: [
                    Challenge(
                        title: "Hidden Details",
                        content: "Add a small detail that only you would recognize from your memory. How does it change the scene?"
                    ),
                    Challenge(
                        title: "Visual Soundtrack",
                        content: "Imagine a sound or song that represents your memory. How can you show it visually?"
                        )
                ]
            )
        case .home:
            return Intention(
                title: "Where I feel at home",
                comment: "Home is where the heart is—or maybe something else entirely! Let me guide you as you reflect.",
                prompts: [
                    "What’s the most vivid detail from this memory? How can you bring it into your artwork?",
                    "What emotion does this memory hold? Can you show it with a color or texture?",
                    "Blend an object from your memory into your environment—how does it interact with the present?"
                ],
                challenges: [
                    Challenge(
                        title: "Comfort Zone",
                        content: "Create a visual “bubble” that represents your feeling of home. What’s inside, and what stays outside?"
                    )
                ]
            )
        case .other:
            return Intention(
                title: "I have another idea",
                comment: "Going your own way? Awesome! I’ll be here if you need inspiration, but the stage is yours!",
                prompts: [
                    "What’s the first thing that comes to mind for your self-portrait? Start with that!",
                    "Let your environment guide you: what objects, shapes, or textures around you fit your vision?",
                    "Start with one element and build outward. What feels natural to add next?"
                ],
                challenges: [
                    Challenge(
                        title: "Emotion Explorer",
                        content: "Pick an emotion you’ve felt today and represent it visually. What color, shape, or object fits best?"
                    )
                ]
            )
        }
    }
}
