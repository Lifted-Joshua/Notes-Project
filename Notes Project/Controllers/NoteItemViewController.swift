//
//  NoteItemTableViewController.swift
//  Notes Project
//
//  Created by lifted joshua on 26/07/2023.
//

import UIKit
import CoreData




class NoteItemViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, NotesViewControllerDelegate  {
    
    
    
    var notesItemsArray = [NoteItems]()
    
    var notesITEMS = [Notes]()
    
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Folders? {
        didSet {
            loadItems()
        }
    }
    
    var noteItemArray = [NotesModel]()
    var noteItemCount = 0
    var noteItemTitle: String = ""
    var noteItemDate: String = ""
    var noteItemSubText: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        
        tableView.register(UINib(nibName: "NoteItemCell", bundle: nil), forCellReuseIdentifier: "Reusable Cell")//Here we are registering our NoteItemCell
        
        navigationController?.navigationBar.tintColor = UIColor.yellow
        UITabBar.appearance().barTintColor = UIColor.black
   
        tabBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func UpdateTitle(FolderName: String) {
        DispatchQueue.main.async {
            self.navigationItem.title = FolderName
        }
    }
    
    
    
    
    
    

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Reusable Cell", for: indexPath) as! NoteItemCell
        //cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        
        let notesModel = notesItemsArray[indexPath.row]
        
        
        cell.cellTitleLabel.text = notesModel.title
        cell.textInNoteItemCell.text = notesModel.subText
        cell.cellTimeLabel.text = notesModel.time
        
        
        return cell
        

    }
    
    

    //MARK: - TableView Delegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
                    UIView.animate(withDuration: 0.2, animations: {
                        cell!.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
                    }, completion: { finished in
                        UIView.animate(withDuration: 0.2) {
                            cell!.transform = .identity
                        }
                    })
       //print(notesItemsArray[indexPath.row].title!)
       performSegue(withIdentifier: "NoteItemPressed", sender: self)
       //print(indexPath.row)
        
    }
    
    

    //MARK: - Code for Tab Bar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        if item.title == "New Notes" {
            performSegue(withIdentifier: "NewNotesPressed", sender: self)
        } else if item.title == "Folders" {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    //MARK: - Code overriding Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewNotesPressed" {
            if let notesVC = segue.destination as? NotesViewController {
                notesVC.delegate = self
            }
        }
        else if segue.identifier == "NoteItemPressed" {
            let newDestinationVC = segue.destination as! NotesViewController
//            if let indexPath = tableView.indexPathForSelectedRow {
//                newDestinationVC.titleLabel.text = notesItemsArray[indexPath.row].title
//                newDestinationVC.textViewText.text = notesItemsArray[indexPath.row].subText
//            } else {
//                print("indexPath not found")
//            }
            if let indexPath = tableView.indexPathForSelectedRow {
                //print("This is the indexPath \(indexPath)")
                newDestinationVC.NoteItemIndex = indexPath.row
                newDestinationVC.NoteItemSelectedCategory = notesItemsArray[indexPath.row]
                
            }
            
        }
    }
    
    
    
    //MARK: - Delegate Method
    
    func didUpdateData(notesModel: NotesModel) {
        
        //print("The index is \(index)")
        
//        print("The title is \(notesModel.title)")
//        print("The subText is \(notesModel.subText)")
        
        let noteItems = NoteItems(context: context)
        noteItems.title = notesModel.title
        noteItems.subText = notesModel.subText
        noteItems.time = notesModel.date
        noteItems.parentFolder = selectedCategory
        
        
        
        saveItems()
        loadItems()
        
        DispatchQueue.main.async {
            self.tableView.reloadData() // Reload the table view on the main thread
        }
        
    }
    
    func updatedNotes(index: Int, title: String, subText: String, date: String) {
        print(index)
        print(title)
        print(subText)
        print(date)
    }
    
    
    
    //MARK: - CoreData saving items
    
    func saveItems() {
        do {
            try context.save()
            //print("NoteItem Data saved Successfully")
        } catch {
            print("There was an error saving your data \(error)")
        }
    }
    
    
    //MARK: - CoreData Loading items
    
    func loadItems() {
        let request: NSFetchRequest<NoteItems> = NoteItems.fetchRequest()


        if let categoryName = selectedCategory?.name {
            //print("getting names for noteItems")
            let predicate = NSPredicate(format: "parentFolder.name MATCHES %@", categoryName)
            request.predicate = predicate
        } else {
            print("error loading noteItems")

        }


        do {
            let fetchedItems = try context.fetch(request)
            notesItemsArray = fetchedItems// Reverse the array

            print("The number of items in NoteItemArray is \(notesItemsArray.count)")


        } catch {
            print("Error fetching your data from context \(error)")
        }

    }
    
    
    
    
}
