//
//  NoteItemCell.swift
//  Notes Project
//
//  Created by lifted joshua on 29/07/2023.
//

import UIKit

class NoteItemCell: UITableViewCell {
    
    @IBOutlet weak var notesView: UIView!
    
    @IBOutlet weak var cellTitleLabel: UILabel!
    
    @IBOutlet weak var cellTimeLabel: UILabel!
    
    @IBOutlet weak var textInNoteItemCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
