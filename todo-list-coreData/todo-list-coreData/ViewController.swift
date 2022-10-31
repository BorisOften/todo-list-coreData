//
//  ViewController.swift
//  todo-list-coreData
//
//  Created by Boris Ofon on 10/31/22.
//

import UIKit

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource{
    
    private var tableView: UITableView!

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        getAllItems()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounds = view.bounds
        title = "Core list todo"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
      
    }
    @objc func didTapAdd(){
        let alert = UIAlertController(title: "New Item", message: "Enter New item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "sumbit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text , !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
            
        }))
        
        present(alert,animated: true)
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = models[indexPath.row]
        let sheet = UIAlertController(title: "edit", message: nil, preferredStyle: .alert)
        sheet.addTextField(configurationHandler: nil)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text , !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
                
            }))
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteItem(item: item)
            tableView.reloadData()
        }))
        
        present(sheet,animated: true)
        
        tableView.reloadData()
    }
        
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel!.text = model.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
           //an error
        }
    }
    
    func createItem(name: String){
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
           //an error
        print("There was an error")
        }
        
    }
    
    func deleteItem(item: ToDoListItem){
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
           //an error
        }
    }

    func updateItem(item: ToDoListItem, newName : String){
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch {
           //an error
        }
        
    }

}

