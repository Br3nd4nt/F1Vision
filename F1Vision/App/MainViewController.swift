//
//  ViewController.swift
//  F1Vision
//
//  Created by br3nd4nt on 10.06.2024.
//

import UIKit

class MainViewController: UIViewController {
    private let table: UITableView = UITableView();
    private var drivers: [DriverData] = [];
    
    private let trackView: TrackView = TrackView();
    
    var targetRatio: Float = 0;
    
    // search bar for testing
    private let textField: UITextField = UITextField()
    private let searchButton: UIButton = UIButton();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .darkGray
        
        createTestDriverData()
        configureUI();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textField.text = "baku"
        self.onButtonPressed()
    }
    
    func configureUI() {
        configureTable();
        
        configureTestSearch()
        
        
        view.addSubview(trackView)
        
        trackView.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor)
        trackView.pinLeft(to: table.trailingAnchor)
        trackView.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor)
        trackView.pinTop(to: textField.bottomAnchor)
    }
    
    func configureTestSearch() {
        view.addSubview(textField)
        textField.backgroundColor = UIColor(white: 0.3, alpha: 1)
        textField.placeholder = "   Search for track..."
        textField.pinLeft(to: table.trailingAnchor)
        textField.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
//        textField.pinRight(to: searchButton.leadingAnchor)
        textField.font = .systemFont(ofSize: 30)
        
        view.addSubview(searchButton)
        searchButton.setTitle("   Search   ", for: .normal)
        searchButton.backgroundColor = .systemMint
        searchButton.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        searchButton.pinRight(to: view.safeAreaLayoutGuide.trailingAnchor)
        searchButton.pinLeft(to: textField.trailingAnchor)
        searchButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)
    }
    
    @objc
    func onButtonPressed() {
        self.trackView.reset()
        if textField.hasText{
            self.trackView.trackGP = textField.text!
            self.trackView.targetRatio = (self.trackView.bounds.height / self.trackView.bounds.width)
            self.trackView.connectToServer(completion: {
                for driver in self.drivers {
                    self.trackView.drawDriver(driver: driver)
                }
            })
            
            
        }
    }
    
    
    
    func createTestDriverData() {
        drivers.append(DriverData (number:  1, dirverInitials: "VER", tyreData: 0, position:  1, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number:  4, dirverInitials: "NOR", tyreData: 0, position:  2, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 16, dirverInitials: "LEC", tyreData: 0, position:  3, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 81, dirverInitials: "PIA", tyreData: 0, position:  4, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 55, dirverInitials: "SAI", tyreData: 0, position:  5, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 44, dirverInitials: "HAM", tyreData: 0, position:  6, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 11, dirverInitials: "PER", tyreData: 0, position:  7, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 63, dirverInitials: "RUS", tyreData: 0, position:  8, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 14, dirverInitials: "ALO", tyreData: 0, position:  9, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 18, dirverInitials: "STR", tyreData: 0, position: 10, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 27, dirverInitials: "HUL", tyreData: 0, position: 11, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 22, dirverInitials: "TSU", tyreData: 0, position: 12, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number:  3, dirverInitials: "RIC", tyreData: 0, position: 13, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 10, dirverInitials: "GAS", tyreData: 0, position: 14, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 20, dirverInitials: "MAG", tyreData: 0, position: 15, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 31, dirverInitials: "OCO", tyreData: 0, position: 16, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 23, dirverInitials: "ALB", tyreData: 0, position: 17, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 24, dirverInitials: "ZHO", tyreData: 0, position: 18, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number:  2, dirverInitials: "SAR", tyreData: 0, position: 19, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
        drivers.append(DriverData (number: 77, dirverInitials: "BOT", tyreData: 0, position: 20, time: 0, deltaTime: 0, coordinates: CGPoint(x: 0, y: 0)))
    }
    
    private func configureTable() {
        self.view.addSubview(table);
        table.backgroundColor = .systemMint;
        table.delegate = self;
        table.dataSource = self;
        table.isScrollEnabled = false
        table.isUserInteractionEnabled = false
//        table.pinTop(to: view.safeAreaLayoutGuide.topAnchor);
        table.pinTop(to: view.topAnchor)
        table.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor);
        table.pinLeft(to: view.safeAreaLayoutGuide.leadingAnchor);
        table.pinRight(to: view.safeAreaLayoutGuide.centerXAnchor);
        table.register(DriverTableViewCell.self, forCellReuseIdentifier: DriverTableViewCell.reuseId);
    }
    
    
}

extension MainViewController: UITableViewDelegate {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: DriverTableViewCell.reuseId, for: indexPath) as! DriverTableViewCell;
        if (indexPath.row < self.drivers.count) {
            cell.configure(with: self.drivers[indexPath.row]);
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(drivers.count)
    }
}
