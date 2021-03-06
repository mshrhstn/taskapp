//
//  InputViewController.swift
//  taskapp
//
//  Created by 菱谷昌弘 on 2020/07/29.
//  Copyright © 2020 masahiro.hishitani. All rights reserved.
//

import UIKit
import RealmSwift    // 追加
import UserNotifications    // 追加

class InputViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let realm = try! Realm()    // 追加する
    var task: Task!   // 追加する
    
    let datalist: [String] = ["予定", "リハ", "ライブ", "重要", "スクール"]
    
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datalist.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return datalist[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var passedCategory = task.category
        var categoryNo = 0
        
        for (index, cat) in datalist.enumerated() {
            print(passedCategory)
          if(cat == passedCategory){
            categoryNo = index
            break
          }
          else {
            continue
          }
        }
        
        // ピッカー設定
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(categoryNo, inComponent: 0, animated: false)
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
            let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
            self.view.addGestureRecognizer(tapGesture)

            titleTextField.text = task.title
            contentsTextView.text = task.contents
            datePicker.date = task.date
        }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write { //データベースへ保存する
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = datalist[self.pickerView.selectedRow(inComponent: 0)]
            self.realm.add(self.task, update: .modified)
            
        }
        setNotification(task: task)   // 追加

        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで追加 ---

        @objc func dismissKeyboard(){
            // キーボードを閉じる
            view.endEditing(true)
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
}
    */

