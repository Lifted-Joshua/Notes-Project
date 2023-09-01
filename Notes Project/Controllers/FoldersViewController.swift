//
//  ViewController.swift
//  Iphone Notes App(Personal Project)
//
//  Created by lifted joshua on 25/07/2023.
//

import UIKit
import CoreData


class FoldersViewController: UITableViewController {
    

    
    var foldersArray = [Folders]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var FolderName: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//This creates the number of rows for the table
        return foldersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//This creates a cell for each row
        
        print(foldersArray[indexPath.row])
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        
        let bottomBorder = CALayer()
        
        bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: cell.contentView.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor(white: 0.4, alpha: 1.0).cgColor
        cell.contentView.layer.addSublayer(bottomBorder)
        
        cell.textLabel?.textColor = .white
        cell.imageView?.image = UIImage(systemName: "folder")
        cell.imageView?.tintColor = .systemYellow
        cell.textLabel?.text = foldersArray[indexPath.row].name//This appends the name property  of the folder into our table view
        return cell
        
    }
    
    
    //MARK: - TableView Delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        FolderName = foldersArray[indexPath.row].name!
        
        //tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "FolderPressed", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions -> UIMenu? in
            let folder = self.foldersArray[indexPath.row]
            var renameTextField = UITextField()
            let deleteImage = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)//Here we are making our trash image colour red
            
            let deleteAction = UIAction(title: "Delete", image: deleteImage, identifier: nil, discoverabilityTitle: nil) { action in //This creates our UIAction that will be displayed in the context menu
                
                //When this UIAction is clicked, call a method that deletes the selected table cell from its database and from the ui and reload the table view
                self.context.delete(self.foldersArray[indexPath.row])
                self.foldersArray.remove(at: indexPath.row)
                self.saveItems()
                tableView.reloadData()
            }
            
            let renameAction = UIAction(title: "Rename", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil) { action in //This will allow us to be a to rename our folder name in the database and in the ui
                let renameAlert = UIAlertController(title: "Rename Folder", message: "", preferredStyle: .alert)
                let cancelRename = UIAlertAction(title: "Cancel", style: .cancel) { action in
                    renameAlert.dismiss(animated: true)//This dismisses the UIAlertAction when the cancel button is pressed
                }
                let renameAction = UIAlertAction(title: "Rename", style: .default) { action in
                    self.foldersArray[indexPath.row].setValue(renameTextField.text, forKey: "name")
                    self.saveItems()
                    tableView.reloadData()
                }
                
                renameAlert.addTextField { alertTextField in
                    alertTextField.placeholder = "Enter Folder Name"
                    renameTextField = alertTextField
                }
                renameAlert.addAction(renameAction)
                renameAlert.addAction(cancelRename)
                self.present(renameAlert, animated: true, completion: nil)
            }
            
            
            let copyAction = UIAction(title: "Copy", identifier: nil, discoverabilityTitle: nil) { action in
                let folderTitleCopy = self.foldersArray[indexPath.row].name!
                self.copyButtonPressed(copiedText: folderTitleCopy)
                
            }
            return UIMenu(title: folder.name!, image: nil, identifier: nil, options: [], children: [copyAction, renameAction, deleteAction])
        }
    }
    
    
    
    
    
    
    //MARK: - Perform Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FolderPressed" {
            //print("Going to NoteItemsViewController")
            if let destinationVC = segue.destination as? NoteItemViewController {
                destinationVC.UpdateTitle(FolderName: FolderName)
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    //print("This is the indexPath \(indexPath)")
                    destinationVC.selectedCategory = foldersArray[indexPath.row]
                }
            }
        }
        
    }
    
    //MARK: - Create a new Folder
    
    func addNewFolder() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Enter a new Notes folder", message: "", preferredStyle: .alert)//This creates the alert pop up
        
        let action = UIAlertAction(title: "Add Folder", style: .default) { action in//This button adds a new folder(Cell) into the tableView
            let newFolders = Folders(context: self.context)
            newFolders.name = textField.text!
            
            self.foldersArray.append(newFolders)
            self.tableView.reloadData()
            
            self.saveItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            alert.dismiss(animated: true)//This dismisses the UIAlertAction when the cancel button is pressed
        }
        
        
        //Here we are going to add a textField to the alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Enter a new Folder"
            textField = alertTextField
        }
        alert.addAction(action)//Here we are adding our action to our alert
        alert.addAction(cancelAction)

       
        
        present(alert, animated: true, completion: nil)//This displays our alert onto the screen
        
       
    }
    
    //MARK: - Folder Button Pressed
    
    @IBAction func FolderButtonPressed(_ sender: UIBarButtonItem) {
        addNewFolder()
    }
    
    
    
    //MARK: - Copy Button Pressed
    
    func copyButtonPressed(copiedText: String) {
        UIPasteboard.general.string = copiedText//This is how to use the copy functionality in swift
    }
    
    
    
    
    
    
    //MARK: - Core Data functionality
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("There was an error saving your data \(error)")
        }
    }
    
    func loadItems() {
        let request : NSFetchRequest<Folders> = Folders.fetchRequest()
        do {
            foldersArray = try context.fetch(request)
            self.tableView.reloadData()
        } catch {
            print("There was an error fetching your data\(error)")
            
        }
    }
    
}


    
    
    

