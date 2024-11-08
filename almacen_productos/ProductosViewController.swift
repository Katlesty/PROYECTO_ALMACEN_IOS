import UIKit
import SwiftUI

class ProductosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var searchButton: UISearchBar!
    @IBOutlet var tableView: UITableView!
    
    var productos: [Producto] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // DISEÑO
        
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        let contentView = ContentView()

        let hostingController = UIHostingController(rootView: contentView)

        addChild(hostingController)

        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(hostingController.view, at: 0)

        hostingController.didMove(toParent: self)
        
        // Diseño del search

        if let textField = searchButton.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor(hex: "#FFFFFF")
            textField.textColor = UIColor.black
            textField.layer.borderWidth = 0
            textField.layer.cornerRadius = 1
            textField.clipsToBounds = true
        }

        searchButton.backgroundImage = UIImage()
        searchButton.layer.backgroundColor = UIColor.clear.cgColor
        searchButton.layer.cornerRadius = 1
        searchButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        obtenerProductos()
        tableView.reloadData()
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
    
    func obtenerProductos() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            productos = try context.fetch(Producto.fetchRequest()) as! [Producto]
        } catch {
            print("Error al leer entidad Producto de CoreData")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
        
        cell.contentView.layer.cornerRadius = 15
        cell.contentView.layer.masksToBounds = true
        cell.backgroundColor = .clear
    
        
        let producto = productos[indexPath.row]
        
        cell.lblNombre?.text = producto.nombre
        cell.lblCategoria?.text = producto.categoria
        
        //CANTIDAD
        if let cantidad = Int16(exactly: producto.cantidad) {
            cell.lblCantidad?.text = String(cantidad)
        } else {
            cell.lblCantidad?.text = "N/A"
        }
        
        //PRECIO
        let precio = Double(producto.precio)
           
        if precio.isNaN {
            cell.lblPrecio?.text = "N/A"
        } else {
            cell.lblPrecio?.text = String(format: "S/. %.2f", precio)
        }
        
        //IMAGEN
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            cell.imagenView?.image = image
        } else {
            cell.imagenView?.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let producto = productos[indexPath.row]
            
            let alertController = UIAlertController(title: "Eliminar Producto", message: "¿Estás seguro de que deseas eliminar este producto?", preferredStyle: .alert)
                
            let eliminarAction = UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                    
                context.delete(producto)
                do {
                    try context.save()
                } catch {
                    print("Error al eliminar el producto de Core Data: \(error)")
                }
                    
                self.productos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                }
                
            let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                
                alertController.addAction(eliminarAction)
                alertController.addAction(cancelarAction)
                
                present(alertController, animated: true, completion: nil)
            }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let botonEliminar = UITableViewRowAction(style: .normal, title: "Eliminar") { (action, indexPath) in
            
            let productoAEliminar = self.productos[indexPath.row]
            
            let alertController = UIAlertController(title: "Eliminar Producto", message: "¿Estás seguro de que deseas eliminar este producto?", preferredStyle: .alert)
            
            // Acción de confirmación
            let eliminarAction = UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        
                context.delete(productoAEliminar)
                do {
                    try context.save()
                } catch {
                    print("Error al eliminar el producto de Core Data: \(error)")
                }
                        
                self.productos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                    
            alertController.addAction(eliminarAction)
            alertController.addAction(cancelarAction)
                    
            self.present(alertController, animated: true, completion: nil)
        }
        botonEliminar.backgroundColor = UIColor.red
        
        let botonEditar = UITableViewRowAction(style: .normal, title: "Editar") { (action, indexPath) in
            self.performSegue(withIdentifier: "segueEditar", sender: self.productos[indexPath.row])
        }
        botonEditar.backgroundColor = UIColor.blue
        
        return [botonEliminar, botonEditar]
    }


    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let producto = productos[indexPath.row]
        performSegue(withIdentifier: "segueDetalle", sender: producto)
    }
    
    @IBAction func agregarProducto(_ sender: Any) {
        performSegue(withIdentifier: "segueAgregar", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueAgregar" {
            let destinoVC = segue.destination as! AgregarProductoViewController
            destinoVC.anteriorVC = self
        } else if segue.identifier == "segueDetalle" {
            if let destinoVC = segue.destination as? DetalleProductoViewController{
                destinoVC.producto = sender as? Producto
            }
        } else if segue.identifier == "segueEditar" {
            if let destinoVC = segue.destination as?
                EditarProductoViewController {
                destinoVC.producto = sender as? Producto
            }
        }
    }
}
