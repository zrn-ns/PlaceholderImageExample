//
//  ViewController.swift
//  PlaceholderImageExampleApp
//
//  Created by zrn_ns on 2024/11/29.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addConstraints([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])

        let url = URL(string: "http://placeholder/image.png?width=300&height=200&text=Hello&fgcolor=ffffff&bgcolor=ff0000")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        task.resume()
    }
    let imageView: UIImageView = {
        let imageView: UIImageView = .init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}

#Preview {
    ViewController()
}
