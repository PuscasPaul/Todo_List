//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Puscas Paul on 07.06.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm()
    // Results is an auto-updating container type in Realm returned from object queries.
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
    }
    
    
    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if it's nil return 1 else return categories
        return categories?.count ?? 1
    }
    
    // this triggers the code from SwipeTableViewCell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // super calls function from SwipeTableViewController
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added Yet"
        // Change color
        if let category = categories?[indexPath.row] {
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}

            cell.backgroundColor = categoryColour
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
        }

        return cell
    }
    
    
    // MARK: - TableView Delegate Methods
    
    // Tels the delegate that a row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    // Notifies the view controller that a segue is about to be performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController

        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    // MARK: - Data Manipulation Methods
    func save(category: Category) {
        // do catch block because .save()  throws
        do {
//            try theContext.save()
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
    
    
    // MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

}

