//
//  CategoryViewController.swift
//  Todoey
//
//  Created by David Smith on 3/2/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

// TODO: 1. See if we can get rid of edge settings in storyboard on navigation bar
//       2. Fix problem with deleting item in TodoList not reseting the colors
//       3. Check on title in navbar getting color reset - appears not to be working

import UIKit
import RealmSwift
import ChameleonSwift

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist!")
        }
        
        // TODO: navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
        if let navBarColor = UIColor(hexString: "#1D9BF6") {
            if let _ = navBar.scrollEdgeAppearance?.backgroundColor {
                navBar.scrollEdgeAppearance!.backgroundColor = navBarColor
            }
        }
    }
    
    // MARK: - TableView data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.hexBackgroundColor) else {fatalError()}
            
            var config = cell.defaultContentConfiguration()
            config.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
            config.textProperties.color = ContrastColorOf(categoryColour, returnFlat: true)
            cell.contentConfiguration = config
            
            cell.backgroundColor = categoryColour
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let desinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            desinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Add New Category
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = alert.textFields?[0].text ?? "New"
            newCategory.hexBackgroundColor = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
        }
        
        present(alert, animated: true)
    }
    
    // MARK: - Model Manipulation Methods
    
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    // MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath)
        
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}
