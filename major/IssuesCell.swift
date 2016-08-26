//
//  IssuesCell.swift
//  major
//
//  Created by Rishu Goel on 24/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit

class IssuesCell: UITableViewCell {
    
    @IBOutlet weak var ClosedIssuesLabel: UILabel!
    @IBOutlet weak var OpenIssuesLabel: UILabel!
    
    @IBOutlet weak var issuesView: UIView!
    
    @IBOutlet weak var closedIssueImage: UIImageView!
    @IBOutlet weak var openIssueImage: UIImageView!
}
