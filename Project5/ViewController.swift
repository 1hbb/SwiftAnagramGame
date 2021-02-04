//
//  ViewController.swift
//  Project5
//
//  Created by burk burs on 1.02.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(newWord))
        
        
        if let txtFileUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let allDataInTxtFile = try? String(contentsOf: txtFileUrl){
                // split words by "\n" and add in allWords array
                allWords = allDataInTxtFile.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty{
            allWords = ["silkwarm"]
        }
        
        
        startGame()
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
    
    
    
    func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll()
        tableView.reloadData()
    }
    
    @objc func promptForAnswer(){
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
        
    }
    
    @objc func newWord(){
        startGame()
    }
    
    
    func submit(_ answer:String){
        let lowerAnswer = answer.lowercased()
        var alertTitle:String
        var alertMessage:String
        
        if isPossible(lowerAnswer){
            if isOriginal(lowerAnswer){
                if isReal(lowerAnswer){
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    // add new word top of the table view instead of adding end and reload all data in table view
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                    
                }
                else{
                    alertTitle = "Misspelled Word!"
                    alertMessage = "This is not real word"
                }
            }
            else{
                alertTitle = "Used Word Dedected"
                alertMessage = "This word already used"
            }
        }
        
        else{
            alertTitle = "This Word not possible"
            alertMessage = "You cant generate this word from given word"
        }
        
        let ac = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        ac.addAction(okAction)
        
        present(ac, animated: true)
    }
    
    func isPossible(_ word:String) -> Bool {
        guard var tmpWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tmpWord.firstIndex(of: letter) {
                tmpWord.remove(at: position)
            }
            else{
                return false
            }
        }
        
        return true
        
    }
    
    // in this function we will check is typed work is misspelled word or not
    func isReal(_ word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: true, language: "en")
        let result:Bool = misspelledRange.location == NSNotFound
        return result
    }
    
    // this function checks typed word is used
    func isOriginal(_ word:String) -> Bool {
        return !usedWords.contains(word)
    }
    
    // refresh table view data
    @IBAction func refreshControlValueChanged(_ sender: UIRefreshControl) {
        tableView.reloadData()
        sender.endRefreshing()
    }
    
}

