//
//  NewMemoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

extension Notification.Name {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}

class NewMemoViewController: UIViewController {
    
    var editTarget: MemoEntity?
    
    @IBOutlet var inputDatePicker: UIDatePicker!
    @IBOutlet var memoTitleTextField: UITextField!
    @IBOutlet var memoContextTextView: UITextView!
    @IBOutlet var walkCountLabel: UILabel!
    @IBOutlet var walkTimeLabel: UILabel!
    @IBOutlet var pooLabel: UILabel!
    
    @IBAction func walkCountStepper(_ sender: UIStepper) {
        let target = sender.value
        walkCountLabel.text = "\(Int(target))"
    }
    
    @IBAction func walkTimeStepper(_ sender: UIStepper) {
        let target = sender.value
        walkTimeLabel.text = "\(Int(target))"
    }
    
    @IBAction func pooStepper(_ sender: UIStepper) {
        let target = sender.value
        pooLabel.text = "\(Int(target))"
    }
    
    
    var dateFormatter: DateFormatter = {
        let inputDate = DateFormatter()
        inputDate.dateFormat = "MMM d, yyyy"
        inputDate.locale = Locale(identifier: "en_US_POSIX")
        
        return inputDate
    }()
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        let memoTitle = memoTitleTextField.text
        
        if memoTitle?.count ?? 0 >= 15 {
            let alert = UIAlertController(title: "제목 글자수가 많습니다 15자", message: "제목 글자수 수정 필요", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated:  true, completion:  nil)
            return
        }
        
        let memoContext = memoContextTextView.text
        
        if memoContext?.count == 0 {
            let alert = UIAlertController(title: "오늘의 기록을 입력해주세요", message: "오늘의 기록 작성 필요", preferredStyle: .alert)
            let action = UIAlertAction(title: "확인", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated:  true, completion:  nil)
            return
        }
        
        let timeStamp = Date()
        
        let inputDate = inputDatePicker.date

        print(inputDatePicker.date)
        
        guard let walkCountStr = walkCountLabel.text else { return }
            let walkCount = Int(walkCountStr)
         
        guard let walkTimeStr = walkTimeLabel.text else { return }
            let walkTime = Int(walkTimeStr)
        
        guard let pooCountStr = pooLabel.text else { return }
            let pooCount = Int(pooCountStr)
        
        CoreDataManager.shared.saveContext()
        
        if let target = editTarget {
            CoreDataManager.shared.updateMemo(memo: target, memoTitle: memoTitle, memoContext: memoContext, walkCount: walkCount, walkTime: walkTime, pooCount: pooCount, inputDate: inputDate)
            NotificationCenter.default.post(name: .memoDidChange, object: nil)
        } else {
            CoreDataManager.shared.addNewMemo(memoTitle: memoTitle, memoContext: memoContext, timeStamp: timeStamp, walkCount: walkCount, walkTime: walkTime, pooCount: pooCount, inputDate: inputDate)
            NotificationCenter.default.post(name: .newMemoDidInsert, object: nil)
        }
        
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTitleTextField.layer.cornerRadius = 15
        memoContextTextView.layer.cornerRadius = 15
        
        if let target = editTarget {
            memoTitleTextField.text = target.title
            memoContextTextView.text   = target.context
            walkCountLabel.text = "\(target.walkCount)"
            walkTimeLabel.text = "\(target.walkTime)"
            pooLabel.text = "\(target.pooCount)"
            navigationItem.title = "Memo Edit Page"
            
            inputDatePicker.date = target.inputDate!
            
            
        } else {
            print("에러")
        }
    }
}
