//
//  TaskDetailViewController.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController, UITextViewDelegate {
    
    var task: TableItem?
    var onTaskUpdated: ((TableItem) -> Void)?
    
    private let titleTextField = UITextField()
    private let bodyTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let placeholderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupPlaceholders()
        populateData()
        setupNavigationBar()
        bodyTextView.delegate = self
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        titleTextField.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleTextField.placeholder = "Введите заголовок"
        titleTextField.borderStyle = .none
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        bodyTextView.font = UIFont.systemFont(ofSize: 16)
        bodyTextView.layer.cornerRadius = 8
        bodyTextView.backgroundColor = .systemBackground
        bodyTextView.translatesAutoresizingMaskIntoConstraints = false
        
        placeholderLabel.text = "Введите описание..."
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            titleTextField,
            datePicker,
            bodyTextView
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            titleTextField.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            bodyTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            bodyTextView.heightAnchor.constraint(equalToConstant: 200),
            
            placeholderLabel.topAnchor.constraint(equalTo: bodyTextView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: bodyTextView.leadingAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: bodyTextView.trailingAnchor, constant: -8)
        ])
        
        titleTextField.accessibilityIdentifier = "titleTextField"
        bodyTextView.accessibilityIdentifier = "bodyTextView"
    }
    
    private func setupPlaceholders() {
        updatePlaceholderVisibility()
    }
    
    private func populateData() {
        titleTextField.text = task?.title
        bodyTextView.text = task?.body
        datePicker.date = task?.date ?? Date()
        
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(bodyTextView.text.isEmpty)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updatePlaceholderVisibility()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    @objc private func cancelButtonTapped() {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = bodyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else {
            showTitleRequiredAlert()
            return
        }
        
        task?.title = title
        task?.body = body.isEmpty ? nil : body
        task?.date = datePicker.date
        
        onTaskUpdated?(task!)
        navigationController?.popViewController(animated: true)
    }
    
    private func showTitleRequiredAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Пожалуйста, введите заголовок задачи",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
