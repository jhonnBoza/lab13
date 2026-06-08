//
//  ChatViewModel.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//
//  Lógica del chat con memoria: envía TODO el historial a la IA
//  para que recuerde la conversación dentro de la sesión.
//

import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // ── Configuración de la API (OpenWebUI) ──
    // ⚠️ Esta API solo es accesible dentro de la red cableada del laboratorio.
    // ⚠️ Recuerda agregar el permiso de HTTP (ATS) en Info.plist. Ver CHAT_IA.md
    private let baseURL = "http://192.168.17.11:3000"
    private let apiKey  = "sk-679bc3154f4b4d8db4e9d4be06cbffa1"
    private let model   = "google/gemma-4-26B-A4B-it"

    // Envía el mensaje del usuario y obtiene la respuesta de la IA.
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // 1. Agregamos el mensaje del usuario al historial (esto es la "memoria").
        messages.append(ChatMessage(role: "user", content: text))
        inputText = ""
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(baseURL)/api/chat/completions") else {
            errorMessage = "URL inválida"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 2. Enviamos TODO el historial -> la IA recuerda lo que se conversó antes.
        let payload = ChatRequest(
            model: model,
            messages: messages.map { APIMessage(role: $0.role, content: $0.content) },
            stream: false
        )

        do {
            request.httpBody = try JSONEncoder().encode(payload)
            let (data, response) = try await URLSession.shared.data(for: request)

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                errorMessage = "Error \(http.statusCode): revisa el token o la conexión a la red del lab."
                isLoading = false
                return
            }

            let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
            if let reply = decoded.choices.first?.message.content {
                // 3. Agregamos la respuesta de la IA al historial.
                messages.append(ChatMessage(role: "assistant", content: reply))
            } else {
                errorMessage = "La IA no devolvió contenido."
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // Limpia la conversación (borra la memoria).
    func clearChat() {
        messages.removeAll()
        errorMessage = nil
    }
}
