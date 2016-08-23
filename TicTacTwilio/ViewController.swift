//
//  ViewController.swift
//  TicTacTwilio
//
//  Copyright © 2016 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioSyncClient

class ViewController: UIViewController {
    @IBOutlet weak var boardCollectionView: UICollectionView!
    var document : TWSDocument?
    var currentBoard:[[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.boardCollectionView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8)
        currentBoard = emptyBoard()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SyncManager.sharedManager.login()

        let gameBoardName = "sync.game"
        if let syncClient = SyncManager.sharedManager.syncClient,
            let options = TWSOptions.withUniqueName(gameBoardName) {
            syncClient.openDocumentWithOptions(
                options,
                delegate: self,
                completion: { (result, document) in
                    if !result.isSuccessful() {
                        print("TTT: error creating document: \(result.error)")
                    } else {
                        self.document = document
                        self.updateBoardFromDocument()
                    }
            })
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.boardCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func emptyBoard() -> [[String]] {
        return [
            ["", "", ""],
            ["", "", ""],
            ["", "", ""]
        ]
    }
    
    func nextValueFor(currentValue: String) -> String {
        var newValue = ""
        if currentValue == "" {
            newValue = "X"
        } else if currentValue == "X" {
            newValue = "O"
        } else {
            newValue = ""
        }
        return newValue
    }
    
    func updateBoardFromDocument() {
        if let document = document {
            let data = document.getData()
            if let board = data["board"] as? [[String]] {
                self.currentBoard = board
            } else {
                self.currentBoard = emptyBoard()
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.boardCollectionView.reloadData()
            })
        }
    }
    
    func toggleSquareAtRow(row: Int, column col: Int) {
        let newValue = nextValueFor(currentBoard[row][col])
        currentBoard[row][col] = newValue

        let newData = ["board": currentBoard]
        document?.setData(newData, flowId: 1, completion: { (result) in
            if !result.isSuccessful() {
                print("TTT: error updating the board: \(result.error)")
            }
        })
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row / 3
        let col = indexPath.row % 3
        
        toggleSquareAtRow(row, column: col)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3*3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Square", forIndexPath: indexPath)
        let label = cell.viewWithTag(100) as! UILabel
        
        if self.document != nil {
            let row = indexPath.row / 3
            let col = indexPath.row % 3
            
            cell.backgroundColor = UIColor.whiteColor()
            label.text = currentBoard[row][col]
        } else {
            cell.backgroundColor = UIColor.lightGrayColor()
            label.text = ""
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath)
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath)
            let label = footerView.viewWithTag(200) as! UILabel
            if self.document != nil {
                label.text = "Sync is initialized"
            } else {
                label.text = "Sync is not yet initialized"
            }
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let squareSize = self.squareSize(collectionView)
        return CGSize(width: squareSize, height: squareSize)
    }
    
    func squareSize(collectionView: UICollectionView) -> CGFloat {
        let margin : CGFloat = 40
        let squareSize = round(min(((collectionView.bounds.width - margin) / 3),
            ((collectionView.bounds.height - margin) / 3)))
        return squareSize
    }
}

extension ViewController: TWSDocumentDelegate {
    func onDocument(document: TWSDocument, resultDataUpdated data: [String : AnyObject], forFlowID flowId: UInt) {
        self.updateBoardFromDocument()
    }

    func onDocument(document: TWSDocument, remoteUpdated data: [String : AnyObject]) {
        self.updateBoardFromDocument()
    }
    
    func onDocument(document: TWSDocument, remoteErrorOccurred error: TWSError) {
        print("TTT: document: \(document) error: \(error)")
    }
}
