//
//  Cell.swift
//  DragSelection
//
//  Created by Maika Yamada on 2016/12/18.
//  Copyright © 2016年 Yamada. All rights reserved.
//

import UIKit

class Cell : UICollectionViewCell {
    
    /// 背景色表示用ビュー
    @IBOutlet weak var _colorView: UIImageView!
    
    /// セルの選択ステータス
    var selectedCell : Bool = false {
        didSet {
            // 選択状態の場合、背景色切り替え
            if self.selectedCell {
                self._colorView.backgroundColor = UIColor.red
            } else {
                self._colorView.backgroundColor = UIColor.cyan
            }
        }
    }
}
