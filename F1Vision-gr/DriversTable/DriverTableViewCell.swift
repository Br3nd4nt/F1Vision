//
//  DriverTableViewCell.swift
//  F1Vision
//
//  Created by br3nd4nt on 10.06.2024.
//

import UIKit

public final class DriverTableViewCell : UITableViewCell {
    public static let reuseId: String = "DriverTableViewCell";
    private var wrap: UIView = UIView();
    
    private let positionNumberLabel: UILabel = UILabel();
    private let driversInitialsLabel: UILabel = UILabel();
    private let driverPersonalNumber: UILabel = UILabel();
    private let driverCoordinates: UILabel = UILabel();
    
    
    private func configureUI() {
        self.addSubview(wrap);
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        configureUI();
    }
    
    
    @available(*, unavailable)
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
    
    func configure(with driver: DriverData) {
        self.addSubview(wrap);
        wrap.pin(to: self);
        
        wrap.addSubview(positionNumberLabel);
        positionNumberLabel.text = driver.getPosition()
        positionNumberLabel.textColor = .white;
        positionNumberLabel.pinTop(to: wrap.topAnchor);
        positionNumberLabel.pinBottom(to: wrap.bottomAnchor);
        positionNumberLabel.pinLeft(to: wrap.leadingAnchor, 10);
        
        wrap.addSubview(driversInitialsLabel);
        driversInitialsLabel.text = driver.dirverInitials;
        driversInitialsLabel.textColor = .white;
        driversInitialsLabel.pinTop(to: wrap.topAnchor);
        driversInitialsLabel.pinBottom(to: wrap.bottomAnchor);
        driversInitialsLabel.pinLeft(to: positionNumberLabel.trailingAnchor)
        
        wrap.addSubview(driverPersonalNumber)
        driverPersonalNumber.text = "\t\(driver.number)\t"
        driverPersonalNumber.textColor = .white
        driverPersonalNumber.pinTop(to: wrap.topAnchor)
        driverPersonalNumber.pinBottom(to: wrap.bottomAnchor)
        driverPersonalNumber.pinLeft(to: driversInitialsLabel.trailingAnchor)
        
        wrap.addSubview(driverCoordinates)
        driverCoordinates.text = "\tX: \(driver.coordinates.x)\tY:\(driver.coordinates.y)"
        driverCoordinates.textColor = .white
        driverCoordinates.pinTop(to: wrap.topAnchor)
        driverCoordinates.pinBottom(to: wrap.bottomAnchor)
        driverCoordinates.pinLeft(to: driverPersonalNumber.trailingAnchor)
    }
}
