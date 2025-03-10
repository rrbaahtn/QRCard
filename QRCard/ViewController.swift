import UIKit
import CoreImage
import AVFoundation

class ViewController: UIViewController {
    
    // UI Elements
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let nameTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Adınız"
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let phoneTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Telefon Numarası"
        field.borderStyle = .roundedRect
        field.keyboardType = .phonePad
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "E-posta Adresi"
        field.borderStyle = .roundedRect
        field.keyboardType = .emailAddress
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemGray4.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("QR Kod Oluştur", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(generateQRCodeTapped), for: .touchUpInside)
        return button
    }()
    
    private let scanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("QR Kod Tara", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(scanQRCodeTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "QR Kartvizit"
        
        // Add subviews
        view.addSubview(stackView)
        
        [nameTextField, phoneTextField, emailTextField, qrImageView, generateButton, scanButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            qrImageView.heightAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 50),
            scanButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func generateQRCodeTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let phone = phoneTextField.text, !phone.isEmpty,
              let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Lütfen tüm alanları doldurun")
            return
        }
        
        let contactInfo = "İsim: \(name)\nTelefon: \(phone)\nE-posta: \(email)"
        
        if let qrImage = generateQRCode(from: contactInfo) {
            qrImageView.image = qrImage
        } else {
            showAlert(message: "QR kod oluşturulamadı")
        }
    }
    
    @objc private func scanQRCodeTapped() {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = self
        present(scannerVC, animated: true)
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("Q", forKey: "inputCorrectionLevel")
            
            guard let outputImage = filter.outputImage else { return nil }
            
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledQRImage = outputImage.transformed(by: transform)
            
            let context = CIContext()
            guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else { return nil }
            
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Uyarı", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: QRScannerDelegate {
    func qrScannerDidScan(_ code: String) {
        showAlert(message: code)
    }
} 
