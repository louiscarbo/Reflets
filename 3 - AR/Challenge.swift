//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 09/02/2025.
//

import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let prompt: String
    let sfSymbol: String
}

let challenges: [Challenge] = [
    Challenge(
        title: "Your Happy Place",
        prompt: "Add an object that represents a place where you feel the happiest.",
        sfSymbol: "sun.max"
    ),
    Challenge(
        title: "A Dream in the Making",
        prompt: "Choose something that symbolizes a goal or dream you want to achieve.",
        sfSymbol: "star"
    ),
    Challenge(
        title: "A Skill to Master",
        prompt: "Add an object that represents a skill you’d love to learn.",
        sfSymbol: "paintbrush"
    ),
    Challenge(
        title: "Something That Sparks Joy",
        prompt: "Place an object that instantly makes you smile.",
        sfSymbol: "face.smiling"
    ),
    Challenge(
        title: "A Memory to Keep",
        prompt: "Pick something that reminds you of a moment you never want to forget.",
        sfSymbol: "photo"
    ),
    Challenge(
        title: "Your Next Adventure",
        prompt: "Add something that represents a place you'd love to visit.",
        sfSymbol: "airplane"
    ),
    Challenge(
        title: "A Symbol of Strength",
        prompt: "Choose an object that reminds you of a time you overcame a challenge.",
        sfSymbol: "bolt.shield"
    ),
    Challenge(
        title: "Your Favorite Hobby",
        prompt: "Add something that represents an activity you love doing.",
        sfSymbol: "gamecontroller"
    ),
    Challenge(
        title: "An Object With a Story",
        prompt: "Pick an object and imagine the story behind it.",
        sfSymbol: "book"
    ),
    Challenge(
        title: "Something Unexpected",
        prompt: "Add the first object that appears in your photos—no cheating allowed!",
        sfSymbol: "sparkles"
    ),
    Challenge(
        title: "Your Lucky Charm",
        prompt: "Add an object that you believe brings you good luck.",
        sfSymbol: "hand.thumbsup"
    ),
    Challenge(
        title: "A Soundtrack to Your Life",
        prompt: "Place an object that reminds you of your favorite song.",
        sfSymbol: "music.note"
    ),
    Challenge(
        title: "Your Dream Collaboration",
        prompt: "Choose an object that represents someone you'd love to work with or learn from.",
        sfSymbol: "person.2.wave.2"
    ),
    Challenge(
        title: "A Taste of Happiness",
        prompt: "Add something that represents your favorite food or drink.",
        sfSymbol: "fork.knife"
    ),
    Challenge(
        title: "A Superpower for You",
        prompt: "Choose something that represents a power you wish you had.",
        sfSymbol: "wand.and.stars"
    ),
    Challenge(
        title: "Build a Landmark",
        prompt: "Use shapes to create a structure that represents your dream city or place.",
        sfSymbol: "building.columns"
    )
]
