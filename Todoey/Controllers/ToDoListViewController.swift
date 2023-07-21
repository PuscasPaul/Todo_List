//
//  ToDoListViewController.swift
//  Todoey
//
//  Created by Puscas Paul on 07.06.2023.
//


import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var toDoItems: Results<Item>?
    let realm = try! Realm()
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    // Convert itemArray into a plist file 👇🏻
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist")}
            
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
                
                searchBar.barTintColor = navBarColour
            }
        }
    }
    
    
    // MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Display the items in a array
        //        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
            
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(toDoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            // Ternary Operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            // Add checkmark ✅ on user interaction
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    // MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do {
                try realm.write {
                    // if false become true and vice versa
                    item.done = !item.done
                    // realm.delete(item)
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
        // Select for a brief moment
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add new Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // Placeholder text from alertTextField to be able to save it and use it elswhere
        // Local variable to be able to use it
        var textField = UITextField()
        
        // Create alert
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Model Manipulation Methods
    
    //     Load data from file
    func loadItems() {
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    // Update the model
    override func updateModel(at indexPath: IndexPath) {
        if let item = self.toDoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
        
    }
}
// MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Query the data
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                // Keyboard will go away
                searchBar.resignFirstResponder()
            }
        }
    }

}


