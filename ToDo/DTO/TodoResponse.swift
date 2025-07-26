//
//  TodoResponse.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//


struct TodoResponse: Codable {
    let todos: [Todo]
}

struct Todo: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
