//
//  NotesViewController.swift
//  Notes Project
//
//  Created by lifted joshua on 29/07/2023.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData

protocol NotesViewControllerDelegate: AnyObject {
    func didUpdateData(notesModel: NotesModel)
    func updatedNotes(index: Int, title: String, subText: String, date: String)
}


class NotesViewController: UIViewController, UITextViewDelegate {
    

    
    var NoteItemSelectedCategory : NoteItems? {
        didSet {
            //Here we are going to call LoadItems
            loadItems()
        }
    }
    
    
    var NoteItemIndex: Int? {
        didSet {
            print(NoteItemIndex!)
        }
    }
    

    var notesArray = [Notes]()
    weak var delegate: NotesViewControllerDelegate?
    var notesVcIndexPath : Int = 0
   
    
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var titleLabel: UITextView! //This is for the title of the notes
    @IBOutlet weak var titleLabelHC: NSLayoutConstraint!
    @IBOutlet weak var textViewText: UITextView!//This is for the text/ notes inside the notes
    
    @IBOutlet weak var scrollView: UIScrollView!
    var currentDate: String = ""
    //var count = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        
//        DispatchQueue.main.async {
//            self.titleLabel.text = self.notesArray[self.count].title
//            self.textViewText.text = self.notesArray[self.count].subText
//        }
        
        titleLabel.delegate = self
        scrollView.keyboardDismissMode = .interactive
        
    
        
        titleLabelHC.isActive = false
        
        textViewText.isScrollEnabled = false
        titleLabel.isScrollEnabled = false
       
        
        titleLabel.text = ""
        titleLabel.sizeToFit()
        textViewText.text = ""
        textViewText.sizeToFit()
        
        

    
        
        view.backgroundColor = UIColor.black
        titleLabel.backgroundColor = UIColor.black
        titleLabel.textColor = UIColor.white
        textViewText.backgroundColor = UIColor.black
        textViewText.textColor = UIColor.white
        
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        titleLabel.becomeFirstResponder()
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
   
    
    @IBAction func DoneButtonPressed(_ sender: UIBarButtonItem) {
        var titleLabelText = titleLabel.text
        var noteText = textViewText.text
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.calendar = Calendar(identifier: .gregorian)
        let date = Date()
        currentDate = formatter.string(from: date)
        
        
        //Checking to see whether the title or sub text is empty
        if titleLabel.text == "" && textViewText.text == "" {
            //If title and Text is empty
            print("Title and text is empty")
        }
        
        else if titleLabel.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty && textViewText.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            //If title and text is white space and new Lines
            titleLabelText = "New Notes"
            noteText = "No additional Text"
            
            
            let notesModel = NotesModel(title: titleLabelText!, date: currentDate, subText: noteText!)
            delegate?.didUpdateData(notesModel: notesModel)
            
            
            //Saving title&text into coreData/
            let defaultNotes = Notes(context: context)
            defaultNotes.title = titleLabelText
            defaultNotes.subText = noteText
            defaultNotes.time = currentDate
            defaultNotes.parentNoteItems = NoteItemSelectedCategory
            
            saveItems()
            
            if NoteItemIndex == nil {
                print("NoteItemIndex is nil")
            } else {
                updateNoteAtIndex(newTitle: titleLabelText! , newSubText: noteText!, newDate: currentDate)
            }
            
        }
        
        else {
            
//            print(titleLabelText!)
//            print(noteText!)
            
            //Saving title&text into coreData
            let newNotes = Notes(context: context)
            newNotes.title = titleLabelText
            newNotes.subText = noteText
            newNotes.time = currentDate
            newNotes.parentNoteItems = NoteItemSelectedCategory
            
            
            let notesModel = NotesModel(title: titleLabelText!, date: currentDate, subText: noteText!)
            delegate?.didUpdateData(notesModel: notesModel)
            
            
            
            saveItems()
            
            if NoteItemIndex == nil {
                print("NoteItemIndex is nil")
            } else {
                updateNoteAtIndex(newTitle: titleLabelText! , newSubText: noteText!, newDate: currentDate)
            }
            
            

        }
    }
    
    
    
    func saveItems() {
        do {
            try context.save()
            //print("NotesViewController data successfully saved")
        } catch {
            print("There was an error saving your data \(error)")
        }
    }
    
    func loadItems() {
        let title = (NoteItemSelectedCategory?.title! ?? "No title").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let request: NSFetchRequest<Notes> = Notes.fetchRequest()
        
        let predicate = NSPredicate(format: "parentNoteItems.title == %@", title)
        request.predicate = predicate
        

        do {
            
            notesArray = try context.fetch(request)//we have to speak to the context before we can access the persistent contiainer
            //print("Notes data was successfully retrieved")
            
            
            //print("\nNumber of notes in notesArray: \(notesArray.count)")
            
            populateTextViews()
        } catch {
            print("Error fetching your data from context \(error)")
        }

   }
    
    // Assuming you have an NSManagedObject subclass named "Note" and an attribute named "title"

    func updateNoteAtIndex(newTitle: String, newSubText: String, newDate: String) {
        
        notesArray[NoteItemIndex!].title = newTitle
        notesArray[NoteItemIndex!].subText = newSubText
        notesArray[NoteItemIndex!].time = newDate
        
//        print(newTitle)
//        print(newSubText)
//        print(newDate)
        
        //delegate?.updatedNotes(index: 5, title: "NewTitle", subText: "newSubText", date: "newDate")
        
        saveItems()
        
        
        
        
            
    }

    
    func populateTextViews() {
        if !notesArray.isEmpty {
            //print(NoteItemIndex!)
            let firstNote = notesArray[NoteItemIndex!] // You can choose a specific note here

//            print(firstNote.title!)
//            print(firstNote.subText!)

            DispatchQueue.main.async {
                self.titleLabel.text = firstNote.title
                self.textViewText.text = firstNote.subText
            }
        }
    }
    

    

 
    
    
    
    
}

