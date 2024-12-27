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
                ]
            )
        }
    }
}
