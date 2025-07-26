//
//  ToDoUITests.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//

import XCTest

class ToDoUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
    }
    
    func testAddTask() {
        // Находим кнопку добавления по accessibilityIdentifier
        app.buttons["addButton"].tap()
        
        // Заполняем заголовок
        let titleTextField = app.textFields["titleTextField"]
        titleTextField.tap()
        titleTextField.typeText("New UI Task")
        
        // Заполняем описание
        let bodyTextView = app.textViews["bodyTextView"]
        bodyTextView.tap()
        bodyTextView.typeText("UI Test Description")
        
        // Возвращаемся назад
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Проверяем, что задача появилась в списке
        XCTAssertTrue(app.tables["taskListTableView"].cells.staticTexts["New UI Task"].exists)
    }
    
    func testEditTask() {
        // Сначала добавляем задачу для редактирования
        testAddTask()
        
        // Долгое нажатие на ячейку, чтобы вызвать контекстное меню
        let cell = app.tables["taskListTableView"].cells.element(boundBy: 0)
        cell.press(forDuration: 1.0)
        
        // Нажимаем кнопку "Редактировать"
        app.buttons["edit"].tap()
        
        // Редактируем заголовок
        let titleTextField = app.textFields["titleTextField"]
        titleTextField.tap()
        
        // Очищаем поле и вводим новый текст
        titleTextField.clearText()
        titleTextField.typeText("Updated Task")
        
        // Сохраняем изменения
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Проверяем обновленный текст
        XCTAssertTrue(app.tables["taskListTableView"].staticTexts["Updated Task"].exists)
    }
    
    func testDeleteTask() {
        // Добавляем задачу
        testAddTask()
        
        let tableView = app.tables["taskListTableView"]
        let initialCount = tableView.cells.count
        
        // Долгое нажатие для контекстного меню
        let cell = tableView.cells.element(boundBy: 0)
        cell.press(forDuration: 1.0)
        
        // Нажимаем кнопку удаления
        app.buttons["delete"].tap()
        
        // Проверяем, что количество ячеек уменьшилось на 1
        XCTAssertEqual(tableView.cells.count, initialCount - 1)
    }
    
    func testSearchTask() {
        // Добавляем две разные задачи
        testAddTask() // Добавляет "New UI Task"
        
        // Добавляем вторую задачу
        app.buttons["addButton"].tap()
        let titleTextField = app.textFields["titleTextField"]
        titleTextField.tap()
        titleTextField.typeText("Special Task")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Вводим текст в поиск
        let searchBar = app.searchFields["searchBar"]
        searchBar.tap()
        searchBar.typeText("Special")
        
        // Проверяем, что осталась только одна ячейка с текстом "Special Task"
        let tableView = app.tables["taskListTableView"]
        XCTAssertEqual(tableView.cells.count, 1)
        XCTAssertTrue(tableView.staticTexts["Special Task"].exists)
    }
}

// Расширение для очистки текста
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        typeText(deleteString)
    }
}
