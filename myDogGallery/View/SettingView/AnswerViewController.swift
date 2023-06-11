//
//  AnswerViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/06/04.
//

import UIKit

class AnswerViewController: BaseViewController {

    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var answerTextView: UITextView!

var targetQuestion: QuestionAnswer?

    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = targetQuestion?.question
        answerTextView.text =  targetQuestion?.answer
    }
}
