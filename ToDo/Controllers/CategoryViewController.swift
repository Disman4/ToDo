//
//  CategoryViewController.swift
//  ToDo
//
//  Created by Tanaka Mawoyo on 20.06.22.
//

import UIKit
import RealmSwift
import ChameleonFramework

//Inherited from the SwipeTableViewController Super Class
class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        
        tableView.reloadData()
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
            
            self.tableView.reloadData()
        }
        //add textfield in the alert
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "create new category"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //nil coalescing operator
        return categories?.count ?? 1
    }
    
    // populate cell with the data that is added by user
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "no categories added yet"

        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? "1D9BF6")
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    // save category data into the realm database
    func save(category: Category)  {
        do{
            try realm.write(){
                realm.add(category)
            }
        }catch{
            print("error saving category \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    // load data from the database when app is opened
    func loadCategories() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    //use the Realm API .delete to delete obkects from the database
    //overriden from the updateModel function in the superclass
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            }catch{
                print("Error deleting category, \(error)")
            }
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //perform segueway into TodoList of coresponding category
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
}
