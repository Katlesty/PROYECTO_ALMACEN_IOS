import UIKit
import SwiftUI

class EditarProductoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var Vista: UIView!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var txtNombre: UITextField!
    @IBOutlet var txtCategoria: UITextField!
    @IBOutlet var txtCantidad: UITextField!
    @IBOutlet var txtPrecio: UITextField!
    @IBOutlet var txtDescripcion: UITextField!
    
    var producto: Producto? = nil
    
    var anteriorVC = ProductosViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let producto = producto {
            txtNombre.text = producto.nombre
            txtCategoria.text = producto.categoria
            txtCantidad.text = String(producto.cantidad)
            txtPrecio.text = String(producto.precio)
            txtDescripcion.text = producto.descripcion
            
            if let imageData = producto.imagen, let image = UIImage(data: imageData) {
                    imageView.image = image
                } else {
                    imageView.image = nil
                }
        }
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

    @IBAction func editarProducto(_ sender: Any) {
        
        guard let producto = producto else {return}
        
        producto.nombre = txtNombre.text
        producto.categoria = txtCategoria.text
        
        if let cantidadText = txtCantidad.text, let cantidadV = Int16(cantidadText) {
            producto.cantidad = cantidadV
        }
        
        if let precioText = txtPrecio.text, let precioV = Double(precioText) {
            producto.precio = precioV
        }
        
        if let selectedImage = imageView.image {
            producto.imagen = selectedImage.jpegData(compressionQuality: 1.0)
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        navigationController?.popViewController(animated:true)
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
