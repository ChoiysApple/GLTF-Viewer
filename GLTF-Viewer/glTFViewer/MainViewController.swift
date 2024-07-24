//
//  MainViewController.swift
//  glTFViewer
//
//  Created by Daegeon Choi on 7/25/24.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    lazy var objectButton: UIButton = {
        let button = UIButton()
        button.setTitle("Object", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        return button
    }()
    
    lazy var arButton: UIButton = {
        let button = UIButton()
        button.setTitle("AR", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        objectButton.addTarget(self, action: #selector(self.gotoObject), for: .touchUpInside)
        arButton.addTarget(self, action: #selector(self.gotoAR), for: .touchUpInside)
        self.layout()
    }
    

    private func layout() {
        
        self.view.backgroundColor = .white
        
        var stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        
        self.view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.directionalHorizontalEdges.equalToSuperview().inset(50)
        }
        
        [objectButton, arButton].forEach { stack.addArrangedSubview($0) }
    }

}

extension MainViewController {
    
    @objc
    private func gotoObject() {
        self.navigationController?.pushViewController(ObjectViewController(), animated: true)
    }
    
    @objc
    private func gotoAR() {
        self.navigationController?.pushViewController(ARViewController(), animated: true)
    }
}
