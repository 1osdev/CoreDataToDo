//
//  CategoryViewController.swift
//  CoreDataToDo
//
//  Created by Дмитрий Смирнов on 9.03.22.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categories = [Category]()
    
    // чтение и запись данных в Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        setupNavigationBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func addCategoryBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new category", message: "Please enter category name", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Category"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
                let text = textField.text, text != "",
                let self = self {
                let newCategory = Category(context: self.context)
                newCategory.name = text
                self.categories.append(newCategory)
                //self.tableView.reloadData()
                self.saveCategories()
                self.tableView.insertRows(at: [IndexPath(row: self.categories.count - 1, section: 0)], with: .automatic)
            }
        }

        alert.addAction(cancel)
        alert.addAction(addAction)

        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let name = categories[indexPath.row].name {
                let request: NSFetchRequest<Category> = Category.fetchRequest()
                request.predicate = NSPredicate(format: "name==\(name)")
                
                if let categories = try? context.fetch(request) {
                    for category in categories {
                        context.delete(category)
                    }
                    
                    self.categories.remove(at: indexPath.row)
                    saveCategories()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toDoListVC = segue.destination as? ToDoListViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            toDoListVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    // MARK: - Core Data
    
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error save context")
        }
    }
    
    private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 50/255,
            green: 230/255,
            blue: 150/255,
            alpha: 255/255
        )

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
}
