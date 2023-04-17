//
//  Login_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseAuth
import Firebase


class Login_VC: UIViewController {
    
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title="Autenticación"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "LoginAInicio", sender: self)
        }
    }
    
    
    @IBAction func IniciarSesion(_ sender: UIButton) {
        validarTextFields()
    }
    
    func validarTextFields() {
        if tfEmail.text?.isEmpty == true || tfContrasena.text?.isEmpty == true {
            let alerta = UIAlertController(title: "Error", message: "Debe haber texto en todos los campos", preferredStyle: .alert)
            let accion = UIAlertAction(title: "OK", style: .cancel)
                alerta.addAction(accion)
            present(alerta, animated: true)
        }
        login()
    }
        
    func login() {
        Auth.auth().signIn(withEmail: tfEmail.text!, password: tfContrasena.text!) {
            (result, error) in
            if error != nil {
                let alerta = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                let accion = UIAlertAction(title: "OK", style: .cancel)
                    alerta.addAction(accion)
                self.present(alerta, animated: true)
            }
            else {
                self.performSegue(withIdentifier: "LoginAInicio", sender: self)
            }
        }
    }

    @IBAction func quitaTeclado(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
