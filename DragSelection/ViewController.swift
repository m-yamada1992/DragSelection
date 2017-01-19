//
//  ViewController.swift
//  DragSelection
//
//  Created by Maika Yamada on 2016/09/07.
//  Copyright © 2016年 Yamada. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    /// コレクションビュー
    @IBOutlet weak var _collectionView: DraggableCollectionView!
    
    /// 選択済セルのインデックス
    lazy var selectedIndices: Array<Int> = {
        return Array<Int>()
    }()
    
    /// セル1個当たりの横幅(セル自体は正方形)
    var cellWidth: CGFloat!
    
    /// 選択範囲を表す矩形
    var selectedRangeRect: UIView?
    
// MARK: override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._collectionView.parentViewController = self
        self._collectionView.delaysContentTouches = false
        
        self.cellWidth = self.view.frame.size.width * 0.25
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // TODO: 範囲選択のタッチイベントとスクロールしたいタッチイベントの分別
        // タッチイベントを検知した場合、スクロールを不可にする
        self._collectionView.isScrollEnabled = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // TODO: 範囲選択のタッチイベントとスクロールしたいタッチイベントの分別
        // タッチイベントが終了したので、スクロールを可能に戻す
        self._collectionView.isScrollEnabled = true
    }
    
// MARK: Self
    /**
     選択を開始したセルの選択ステータスを変更する
     - paremeter beganPoint: 選択を開始した座標
     */
    func selectTouchBeganCell(beganPoint: CGPoint?) {
        if let indexPath = self._collectionView.indexPathForItem(at: beganPoint!) {
            self._collectionView.previewRangeSelectedIndexPathes.append(indexPath)
            self.selectedCell(self._collectionView, didSelectItemAt: indexPath)
        }
    }
    
    /**
     移動した座標間に含まれるセルの選択ステータスを変更する
     - paremeter beganPoint: 選択を開始した座標
     - parameter movedPoint: 選択範囲の終端の座標
     */
    func selectTouchRangeCells(beganPoint: CGPoint?, movedPoint: CGPoint?) {
        // 座標内に含まれるセルを取得する
        if beganPoint != nil && movedPoint != nil {
            if self._collectionView.indexPathForItem(at: movedPoint!) != nil {
                // 4方向の座標を取得
                let topPoint = min(beganPoint!.y, movedPoint!.y)
                let underPoint = max(beganPoint!.y, movedPoint!.y)
                let leftPoint = min(beganPoint!.x, movedPoint!.x)
                let rightPoint = max(beganPoint!.x, movedPoint!.x)
                // ナビゲーションバーの高さも鑑みて矩形を生成
                let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
                let rect = CGRect(
                    x: leftPoint,
                    y: topPoint + navigationBarHeight,
                    width: rightPoint - leftPoint,
                    height: underPoint - topPoint + navigationBarHeight
                )
                // 現在矩形を表示中の場合は表示を削除し、描画
                self.selectedRangeRect?.removeFromSuperview()
                self.selectedRangeRect = UIView(frame: rect)
                self.selectedRangeRect?.backgroundColor = UIColor.purple
                self.selectedRangeRect?.alpha = 0.5
                self.view.addSubview(self.selectedRangeRect!)
                
                // 1セル辺りのサイズを取得して等間隔に座標指定して、タッチ開始〜タッチ中終端の座標内に含まれるセルの選択ステータスを変更する
                // 選択範囲内のセルのインデックスをそれぞれ取得する
                var selectedIndexPathes = Array<IndexPath>()
                let previewSelectedIndexPathes = self._collectionView.previewRangeSelectedIndexPathes
                // 行
                var y = topPoint
                while y <= underPoint {
                    // 列
                    var x = leftPoint
                    while x <= rightPoint {
                        let selectedIndexPath = self._collectionView.indexPathForItem(at: CGPoint(x: x, y: y))
                        // 前回選択ステータスを切り替えたばかりのセルでない場合、選択イベントを呼び出す
                        var nonSelect = true
                        if previewSelectedIndexPathes.count > 0 {
                            for selected in previewSelectedIndexPathes {
                                if selected == selectedIndexPath {
                                    nonSelect = false
                                    break
                                }
                            }
                        }
                        if nonSelect && selectedIndexPath != nil {
                            self.selectedCell(self._collectionView, didSelectItemAt: selectedIndexPath!)
                        }
                        selectedIndexPathes.append(selectedIndexPath!)
                        // 次の列のセルへ
                        x += self.cellWidth
                    }
                    // 次の行のセルへ
                    y += self.cellWidth
                }
                // 前回の範囲選択で選択され、今回分で範囲外になったセルのステータスを変更する
                for previewSelected in previewSelectedIndexPathes {
                    if !selectedIndexPathes.contains(previewSelected) {
                        self.selectedCell(self._collectionView, didSelectItemAt: previewSelected)
                    }
                }
                // 今回選択範囲に含むセルの情報を保持する
                self._collectionView.previewRangeSelectedIndexPathes = selectedIndexPathes
            }
        }
    }
    
    /**
     セルの選択が終了時の処理
     */
    func selectTouchEndedCells() {
        // 範囲表示をしている場合は、表示を削除
        self.selectedRangeRect?.removeFromSuperview()
        self.selectedRangeRect = nil
    }
    
    /**
     セル選択時の処理
     
     - parameter collectionView
     - parameter didSelectItemAtIndexPath indexPath
     */
    func selectedCell(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            let customCell = cell as! Cell
            customCell.selectedCell = !customCell.selectedCell
            // 選択ステータスを切り替える
            if customCell.selectedCell {
                // 未選択→選択
                // 選択中インデックス情報にこのセルのインデックス情報を追加
                self.selectedIndices.append(indexPath.row)
            } else {
                // 選択→未選択
                // 選択中インデックス情報からこのセルのインデックス情報を削除
                for (index, selected) in self.selectedIndices.enumerated() {
                    if selected == indexPath.row {
                        self.selectedIndices.remove(at: index)
                        break
                    }
                }
            }
        }

    }
}

// MARK: CollectionViewDelegate

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /**
     (delegate)セルの表示数を設定
     
     - parameter collectionView
     - parameter numberOfItemsInSection section
     
     - returns Int: セルの表示数
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 今回は適当に
        return 100
    }
    
    /**
     (delegate)セルサイズの設定
     
     - parameter collectionView
     - parameter layout
     - parameter sizeForItemAtIndexPath indexPath
     
     - returns CGSize: セルの表示サイズオブジェクト
     */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        // 4列表示する
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    /**
     (delegate)セル描画時の処理
     
     - parameter collectionView
     - parameter cellForItemAtIndexPath indexPath
     
     - returns UICollectionViewCell: 表示するセル
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! Cell
        // 選択済みセルのインデックス情報にこのセルのインデックス情報が含まれている場合、選択状態にする
        for selected in self.selectedIndices {
            if selected == indexPath.row {
                cell.selectedCell = true
                break
            } else {
                cell.selectedCell = false
            }
        }
        return cell
    }
}
