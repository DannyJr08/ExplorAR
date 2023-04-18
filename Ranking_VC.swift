//
//  Ranking_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseAuth
import Firebase

class Ranking_VC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var users: Array<user> = []
    
    /*let users = [
        user(name: "Perro", pts: 1),
        user(name: "Gato", pts: 1),
        user(name: "Escritorio", pts: 1),
        user(name: "Juan", pts: 13),
        user(name: "Daniel", pts: 14),
        user(name: "Duerme", pts: 15),
        user(name: "Y ne da cuenta", pts: 16)
    ]*/
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        
        view.addSubview(TableView)
//        TableView.frame =
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(CustomCell.self, forCellReuseIdentifier: "celda")
        TableView.rowHeight = 120
        

        // Do any additional setup after loading the view.
        db.collection("Usuario").getDocuments { (querySnapshot, error) in
            if let error = error {
                self.presentaAlerta(mensaje: "Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    if let nickname = document.get("nickname") as? String, let uidItems = document.get("uidItems") as? Array<String> {
                        self.users.append(user(name: nickname, pts: uidItems.count))
                    } else {
                        self.presentaAlerta(mensaje: "Hubo un error")
                    }
                }
                self.TableView.reloadData()
            }
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath) as! CustomCell
        let user = users[indexPath.row]
        cell.ipts.text = "\(user.pts)"
        cell.iname.text = user.name
//        cell.idesc.text = item.desc
        return cell
    }

    struct user {
        var name: String
        var pts: Int
    }
    
    class CustomCell: UITableViewCell {
        let ipts = UILabel()
        let iname = UILabel()
//        let idesc = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .default
            addSubview(ipts)
            addSubview(iname)
//            addSubview(idesc)
            ipts.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
            iname.frame = CGRect(x: 120, y: 20, width: 130, height: 30)
//            idesc.frame = CGRect(x: 120, y: 60, width: 130, height: 30)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    
    func presentaAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        let accion = UIAlertAction(title: "OK", style: .cancel)
            alerta.addAction(accion)
        present(alerta, animated: true)
    }
    
}
