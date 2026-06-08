//
//  User.swift
//  lab13boza
//
//  Created by Juan Leon – Jaime Gómez
//  Utilizando los métodos POST – PUT – DELETE
//

import Foundation

// Codable: permite convertir entre esta estructura y datos JSON automáticamente.
// Identifiable: es un protocolo que permite que SwiftUI sepa cómo identificar cada elemento en una lista.
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}
