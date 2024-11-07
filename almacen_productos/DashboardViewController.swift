import UIKit
import DGCharts
import CoreData

class DashboardViewController: UIViewController {
    

    @IBOutlet var lblTotalP: UILabel!
    @IBOutlet var lblValorT: UILabel!
    
    var barChartView: BarChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mostrarTotalDeProductosYValorTotal()
        
        barChartView = BarChartView()
                barChartView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 40, height: 300)
                barChartView.center = view.center
                view.addSubview(barChartView)
                
                setData()
    }
    
    func mostrarTotalDeProductosYValorTotal() {
            
            guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
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
            let categories = ["Audífonos", "Sillas gamer", "Streaming", "Monitores"]
            let values = contarProductosPorCategoria(context: context, categories: categories)
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<categories.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "")
            
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
            
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: ["0", "1", "2", "3"])
            barChartView.xAxis.granularity = 1
            barChartView.xAxis.labelPosition = .bottom
            barChartView.xAxis.drawGridLinesEnabled = false
            barChartView.xAxis.drawAxisLineEnabled = false
            
            barChartView.leftAxis.axisMaximum = 36
            barChartView.leftAxis.axisMinimum = 5
            barChartView.leftAxis.granularity = 5
            barChartView.leftAxis.drawGridLinesEnabled = false
            barChartView.leftAxis.drawAxisLineEnabled = true
            
            barChartView.rightAxis.enabled = false
            
            barChartView.chartDescription.enabled = false
            
            barChartView.legend.enabled = false
            
            barChartView.animate(yAxisDuration: 1.5, easingOption: .easeOutBounce)
    }
}

