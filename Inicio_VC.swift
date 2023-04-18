//
//  Inicio_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseAuth
import Firebase

class Inicio_VC: UIViewController {
    
    @IBOutlet weak var lbNombre: UILabel!
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        db.collection("Usuario").document(Auth.auth().currentUser!.uid).getDocument {
            (documentSnapshot, error) in
            if let document = documentSnapshot, error == nil {
                if let nickname = document.get("nickname") as? String {
                    self.lbNombre.text = nickname
                }
            }
            else {
                self.lbNombre.text = error?.localizedDescription
            }
        }
    }
    

    @IBAction func CerrarSesion(_ sender: UIButton) {
        let auth = Auth.auth()
        
        let alerta = UIAlertController(title: "¿Estás seguro?", message: "Estás a punto de cerrar sesión.", preferredStyle: .alert)
        let accion1 = UIAlertAction(title: "No", style: .cancel)
        let accion2 = UIAlertAction(title: "Sí", style: .default) { accion2 in
            do {
                try auth.signOut()
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: "isUserSignedIn")
                self.performSegue(withIdentifier: "InicioALogin", sender: self)
            }
            catch let signOutError {
                let alerta = UIAlertController(title: "Error", message: signOutError.localizedDescription, preferredStyle: .alert)
                let accion = UIAlertAction(title: "OK", style: .cancel)
                    alerta.addAction(accion)
            }
        }
        alerta.addAction(accion1)
        alerta.addAction(accion2)
        present(alerta, animated: true)
    }
    
}
