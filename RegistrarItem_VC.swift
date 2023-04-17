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
        
        btnCamara.isHidden = true
        
        // Set up a timer to check every 10 seconds
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { timer in
                    
                // Check if both text fields have at least on echaracter
                if let text1 = self.tfNombreItem.text, !text1.isEmpty,
                let text2 = self.lfDescripcion.text, !text2.isEmpty {
                        
                // Show the button
                self.btnCamara.isHidden = false
            }
        }
    }
    
    func fetchFloatValueFromAPI(header1: String, header2: String) {
        // Create URL request with headers
        let url = URL(string: "http://localhost:3007")!
        var request = URLRequest(url: url)
        request.addValue(header1, forHTTPHeaderField: "word")
        request.addValue(header2, forHTTPHeaderField: "input")
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Parse JSON response
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let floatValue = json as? Float else {
                    print("Error: Could not convert JSON response to float")
                    return
                }
                
                // Display alert with float value
                let alert = UIAlertController(title: "Float Value", message: "\(floatValue)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.async {
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }

    @IBAction func TomarFoto(_ sender: UIButton) {
        
        fetchFloatValueFromAPI(header1: tfNombreItem.text!, header2: lfDescripcion.text!)
        
        
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
                
                self.subirDatos(url: urlString);
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
}
