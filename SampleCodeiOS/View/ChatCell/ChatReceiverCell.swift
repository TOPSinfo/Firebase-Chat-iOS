//
//  ChatReceiverCell.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit

class ChatReceiverCell: UITableViewCell {

    @IBOutlet weak var lbl_message:UILabel!
    @IBOutlet weak var view_bubble:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        view_bubble.roundCorners([.topRight,.bottomLeft,.bottomRight], radius: 5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
