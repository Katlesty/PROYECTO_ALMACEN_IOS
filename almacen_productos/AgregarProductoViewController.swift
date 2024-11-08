import UIKit
import SwiftUI

class AgregarProductoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var Vista: UIView!
    
    @IBOutlet var txtNombreProducto: UITextField!
    @IBOutlet var txtCategoriaProducto: UITextField!
    @IBOutlet var txtCantidadProducto: UITextField!
    @IBOutlet var txtPrecioProducto: UITextField!
    @IBOutlet var txtDescripcion: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    var anteriorVC = ProductosViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // DISEÑO
        
        let contentView = ContentView()

        let hostingController = UIHostingController(rootView: contentView)

        addChild(hostingController)

        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(hostingController.view, at: 0)

        hostingController.didMove(toParent: self)
        
        self.navigationController?.navigationBar.tintColor = .white
        
        Vista.layer.cornerRadius = 20
        Vista.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
    }
    
    //DISEÑO
    struct ContentView: View {
        var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 129/255, green: 169/255, blue: 203/255),
                    Color(red: 63/255, green: 112/255, blue: 153/255)
                ]),
                startPoint: .leading,
                endPoint: .trailing)
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    var cantidadV: Int = 0
    var precioV: Double = 0
    
    @IBAction func agregarProducto(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let producto = Producto(context: context)
        
        producto.nombre = txtNombreProducto.text
        producto.categoria = txtCategoriaProducto.text
        producto.descripcion = txtDescripcion.text
        
        if let cantidadText = txtCantidadProducto.text, let cantidadV = Int16(cantidadText) {
            producto.cantidad = cantidadV
        }
        if let precioText = txtPrecioProducto.text, let precioV = Double(precioText) {
            producto.precio = precioV
        }
        if let selectedImage = imageView.image {
            producto.imagen = selectedImage.jpegData(compressionQuality: 1.0)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func agregarImagen(_ sender: Any) {
        print("Intentando abrir la galería...")
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            print("Imagen seleccionada y asignada")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)  
    }
    
}
