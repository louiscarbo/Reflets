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
        prompt: "Add an object that represents a place where you feel the happiest.",
        sfSymbol: "sun.max"
    ),
    Challenge(
        id: "dream-in-making",
        title: "A Dream in the Making",
        prompt: "Add something that symbolizes a goal or dream you want to achieve.",
        sfSymbol: "star"
    ),
    Challenge(
        id: "skill-to-master",
        title: "A Skill to Master",
        prompt: "Add an object that represents a skill you’d love to learn.",
        sfSymbol: "paintbrush"
    ),
    Challenge(
        id: "sparks-joy",
        title: "Something That Sparks Joy",
        prompt: "Place an object that instantly makes you smile.",
        sfSymbol: "face.smiling"
    ),
    Challenge(
        id: "memory-to-keep",
        title: "A Memory to Keep",
        prompt: "Place something that reminds you of a moment you never want to forget.",
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
        prompt: "Choose an object that reminds you of a time you overcame a challenge.",
        sfSymbol: "bolt.shield"
    ),
    Challenge(
        id: "favorite-hobby",
        title: "Your Favorite Hobby",
        prompt: "Add something that represents an activity you love doing.",
        sfSymbol: "gamecontroller"
    ),
    Challenge(
        id: "something-unexpected",
        title: "Something Unexpected",
        prompt: "Add the first object that appears in your photos—no cheating allowed!",
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
        prompt: "Place an object that reminds you of your favorite song.",
        sfSymbol: "music.note"
    ),
    Challenge(
        id: "dream-collaboration",
        title: "Your Dream Collaboration",
        prompt: "Choose an object that represents someone you'd love to work with or learn from.",
        sfSymbol: "person.2.wave.2"
    ),
    Challenge(
        id: "taste-of-happiness",
        title: "A Taste of Happiness",
        prompt: "Add something that represents a food or drink you'd like to try.",
        sfSymbol: "fork.knife"
    ),
    Challenge(
        id: "superpower",
        title: "A Superpower for You",
        prompt: "Choose something that represents a power you wish you had.",
        sfSymbol: "wand.and.stars"
    ),
    Challenge(
        id: "build-landmark",
        title: "Build a Landmark",
        prompt: "Use shapes to create a structure that represents your dream city or place.",
        sfSymbol: "building.columns"
    ),
    Challenge(
        id: "feeling-inspired",
        title: "Feeling Inspired",
        prompt: "Add a quote or phrase that resonates with your dreams for the future.",
        sfSymbol: "text.quote"
    ),
    Challenge(
        id: "friendship-forever",
        title: "Friendship Forever",
        prompt: "Add an object that represents a friend who's always there for you, or someone you'd like to see more often.",
        sfSymbol: "person.3"
    )
]
