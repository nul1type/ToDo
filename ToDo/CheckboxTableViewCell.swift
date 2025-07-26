//
//  CheckboxTableViewCell.swift
//  ToDo
//
//  Created by Анатолий Александрович on 24.07.2025.
//

import UIKit

class CheckboxTableViewCell: UITableViewCell {
    
    var checkboxTapped: (() -> Void)?
    
    let checkboxButton: CheckboxButton = {
        let button = CheckboxButton()
        button.outerCircleColor = .systemGray3
        button.innerCircleColor = .systemOrange
        button.checkmarkColor = .white
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 2
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [textStackView, dateLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(checkboxButton)
        contentView.addSubview(mainStackView)
        
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            mainStackView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        bodyLabel.isHidden = true
    }
    
    // MARK: - Configuration
    func configure(with task: TableItem) {
        // Конфигурация контента
        let bodyText = task.body?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        dateLabel.text = formatDate(task.date)
        
        // Обновление состояния чекбокса
        checkboxButton.isSelected = task.isCompleted
        checkboxButton.updateState(animated: false)
        
        // Обновление стилей текста
        updateTextContent(title: task.title,
                          body: bodyText,
                          isCompleted: task.isCompleted)
    }
    
    private func updateTextContent(title: String, body: String, isCompleted: Bool) {
        let titleColor: UIColor = isCompleted ? .systemGray : .label
        let bodyColor: UIColor = isCompleted ? .systemGray : .secondaryLabel
        let dateColor: UIColor = isCompleted ? .systemGray : .tertiaryLabel
        
        let hasBody = !body.isEmpty
        bodyLabel.isHidden = !hasBody
        
        titleLabel.attributedText = attributedText(
            title,
            isCompleted: isCompleted,
            font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            color: titleColor
        )
        
        if hasBody {
            let trimmedBody = body.count > 40 ? String(body.prefix(40)) + "..." : body
            bodyLabel.attributedText = attributedText(
                trimmedBody,
                isCompleted: isCompleted,
                font: UIFont.systemFont(ofSize: 15),
                color: bodyColor
            )
        }
        
        dateLabel.textColor = dateColor
    }
    
    private func attributedText(_ text: String, isCompleted: Bool, font: UIFont, color: UIColor) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        if isCompleted {
            attributedString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: text.count))
        }
        
        return attributedString
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        bodyLabel.attributedText = nil
        dateLabel.text = nil
        bodyLabel.isHidden = true
        checkboxButton.isSelected = false
        checkboxButton.updateState(animated: false)
    }
}
