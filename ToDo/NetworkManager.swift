//
//  NetworkManager.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//


import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    init(session: URLSession = .shared) {
            self.session = session
        }
        
    private var session: URLSession = .shared
    
    func fetchTodos(completion: @escaping (Result<[TableItem], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TodoResponse.self, from: data)
                
                let tableItems = response.todos.map { todo -> TableItem in
                    TableItem(
                        title: todo.todo,
                        body: nil,
                        isCompleted: todo.completed,
                        serverId: todo.id
                    )
                }
                
                completion(.success(tableItems))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
        case noData
    }
}
