import UIKit
import SwiftUI

class DetalleProductoViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var txtNombre: UILabel!
    @IBOutlet var txtCategoria: UILabel!
    @IBOutlet var txtDescripcion: UILabel!
    @IBOutlet var txtPrecio: UILabel!
    
    var producto: Producto? = nil
    
    var anteriorVC = ProductosViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let producto = producto {
            txtNombre.text = producto.nombre
            txtCategoria.text = producto.categoria
            txtPrecio.text = String(format: "S/. %.2f", producto.precio)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
