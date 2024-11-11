import UIKit
import DGCharts
import CoreData

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var lblTotalP: UILabel!
    @IBOutlet var lblValorT: UILabel!
    
    @IBOutlet var view1: UIView!
    @IBOutlet var view2: UIView!
    @IBOutlet var view3: UIView!
    @IBOutlet var viewChart: UIView!
    
    @IBOutlet var tableViewC: UITableView!
    
    var categorias: [Categoria] = []
    
    var barChartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view1.layer.cornerRadius = 16
        view1.layer.masksToBounds = true
        
        view2.layer.cornerRadius = 16
        view2.layer.masksToBounds = true
        
        view3.layer.cornerRadius = 16
        view3.layer.masksToBounds = true
        
        barChartView = BarChartView()
        barChartView.frame = viewChart.bounds
        barChartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewChart.addSubview(barChartView)
        
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mostrarTotalDeProductosYValorTotal()
        setData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Celda", for: indexPath) as! TableViewCell
        
        cell.backgroundColor = .clear

        let categoria = categorias[indexPath.row]
        
        cell.lblNombre?.text = categoria.nombre
        
        return cell
    }
    func mostrarTotalDeProductosYValorTotal() {
            
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                print("Error: Contexto de Core Data no disponible.")
                return
            }
            
            let resultado = obtenerTotalDeProductosYValorTotal(context: context)
            
            lblTotalP.text = "\(resultado.totalProductos)"
            lblValorT.text = "S/ \(resultado.valorTotal)"
        }
        
    func obtenerTotalDeProductosYValorTotal(context: NSManagedObjectContext) -> (totalProductos: Int, valorTotal: Double) {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Producto")
        
        let totalProductos: Int
        do {
            totalProductos = try context.count(for: fetchRequest)
        } catch {
            print("Error al contar productos: \(error)")
            totalProductos = 0
        }
        
        let precioExpression = NSExpressionDescription()
        precioExpression.name = "precioTotal"
        precioExpression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "precio")])
        precioExpression.expressionResultType = .doubleAttributeType
        
        fetchRequest.propertiesToFetch = [precioExpression]
        fetchRequest.resultType = .dictionaryResultType
        
        var valorTotal: Double = 0.0
        do {
            if let result = try context.fetch(fetchRequest) as? [[String: Double]],
               let precioTotal = result.first?["precioTotal"] {
                valorTotal = precioTotal
            }
        } catch {
            print("Error al obtener el valor total de precios: \(error)")
        }
        
        return (totalProductos, valorTotal)
    }

    
    func contarProductosPorCategoria(context: NSManagedObjectContext, categories: [String]) -> [Double] {
        var categoryCounts: [Double] = []
        
        for category in categories {
            let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "categoria == %@", category)
            
            do {
                let count = try context.count(for: fetchRequest)
                categoryCounts.append(Double(count))
            } catch {
                print("Error al contar productos para la categoría \(category): \(error)")
                categoryCounts.append(0)
            }
        }
        return categoryCounts
    }
    
    func setData() {
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            return
        }
        
        do {
            categorias = try context.fetch(Categoria.fetchRequest()) as! [Categoria]
        } catch {
            print("Error al leer entidad Categoria de CoreData")
            return
        }
        
        var categoryNames: [String] = []
        var productCounts: [Double] = []
        

        for categoria in categorias {
            let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "categoria == %@", categoria.nombre!)
            
            do {
                
                let productCount = try context.count(for: fetchRequest)
                categoryNames.append(categoria.nombre ?? "Sin Nombre")
                productCounts.append(Double(productCount))
            } catch {
                print("Error al contar productos para la categoría \(categoria.nombre ?? "Desconocida"): \(error)")
                productCounts.append(0)
            }
        }
        

        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<categoryNames.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: productCounts[i])
            dataEntries.append(dataEntry)
        }
        
      
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Productos por Categoría")
        chartDataSet.colors = [
            UIColor(hex: "#A8E5FC"),
            UIColor(hex: "#C4A8FC"),
            UIColor(hex: "#FCA8BA"),
            UIColor(hex: "#B17C5F")
        ]
        
        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.7
        chartData.setDrawValues(false)
        

        barChartView.data = chartData
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: categoryNames)
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawAxisLineEnabled = true
        
        barChartView.rightAxis.enabled = false
        barChartView.chartDescription.enabled = false
        barChartView.legend.enabled = false
        
        barChartView.animate(yAxisDuration: 1.5, easingOption: .easeOutBounce)
    }

}

