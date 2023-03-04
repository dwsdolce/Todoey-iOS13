//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonSwift

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {

        if let hexColor = selectedCategory?.hexBackgroundColor {
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation controller does not exist!")
            }
            if let navBarColor = UIColor(hexString: hexColor) {
                let contrastColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.tintColor = contrastColor
                
                navBar.scrollEdgeAppearance?.backgroundColor = navBarColor
                
                navBar.scrollEdgeAppearance?.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : contrastColor]
                
                searchBar.barTintColor = navBarColor
                searchBar.searchTextField.backgroundColor = .white
            }
        }
    }
    
    // MARK: - TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var config = cell.defaultContentConfiguration()
        if let item = todoItems?[indexPath.row] {
            config.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let darkenPercentage = CGFloat(indexPath.row)/CGFloat(todoItems!.count)
            let hexColor = selectedCategory!.hexBackgroundColor
            if let color = UIColor(hexString: hexColor)?.darken(byPercentage: darkenPercentage) {
                cell.backgroundColor = color
                config.textProperties.color = ContrastColorOf(color, returnFlat: true)
            }
        } else {
            config.text = "No Items Added"
        }
        cell.contentConfiguration = config
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            self.tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Item
    
    @IBAction func addButtonPress(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = alert.textFields?[0].text ?? "New"
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Model Manupulation Methods
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let item = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
            DispatchQueue.main.async {
                self.loadItems()
            }
        }
    }
}

// MARK: - UISearchBarDelegate Extension

extension TodoListViewController: UISearchBarDelegate {
    // This is to do the search when the button is clicked as opposed to
    // what we have in the textDidChange where the search happens immediately.
    
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //
    //        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    ////        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
    //
    //        tableView.reloadData()
    //    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            // This is required to get the keyboard to disappear when the
            // cancel button in the search bar is pressed.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            tableView.reloadData()
        }
    }
}
