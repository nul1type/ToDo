//
//  ToDOXCTest.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//

import XCTest
@testable import ToDo
import CoreData

class ToDOXCTest: XCTestCase {
    
    var coreDataManager: CoreDataManager!
    var networkManager: NetworkManager!
    var mockURLSession: URLSession!
    
    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer.inMemoryContainer(name: "ToDo")
        coreDataManager = CoreDataManager(container: container)

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockURLSession = URLSession(configuration: config)
        networkManager = NetworkManager(session: mockURLSession)
    }
    
    func testFetchTodosSuccess() {
        let mockData = """
        {
            "todos":[{"id":1,"todo":"Do something nice for someone you care about","completed":false,"userId":152}]
        }
        """.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, mockData)
        }
        
        let expectation = self.expectation(description: "Fetch success")
        
        networkManager.fetchTodos { result in
            switch result {
            case .success(let tasks):
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.title, "Do something nice for someone you care about")
            case .failure:
                XCTFail("Expected success")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testAddTask() {
        // Тест с использованием coreDataManager
        let task = TableItem(title: "Test Task")
        let expectation = self.expectation(description: "Add task")
        
        coreDataManager.addTask(task) {
            self.coreDataManager.fetchTasks { tasks in
                XCTAssertEqual(tasks.count, 1)
                XCTAssertEqual(tasks.first?.title, "Test Task")
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

extension NSPersistentContainer {
    static func inMemoryContainer(name: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        if let error = loadError {
            fatalError("Failed to load in-memory store: \(error)")
        }
        
        return container
    }
}

// Mock URLProtocol для тестирования сетевых запросов
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Request handler not set")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
