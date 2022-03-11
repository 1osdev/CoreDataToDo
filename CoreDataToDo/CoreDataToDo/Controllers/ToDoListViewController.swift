//
//  ToDoListViewController.swift
//  CoreDataToDo
//
//  Created by Дмитрий Смирнов on 9.03.22.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    // чтение и запись данных в Core Data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory: Category? {
        didSet {
            self.title = selectedCategory?.name
            loadItems()
        }
    }
    
    var itemsArray = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Your task"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
                let text = textField.text, text != "",
                let self = self {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemsArray.append(newItem)
                self.saveItems()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
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
        return itemsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemsArray[indexPath.row].title
        cell.accessoryType = itemsArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newItem = Item(context: self.context)
        newItem.done = true
        //tableView.reloadCell()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {

            if let title = itemsArray[indexPath.row].title {
                let request: NSFetchRequest<Item> = Item.fetchRequest()
                request.predicate = NSPredicate(format: "title==\(title)")

                if let itemsArray = try? context.fetch(request) {
                    for item in itemsArray {
                        context.delete(item)
                    }

                    self.itemsArray.remove(at: indexPath.row)
                    saveItems()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // MARK: - Core Data
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error save context")
        }
    }
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(),
                           predicate: NSPredicate? = nil) {
        guard let name = selectedCategory?.name else { return }
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
        
        if let predicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error fetch context")
        }
        tableView.reloadData()
    }
}

    extension ToDoListViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                loadItems()
                searchBar.resignFirstResponder()
            } else {
                let request: NSFetchRequest<Item> = Item.fetchRequest()
                let searchPredicate = NSPredicate(format: "title CONTAINS %@", searchText)
                request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                loadItems(with: request, predicate: searchPredicate)
            }
        }
    }
