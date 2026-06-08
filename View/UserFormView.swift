//
//  UserFormView.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//
//  Vista para agregar o modificar un usuario.
//

import SwiftUI

struct UserFormView: View {
    @Environment(\.presentationMode) var presentationMode

    @State var name: String
    @State var email: String
    var isEditing: Bool
    var onSubmit: (String, String) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Nombre", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
            .navigationTitle(isEditing ? "Editar Usuario" : "Nuevo Usuario")
            .navigationBarItems(
                trailing: Button("Guardar") {
                    onSubmit(name, email)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
