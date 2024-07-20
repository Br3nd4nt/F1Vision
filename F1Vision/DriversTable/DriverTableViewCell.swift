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
    
    private var label: UILabel = UILabel();
    
    private func configureUI() {
        self.addSubview(wrap)
        

    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    
    @available(*, unavailable)
    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with driver: DriverData) {
//        self.titleView.text = film.title
//        self.overviewView.text = film.overview
//        self.posterView.image = film.poster
        wrap.backgroundColor = .systemPink;
        wrap.addSubview(label);
        wrap.pin(to: self);
        
        label.text = "cum";
        label.pinCenter(to: wrap);
    }
}
