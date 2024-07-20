//
//  ViewController.swift
//  F1Vision
//
//  Created by br3nd4nt on 10.06.2024.
//

import UIKit

class MainViewController: UIViewController {
    private let table: UITableView = UITableView();
    private let testView: UIView = UIView();
    private var drivers: [DriverData] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        configureUI();
        
    }
    
    func configureUI() {
        view.addSubview(testView)
//        testView.pin(to: self.view)
//        testView.backgroundColor = .cyan
        configureTable();
    }
    
    private func configureTable() {
        self.view.addSubview(table);
        table.backgroundColor = .systemMint;
        table.delegate = self;
        table.dataSource = self;
        table.pinTop(to: view.safeAreaLayoutGuide.topAnchor);
        table.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor);
        table.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor);
        table.pinRight(to: view.safeAreaLayoutGuide.centerXAnchor);
        table.register(DriverTableViewCell.self, forCellReuseIdentifier: DriverTableViewCell.reuseId);
    }
}

extension MainViewController: UITableViewDelegate {}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: DriverTableViewCell.reuseId, for: indexPath) as! DriverTableViewCell;
        if (indexPath.row < self.drivers.count) {
            cell.configure(with: self.drivers[indexPath.row]);
        }
        return cell;
    }
}
