//
//  TaskListViewController.swift
//  ToDo
//
//  Created by Анатолий Александрович on 23.07.2025.
//

import UIKit

class TaskListViewController: UIViewController, UINavigationBarDelegate {

    // MARK: - Task lists
    private var items: [TableItem] = []
    private var filteredTasks: [TableItem] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("title", comment: "")
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar()
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem()
        
        navItem.title = formatTaskCount(0)
        
        navItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        navigationBar.items = [navItem]
        return navigationBar
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("search_label", comment: "")
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(CheckboxTableViewCell.self, forCellReuseIdentifier: "CheckboxCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupTableView()
        loadData()
        updateNavigationTitle()
        
        navigationBar.topItem?.rightBarButtonItem?.accessibilityIdentifier = "addButton"
        tableView.accessibilityIdentifier = "taskListTableView"
        searchBar.searchTextField.accessibilityIdentifier = "searchBar"
    }
    
    private func loadData() {
        NetworkManager.shared.fetchTodos { [weak self] result in
            switch result {
            case .success(let networkTasks):
                CoreDataManager.shared.syncWithNetwork(tasks: networkTasks) {
                    CoreDataManager.shared.fetchTasks { tasks in
                        self?.updateData(with: tasks)
                    }
                }
            case .failure(let error):
                CoreDataManager.shared.fetchTasks { tasks in
                    self?.updateData(with: tasks)
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    private func updateData(with newTasks: [TableItem]) {
        let oldTasks = self.items
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let diff = newTasks.difference(from: oldTasks)
            var deleted = [IndexPath]()
            var inserted = [IndexPath]()
            
            for change in diff {
                switch change {
                case .remove(let offset, _, _): deleted.append(IndexPath(row: offset, section: 0))
                case .insert(let offset, _, _): inserted.append(IndexPath(row: offset, section: 0))
                }
            }
            
            DispatchQueue.main.async {
                self?.applyChanges(newTasks: newTasks, deleted: deleted, inserted: inserted)
            }
        }
    }

    private func applyChanges(newTasks: [TableItem], deleted: [IndexPath], inserted: [IndexPath]) {
        self.items = newTasks
        updateFilteredTasks()
        updateNavigationTitle()
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: deleted, with: .automatic)
            tableView.insertRows(at: inserted, with: .automatic)
            
            if let visiblePaths = tableView.indexPathsForVisibleRows {
                for path in visiblePaths {
                    if !deleted.contains(path) && !inserted.contains(path) {
                        if let cell = tableView.cellForRow(at: path) as? CheckboxTableViewCell {
                            cell.configure(with: filteredTasks[path.row])
                        }
                    }
                }
            }
        }, completion: nil)
    }
    
    private func updateFilteredTasks() {
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredTasks = items.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        } else {
            filteredTasks = items
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("error", comment: ""),
            message: NSLocalizedString("error_text", comment: "") + " \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func formatTaskCount(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if count == 0 {
            return NSLocalizedString("no_tasks", comment: "")
        } else if remainder10 == 1 && remainder100 != 11 {
            return "\(count) " + NSLocalizedString("task_single_title", comment: "")
        } else if (2...4).contains(remainder10) && !(12...14).contains(remainder100) {
            return "\(count) " + NSLocalizedString("task_plural_title", comment: "")
        } else {
            return "\(count) " + NSLocalizedString("tssks_title_2", comment: "")
        }
    }
    
    private func updateNavigationTitle() {
        navigationBar.topItem?.title = formatTaskCount(items.count)
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(navigationBar)
        searchBar.delegate = self
        navigationBar.delegate = self
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: navigationBar.topAnchor),
            
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Create New Task
    @objc private func addButtonTapped() {
        let detailVC = TaskDetailViewController()
        detailVC.task = TableItem()
        
        detailVC.onTaskUpdated = { [weak self] updatedTask in
            CoreDataManager.shared.addTask(updatedTask) { [weak self] in
                CoreDataManager.shared.fetchTasks { tasks in
                    self?.updateData(with: tasks)
                }
            }
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Context Menu
    private func makeContextMenu(at indexPath: IndexPath) -> UIMenu {
        let edit = UIAction(
            title: NSLocalizedString("edit", comment: ""),
            image: UIImage(systemName: "pencil")
        ) { [weak self] _ in
            self?.editTask(at: indexPath)
        }
        
        edit.accessibilityIdentifier = "edit"
        
        let share = UIAction(
            title: NSLocalizedString("share", comment: ""),
            image: UIImage(systemName: "square.and.arrow.up")
        ) { [weak self] _ in
            self?.shareTask(at: indexPath)
        }
        
        let delete = UIAction(
            title: NSLocalizedString("delete", comment: ""),
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { [weak self] _ in
            self?.deleteTask(at: indexPath)
        }
        
        delete.accessibilityIdentifier = "delete"
        
        return UIMenu(title: "", children: [edit, share, delete])
    }
    
    private func editTask(at indexPath: IndexPath) {
        let task = filteredTasks[indexPath.row]
        
        let detailVC = TaskDetailViewController()
        detailVC.task = task
        
        detailVC.onTaskUpdated = { [weak self] updatedTask in
            CoreDataManager.shared.updateTask(updatedTask) {
                CoreDataManager.shared.fetchTasks { tasks in
                    self?.updateData(with: tasks)
                }
            }
        }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    private func shareTask(at indexPath: IndexPath) {
        let task = filteredTasks[indexPath.row]
        
        let shareText = """
        Задача: \(task.title)
        Статус: \(task.isCompleted ? "Выполнена" : "Не выполнена")
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let cell = tableView.cellForRow(at: indexPath) {
            activityVC.popoverPresentationController?.sourceView = cell
            activityVC.popoverPresentationController?.sourceRect = cell.bounds
        }
        
        present(activityVC, animated: true)
    }
    
    private func deleteTask(at indexPath: IndexPath) {
        let taskToDelete = filteredTasks[indexPath.row]
        
        if let indexInItems = items.firstIndex(where: { $0.id == taskToDelete.id }) {
            items.remove(at: indexInItems)
        }
        filteredTasks.remove(at: indexPath.row)
        
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .fade)
        }, completion: nil)
        
        CoreDataManager.shared.deleteTask(taskToDelete)
        updateNavigationTitle()
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CheckboxCell", for: indexPath) as! CheckboxTableViewCell
        let item = filteredTasks[indexPath.row]
        cell.configure(with: item)
        cell.checkboxButton.isUserInteractionEnabled = false
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var updatedTask = filteredTasks[indexPath.row]
        updatedTask.isCompleted.toggle()
        updatedTask.lastUpdated = Date()
        
        if let cell = tableView.cellForRow(at: indexPath) as? CheckboxTableViewCell {
            cell.configure(with: updatedTask)
        }
        
        filteredTasks[indexPath.row] = updatedTask
        if let index = items.firstIndex(where: { $0.id == updatedTask.id }) {
            items[index] = updatedTask
        }
        
        CoreDataManager.shared.updateTask(updatedTask)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { [weak self] _ in
            self?.makeContextMenu(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateFilteredTasks()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
