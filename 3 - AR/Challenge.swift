//
//  File.swift
//  Reflets
//
//  Created by Louis Carbo Estaque on 09/02/2025.
//

import Foundation

struct Challenge: Identifiable, Hashable {
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
        prompt: "Add something that symbolizes a goal or dream you want to achieve.",
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
        prompt: "Place something that reminds you of a moment you never want to forget.",
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
        prompt: "Add something that represents a food or drink you'd like to try.",
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
    ),
    Challenge(
        title: "Feeling Inspired",
        prompt: "Add a quote or phrase that resonates with your dreams for the future.",
        sfSymbol: "text.quote"
    ),
    Challenge(
        title: "Friendship Forever",
        prompt: "Add an object that represents a friend who's always there for you, or someone you'd like to see more often.",
        sfSymbol: "person.3"
    )
]
