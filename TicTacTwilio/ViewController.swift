//
//  ViewController.swift
//  TicTacTwilio
//
//  Copyright (c) 2017 Twilio, Inc. All rights reserved.
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SyncManager.sharedManager.login() { (syncClient) in
            let gameBoardName = "SyncGame"
            if let syncClient = SyncManager.sharedManager.syncClient,
                let options = TWSOpenOptions.withUniqueName(gameBoardName) {
                syncClient.openDocument(
                    with: options,
                    delegate: self,
                    completion: { (result, document) in
                        if !(result.isSuccessful()) {
                            print("TTT: error creating document: \(String(describing: result.error))")
                        } else {
                            self.document = document
                            self.updateBoardFromDocument()
                        }
                })
            }
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.boardCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    func emptyBoard() -> [[String]] {
        return [
            ["", "", ""],
            ["", "", ""],
            ["", "", ""]
        ]
    }
    
    func nextValueFor(_ currentValue: String) -> String {
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
            DispatchQueue.main.async(execute: {
                self.boardCollectionView.reloadData()
            })
        }
    }
    
    func toggleSquareAtRow(_ row: Int, column col: Int) {
        let newValue = nextValueFor(currentBoard[row][col])
        currentBoard[row][col] = newValue

        let newData = ["board": currentBoard]
        document?.setData(newData, flowId: 1, completion: { (result) in
            if !(result.isSuccessful()) {
                print("TTT: error updating the board: \(String(describing: result.error))")
            }
        })
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row / 3
        let col = indexPath.row % 3
        
        toggleSquareAtRow(row, column: col)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3*3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Square", for: indexPath)

        if let label = cell.viewWithTag(100) as! UILabel? {
            if self.document != nil {
                let row = indexPath.row / 3
                let col = indexPath.row % 3
                
                cell.backgroundColor = UIColor.white
                label.text = currentBoard[row][col]
            } else {
                cell.backgroundColor = UIColor.lightGray
                label.text = ""
            }
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            if let label = footerView.viewWithTag(200) as! UILabel? {
                if self.document != nil {
                    label.text = "Sync is initialized"
                } else {
                    label.text = "Sync is not yet initialized"
                }
            }
            return footerView
        } else {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            return headerView
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let squareSize = self.squareSize(collectionView)
        return CGSize(width: squareSize, height: squareSize)
    }
    
    func squareSize(_ collectionView: UICollectionView) -> CGFloat {
        let margin : CGFloat = 40
        let squareSize = round(min(((collectionView.bounds.width - margin) / 3),
            ((collectionView.bounds.height - margin) / 3)))
        return squareSize
    }
}

extension ViewController: TWSDocumentDelegate {
    func onDocumentResultUpdated(_ document: TWSDocument, forFlowID flowId: UInt) {
        self.updateBoardFromDocument()
    }

    func onDocument(_ document: TWSDocument, remoteUpdated data: [String : Any]) {
        self.updateBoardFromDocument()
    }
}
