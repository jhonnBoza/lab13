//
//  ChatMessage.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//
//  Modelo del chat con la IA (OpenWebUI / formato OpenAI).
//

import Foundation

// Mensaje que se muestra en la interfaz del chat.
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: String      // "user" o "assistant"
    let content: String
}

// ── Estructuras para la petición y respuesta de la API ──

// Cada mensaje enviado/recibido por la API.
struct APIMessage: Codable {
    let role: String
    let content: String
}

// Cuerpo (body) que se envía en el POST.
struct ChatRequest: Codable {
    let model: String
    let messages: [APIMessage]
    let stream: Bool
}

// Respuesta que devuelve la API.
struct ChatResponse: Codable {
    struct Choice: Codable {
        let message: APIMessage
    }
    let choices: [Choice]
}
