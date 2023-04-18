//
//  RegistrarItem_VC.swift
//  ExplorAR
//
//  Created by Juan Daniel Rodríguez Oropeza on 16/04/23.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import Firebase

class RegistrarItem_VC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tfNombreItem: UITextField!
    @IBOutlet weak var lfDescripcion: UITextField!
    @IBOutlet weak var btnConfirmarDatos: UIButton!
    @IBOutlet weak var btnCamara: UIButton!
    
    var foto = UIImage()
    let imagePicker = UIImagePickerController()
    
    private let storage = Storage.storage().reference()
    
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        
        btnConfirmarDatos.isHidden = false
        btnCamara.isHidden = true
        tfNombreItem.isEnabled = true
        lfDescripcion.isEnabled = true
    }
    
    func getAccuracy(word: String, input: String, completion: @escaping (Float?) -> Void) {
        let urlComponents = NSURLComponents(string: "http://localhost:3007/api/accuracy")!

        urlComponents.queryItems = [
            URLQueryItem(name: "word", value: word),
            URLQueryItem(name: "input", value: input)
        ]

        let request = URLRequest(url: urlComponents.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error en la solicitud:", error ?? "Error desconocido")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let accuracy = json["accuracy"] as? NSNumber {
                    DispatchQueue.main.async {
                        completion(accuracy.floatValue)
                    }
                } else {
                    print("Error al analizar el JSON")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch let error {
                print("Error al procesar el JSON:", error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }


    @IBAction func TomarFoto(_ sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        //foto = img!
        
        guard let imageData = img.pngData() else {
            return
        }
        
        //btnCamara.isHidden = true
        
        storage.child("imgItems/\(tfNombreItem.text!)/\(Auth.auth().currentUser!.uid).png").putData(imageData, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("No se pudo subir")
                return
            }
            
            self.storage.child("imgItems\(self.tfNombreItem.text!)/\(Auth.auth().currentUser!.uid).png").downloadURL(completion: { url, error in
                guard let url = url, error == nil else {
                    return
                }
                
                let urlString = url.absoluteString
                
                /*DispatchQueue.main.async {
                 self.foto = img
                 }*/
                
                print("Primer Hola")
                UserDefaults.standard.set(urlString, forKey: "url")
                
                print(urlString)
                print("Hola")
                
                self.db.collection("Item").document(Auth.auth().currentUser!.uid).setData(["urlImg": urlString], merge: true) {
                    (error) in
                    
                    if error != nil {
                        let alerta = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                        let accion = UIAlertAction(title: "OK", style: .cancel)
                        alerta.addAction(accion)
                        self.present(alerta, animated: true)
                    }
                }
                
                self.subirDatos(url: urlString)
            })
        })
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 19) {
            // code to remove your view
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func presentaAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        let accion = UIAlertAction(title: "OK", style: .cancel)
            alerta.addAction(accion)
        present(alerta, animated: true)
    }
    
    @IBAction func ConfirmarDatos(_ sender: UIButton) {
        // Check if both text fields have at least one character
            if let text1 = tfNombreItem.text, !text1.isEmpty,
            let text2 = lfDescripcion.text, !text2.isEmpty {
                
                self.getAccuracy(word: tfNombreItem.text!, input: lfDescripcion.text!) { accuracy in
                    if let accuracy = accuracy {
                        let alerta = UIAlertController(title: "Si tienes un porcentaje mayor de 70, puedes tomar la foto.", message: "\(accuracy)", preferredStyle: .alert)
                        let accion = UIAlertAction(title: "OK", style: .cancel)
                        alerta.addAction(accion)
                        self.present(alerta, animated: true)
                        
                        if accuracy >= 70 {
                            // Show the button
                            self.btnConfirmarDatos.isHidden = true
                            self.tfNombreItem.isEnabled = false
                            self.lfDescripcion.isEnabled = false
                            self.btnCamara.isHidden = false
                        }
                    } else {
                        self.presentaAlerta(mensaje: "No se pudo obtener el JSON")
                    }
                }

            }
            else {
                presentaAlerta(mensaje: "Debes llenar todos los campos.")
            }
    }
    
    
    func subirDatos(url: String) {
        if tfNombreItem.text?.isEmpty == true || lfDescripcion.text?.isEmpty == true {
            presentaAlerta(mensaje: "NO debe quedar ningún campo vacío.")
        } else {
            db.collection("Item").document("\(tfNombreItem.text!)").setData(["nombre": self.tfNombreItem.text!,"descripcion": self.lfDescripcion.text!, "urlImg": url]) {
                (error) in
                
                if error != nil {
                    let alerta = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
                    let accion = UIAlertAction(title: "OK", style: .cancel)
                    alerta.addAction(accion)
                    self.present(alerta, animated: true)
                } else {
                    let alerta = UIAlertController(title: "Proceso Finalizado!", message: "Porfavor salir de esta pestaña" , preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alerta, animated: true)
                }
            }
        }
    }
    
    
    @IBAction func quitaTeclado(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
}
