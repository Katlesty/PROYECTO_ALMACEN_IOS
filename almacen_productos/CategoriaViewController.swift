import UIKit

class CategoriaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var categorias: [Categoria] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        obtenerCategorias()
    }
    
    func obtenerCategorias() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            categorias = try context.fetch(Categoria.fetchRequest()) as! [Categoria]
        } catch {
            print("Error al leer entidad Producto de CoreData")
        }
    }
    
    // MARK: - Tabla
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CeldaC", for: indexPath)
        cell.backgroundColor = .clear

        let categoria = categorias[indexPath.row]
        cell.textLabel?.text = categoria.nombre

        return cell
    }

    
    // MARK: - Agregar Categoría
    
    @IBAction func agregarCategoria(_ sender: Any) {
        let alertController = UIAlertController(title: "Nueva Categoría", message: " ", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Nombre de la categoría"
        }
        
        let agregarAction = UIAlertAction(title: "Agregar", style: .default) { [weak self] _ in
            guard let nombre = alertController.textFields?.first?.text, !nombre.isEmpty else { return }
            
            let nuevaCategoria = Categoria(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            nuevaCategoria.nombre = nombre
            self?.categorias.append(nuevaCategoria)
            self?.tableView.reloadData()
        }
        
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(agregarAction)
        alertController.addAction(cancelarAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Editar y Eliminar Categorías
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoria = categorias[indexPath.row]
        
        let alertController = UIAlertController(title: "Editar Categoría", message: " ", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = categoria.nombre
        }
        
        let guardarAction = UIAlertAction(title: "Guardar", style: .default) { [weak self] _ in
            guard let nombre = alertController.textFields?.first?.text, !nombre.isEmpty else { return }
            
            categoria.nombre = nombre
            do {
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
                self?.tableView.reloadData()
            } catch {
                print("Error al guardar la categoría editada en CoreData: \(error)")
            }
        }
        
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alertController.addAction(guardarAction)
        alertController.addAction(cancelarAction)
        
        present(alertController, animated: true, completion: nil)
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let categoria = categorias[indexPath.row]
            
            let alertController = UIAlertController(title: "Eliminar Categoría", message: "¿Estás seguro de que deseas eliminar esta categoría?", preferredStyle: .alert)
            
            let eliminarAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                context.delete(categoria)
                
                do {
                    try context.save()
                    self?.categorias.remove(at: indexPath.row)
                    self?.tableView.deleteRows(at: [indexPath], with: .fade)
                } catch {
                    print("Error al eliminar la categoría de Core Data: \(error)")
                }
            }
            
            let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            
            alertController.addAction(eliminarAction)
            alertController.addAction(cancelarAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
