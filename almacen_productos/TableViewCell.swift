import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var lblNombre: UILabel!
    @IBOutlet var lblCategoria: UILabel!
    @IBOutlet var lblCantidad: UILabel!
    @IBOutlet var lblPrecio: UILabel!
    @IBOutlet weak var imagenView: UIImageView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        imagenView.layer.cornerRadius = 10
        imagenView.layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
        
    }
}
