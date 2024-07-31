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
    
    private var positionNumberLabel: UILabel = UILabel();
    private var driversInitialsLabel: UILabel = UILabel();
    
    
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
    }
}
