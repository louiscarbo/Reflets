//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 09/02/2025.
//

import Foundation

struct Challenge: Identifiable, Hashable {
    let id: String  // Stable identifier for persistence
    let title: String
    let prompt: String
    let sfSymbol: String
}

let challenges: [Challenge] = [
    Challenge(
        id: "happy-place",
        title: "Your Happy Place",
        prompt: "Add an object that represents somewhere you feel completely at home.",
        sfSymbol: "sun.max"
    ),
    Challenge(
        id: "dream-in-making",
        title: "A Dream in the Making",
        prompt: "Add something that stands for a goal you are actively working toward.",
        sfSymbol: "star"
    ),
    Challenge(
        id: "skill-to-master",
        title: "A Skill to Master",
        prompt: "Add an object that represents a skill you are determined to develop.",
        sfSymbol: "paintbrush"
    ),
    Challenge(
        id: "sparks-joy",
        title: "Something That Sparks Joy",
        prompt: "Add an object that instantly makes you smile everytime you encounter it.",
        sfSymbol: "face.smiling"
    ),
    Challenge(
        id: "memory-to-keep",
        title: "A Memory to Keep",
        prompt: "Add something that anchors a moment you never want to lose.",
        sfSymbol: "photo"
    ),
    Challenge(
        id: "next-adventure",
        title: "Your Next Adventure",
        prompt: "Add something that represents a place you'd love to visit.",
        sfSymbol: "airplane"
    ),
    Challenge(
        id: "symbol-of-strength",
        title: "A Symbol of Strength",
        prompt: "Add an object that represents a time you surprised yourself.",
        sfSymbol: "bolt.shield"
    ),
    Challenge(
        id: "favorite-hobby",
        title: "Your Favorite Hobby",
        prompt: "Add something that captures an activity that makes time disappear.",
        sfSymbol: "gamecontroller"
    ),
    Challenge(
        id: "something-unexpected",
        title: "Something Unexpected",
        prompt: "Open your photo library and place the very first thing you see. No cheating allowed!",
        sfSymbol: "sparkles"
    ),
    Challenge(
        id: "lucky-charm",
        title: "Your Lucky Charm",
        prompt: "Add an object that you believe brings you good luck.",
        sfSymbol: "hand.thumbsup"
    ),
    Challenge(
        id: "soundtrack-to-life",
        title: "A Soundtrack to Your Life",
        prompt: "Add an object that calls to mind a song that defined a chapter of your life.",
        sfSymbol: "music.note"
    ),
    Challenge(
        id: "dream-collaboration",
        title: "Your Dream Collaboration",
        prompt: "Add something that represents a person you would love to create or build something with.",
        sfSymbol: "person.2.wave.2"
    ),
    Challenge(
        id: "taste-of-happiness",
        title: "Something That Nourishes You",
        prompt: "Add an object tied to a ritual, food, or experience that genuinely refuels you.",
        sfSymbol: "fork.knife"
    ),
    Challenge(
        id: "superpower",
        title: "Your Best Self",
        prompt: "Add an object that represents what you would be capable of at your very best.",
        sfSymbol: "wand.and.stars"
    ),
    Challenge(
        id: "build-landmark",
        title: "Build a Landmark",
        prompt: "Using only shapes, construct something that represents a place meaningful to you.",
        sfSymbol: "building.columns"
    ),
    Challenge(
        id: "feeling-inspired",
        title: "A Word That Carries Weight",
        prompt: "Add a word or short phrase you come back to when you need direction.",
        sfSymbol: "text.quote"
    ),
    Challenge(
        id: "friendship-forever",
        title: "The People Who Matter",
        prompt: "Add an object that represents someone whose presence makes you better.",
        sfSymbol: "person.3"
    )
]
