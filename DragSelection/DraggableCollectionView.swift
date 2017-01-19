//
//  DraggableCollectionView.swift
//  DragSelection
//
//  Created by Maika Yamada on 2016/12/18.
//  Copyright © 2016年 Yamada. All rights reserved.
//

import UIKit

class DraggableCollectionView : UICollectionView {
    
    var touchesBeganPoint: CGPoint?
    var touchesMovedPoint: CGPoint?
    
    /// 選択範囲に含んでいるセルのインデックス情報
    var parentViewController: ViewController!
    lazy var previewRangeSelectedIndexPathes: Array<IndexPath> = {
        return Array<IndexPath>()
    }()

// MARK: override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.touchesBeganPoint = touches.first?.location(in: self)
        
        // タップした座標のセルの選択ステータスを変更する
        self.parentViewController.selectTouchBeganCell(beganPoint: self.touchesBeganPoint)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        // タッチしたまま指の移動を検知した場合、スクロールを不可にする
        // ただし、現在の座標が画面最上部・最下部の座標の場合はスクロール可能にする
        if let locationPoint = touches.first?.location(in: self) {
            self.touchesMovedPoint = touches.first?.location(in: self)
            if (locationPoint.y - self.contentOffset.y) > 10 && locationPoint.y < self.bounds.size.height - 10 {
                self.isScrollEnabled = false
            }
        } else {
           self.isScrollEnabled = true
        }
        
        // タップした範囲内のセルの選択ステータスを変更する
        self.parentViewController.selectTouchRangeCells(beganPoint: self.touchesBeganPoint, movedPoint: self.touchesMovedPoint)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.touchesBeganPoint = nil
        self.touchesMovedPoint = nil
        self.previewRangeSelectedIndexPathes.removeAll()
        
        // タッチイベントが終了したので、スクロールを可能に戻す
        self.isScrollEnabled = true
        
        // 範囲選択表示を削除する
        self.parentViewController.selectTouchEndedCells()
    }
}
