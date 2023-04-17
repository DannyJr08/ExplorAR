//
//  Biblio_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseAuth
import Firebase

class Biblio_VC: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var listaIDNomItems: Array<String> = []
    
    let db = Firestore.firestore()
    
    var items: Array<item> = []

    /*let items = [
        item(name: "Perro", image: "image (1)", desc: "en la descripcion es al revez"),
        item(name: "Gato", image: "", desc: "en los nombres"),
        item(name: "Escritorio", image: "", desc: "a abajo"),
        item(name: "Juan", image: "", desc: "ademas va de arriba"),
        item(name: "Daniel", image: "", desc: "espero y no lea este texto"),
        item(name: "Duerme", image: "", desc: "menso"),
        item(name: "Y no se da cuenta", image: "", desc: "jejeje")
    ]*/
    
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(TableView)
//        TableView.frame =
        TableView.dataSource = self
        TableView.delegate = self
        TableView.register(CustomCell.self, forCellReuseIdentifier: "cell")
        TableView.rowHeight = 120
        

        // Do any additional setup after loading the view.
        db.collection("Usuario").document(Auth.auth().currentUser!.uid).getDocument {
            (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let idItems = document.get("uidItems") as? Array<String> {
                    //self.listaIdMedicos = idMedicos
                    //print("")
                    print(idItems)
                    if idItems == [] {
                        let alerta = UIAlertController(title: "Aviso: NO tienes médicos vinculados.", message: "Primero el médico te tiene que agregar ingresando el token que se genera en la sección de perfil, en el ícono de la esquina superior izquierda.", preferredStyle: .alert)
                        let accion = UIAlertAction(title: "OK", style: .cancel) { accion in self.dismiss(animated: true)}
                        alerta.addAction(accion)
                        self.present(alerta, animated: true)
                    }
                    else {
                        self.getItems(ids: idItems)
                    }
                }
            }
            else {
                self.presentaAlerta(mensaje: error!.localizedDescription)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCell
        let item = items[indexPath.row]
        cell.iimage.image = UIImage(named: item.image)
        cell.iname.text = item.name
//        cell.idesc.text = item.desc
        return cell
    }

    struct item {
        var name: String
        var image: String
        var desc: String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create a new alert
    let alert = UIAlertController(title: "Descripción:", message: items[indexPath.row].desc, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alert, animated: true, completion: nil)
    }
    
    class CustomCell: UITableViewCell {
        let iimage = UIImageView()
        let iname = UILabel()
//        let idesc = UILabel()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            selectionStyle = .default
            addSubview(iimage)
            addSubview(iname)
//            addSubview(idesc)
            iimage.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
            iname.frame = CGRect(x: 120, y: 20, width: 130, height: 30)
//            idesc.frame = CGRect(x: 120, y: 60, width: 130, height: 30)
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func getItems(ids: Array<String>) {
        for id in stride(from: 0, to: ids.count, by: 1) {
            self.listaIDNomItems.append(ids[id])
            db.collection("Item").document(ids[id]).getDocument {
                (documentSnapshot, error) in
                if let document = documentSnapshot, error == nil {
                    if let nombre = document.get("nombre") as? String, let descripcion = document.get("descripcion") as? String, let urlImg = document.get("urlImg") as? String {
                        self.items.append(item(name: nombre, image: urlImg, desc: descripcion))
                    } else {
                        self.presentaAlerta(mensaje: error!.localizedDescription)
                    }
                    self.TableView.reloadData()
                }
            }
        }
    }

    func presentaAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        let accion = UIAlertAction(title: "OK", style: .cancel)
            alerta.addAction(accion)
        present(alerta, animated: true)
    }
}
