//
//  MainTabView.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//
//  Contenedor principal con dos pestañas: Usuarios (API REST) y Chat IA.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Usuarios", systemImage: "person.3.fill")
                }

            ChatView()
                .tabItem {
                    Label("Chat IA", systemImage: "bubble.left.and.bubble.right.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
