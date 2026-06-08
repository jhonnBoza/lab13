//
//  ChatView.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//
//  Pantalla de chat con la IA (burbujas, campo de texto y memoria).
//

import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Conversación
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                messageBubble(message)
                                    .id(message.id)
                            }

                            if viewModel.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("La IA está escribiendo…")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let last = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Mensaje de error (si lo hay)
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                }

                // Barra para escribir
                HStack(spacing: 8) {
                    TextField("Escribe tu mensaje…", text: $viewModel.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit { enviar() }

                    Button(action: enviar) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                    }
                    .disabled(
                        viewModel.inputText.trimmingCharacters(in: .whitespaces).isEmpty
                        || viewModel.isLoading
                    )
                }
                .padding()
            }
            .navigationTitle("Chat IA")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.clearChat()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(viewModel.messages.isEmpty)
                }
            }
        }
    }

    private func enviar() {
        Task { await viewModel.sendMessage() }
    }

    // Burbuja de un mensaje (usuario a la derecha, IA a la izquierda).
    @ViewBuilder
    private func messageBubble(_ message: ChatMessage) -> some View {
        let isUser = message.role == "user"
        HStack {
            if isUser { Spacer() }
            Text(message.content)
                .padding(10)
                .background(isUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(isUser ? .white : .primary)
                .cornerRadius(12)
                .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
            if !isUser { Spacer() }
        }
    }
}

#Preview {
    ChatView()
}
