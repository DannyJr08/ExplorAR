//
//  SignUp_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUp_VC: UIViewController {
    
    @IBOutlet weak var tfNombreCompleto: UITextField!
    @IBOutlet weak var tfNickname: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfContrasena: UITextField!
    @IBOutlet weak var tfConfContrasena: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    static func isPasswordValid(contrasenia: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: contrasenia)
    }
    
    @IBAction func SignUp(_ sender: UIButton) {
        if tfNombreCompleto.text?.isEmpty == true || tfNickname.text?.isEmpty == true || tfEmail.text?.isEmpty == true || tfContrasena.text?.isEmpty == true || tfConfContrasena.text?.isEmpty == true {
            presentaAlerta(mensaje: "NO debe quedar ningún campo vacío.")
        }
        if SignUp_VC.isPasswordValid(contrasenia: tfContrasena.text!) == false {
            presentaAlerta(mensaje: "Por favor asegurese que la contraseña tenga al menos 8 carácteres, un carácter especial, y un número.")
        }
        if tfContrasena.text != tfConfContrasena.text {
            presentaAlerta(mensaje: "Las contraseñas deben ser iguales.")
        }
        
        Auth.auth().createUser(withEmail: tfEmail.text!, password: tfContrasena.text!) {
            (result, err) in
            if err != nil {
                let alerta = UIAlertController(title: "Error", message: err!.localizedDescription, preferredStyle: .alert)
                let accion = UIAlertAction(title: "OK", style: .cancel)
                    alerta.addAction(accion)
                self.present(alerta, animated: true)
            }
            else {
                // El usuario fue creado exitosamente, ahora almacenar sus datos en la base de datos.
                let db = Firestore.firestore()
                
                db.collection("Usuario").document(result!.user.uid).setData(["nickname": self.tfNickname.text!, "uid": result!.user.uid]) {
                    (error) in
                    
                    if error != nil {
                        let alerta = UIAlertController(title: "Error", message: err!.localizedDescription, preferredStyle: .alert)
                        let accion = UIAlertAction(title: "OK", style: .cancel)
                            alerta.addAction(accion)
                        self.present(alerta, animated: true)
                    }
                    else {
                        self.performSegue(withIdentifier: "SignUpAInicio", sender: self)
                    }
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
    
    @IBAction func quitaTeclado(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
