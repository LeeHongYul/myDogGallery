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

class NewMemoViewController: BaseViewController {
    var editTarget: MemoEntity?
    
    @IBOutlet var memoTitleTextField: UITextField!
    @IBOutlet var inputDatePicker: UIDatePicker!
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
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /// 경고창
    /// - Parameters:
    ///   - title: 경고창 제목
    ///   - messageStr: 경고창 메시지
    ///   - actionTitleStr: 경고창 버튼
    func addAlert(title: String, messageStr: String, actionTitleStr: String) {
        let alert = UIAlertController(title: title, message: messageStr, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitleStr, style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        let memoTitle = memoTitleTextField.text

        if memoTitle?.count ?? 0 >= 15 {
            showAlert(titile: "제목 글자수가 많습니다. 15자", message: "제목 글자수 수정 필요합니다.")
            return
        }

        let memoContext = memoContextTextView.text

        if memoContext?.count == 0 {
            showAlert(titile: "오늘의 기록을 입력해주세요.", message: "오늘의 기록 작성 필요합니다.")
            return
        }
        let timeStamp = Date()

        let inputDate = inputDatePicker.date

        guard let walkCountStr = walkCountLabel.text else { return }
        let walkCount = Int(walkCountStr)

        guard let walkTimeStr = walkTimeLabel.text else { return }
        let walkTime = Int(walkTimeStr)

        guard let pooCountStr = pooLabel.text else { return }
        let pooCount = Int(pooCountStr)
        MemoManager.shared.saveContext()

        if let target = editTarget {
            MemoManager.shared.updateMemo(memo: target, memoTitle: memoTitle, memoContext: memoContext, walkCount: walkCount, walkTime: walkTime, pooCount: pooCount, inputDate: inputDate)
            NotificationCenter.default.post(name: .memoDidChange, object: nil)
        } else {
            MemoManager.shared.addNewMemo(memoTitle: memoTitle, memoContext: memoContext, timeStamp: timeStamp, walkCount: walkCount, walkTime: walkTime, pooCount: pooCount, inputDate: inputDate)
            NotificationCenter.default.post(name: .newMemoDidInsert, object: nil)
        }
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        memoTitleTextField.layer.cornerRadius = 15
        memoContextTextView.layer.cornerRadius = 15

        // MemoViewController에서 받은 TableViewCell의 메모 내용
        if let target = editTarget {
            memoTitleTextField.text = target.title
            memoContextTextView.text   = target.context
            walkCountLabel.text = "\(target.walkCount)"
            walkTimeLabel.text = "\(target.walkTime)"
            pooLabel.text = "\(target.pooCount)"
            navigationItem.title = "Memo Edit Page"
            inputDatePicker.date = target.inputDate!
            
        } else {
            print("New Memo Page Entered")
        }
    }
}

// 메모제목 14자 넘으면 더 이상 내용 입력 불가능
extension NewMemoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = NSString(string: textField.text ?? "")
        let finalText = currentText.replacingCharacters(in: range, with: string)
        
        switch textField {
        case memoTitleTextField:
            if finalText.count >= 14 {
                return false
            }
        default:
            break
        }
        return true
    }
}
