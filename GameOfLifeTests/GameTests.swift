//
//  GameTests.swift
//  GameOfLife
//
//  Created by Thomas Sherwood on 09/05/2017.
//  Copyright © 2017 Shez. All rights reserved.
//

@testable import GameOfLife
import XCTest

struct Game {
    
    struct CellIndex {
        var x: Int
        var y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    enum Error: Swift.Error {
        case cellIndexOutsideGameBounds
    }
    
    var area: Int
    var width: Int
    var height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        area = width * height
    }
    
    func cell(at index: Game.CellIndex) throws {
        throw Game.Error.cellIndexOutsideGameBounds
    }
    
}

class GameTests: XCTestCase {
    
    func testTheGameAreaIsAsExpected() {
        let width = Int(arc4random_uniform(100))
        let height = Int(arc4random_uniform(100))
        let game = Game(width: width, height: height)
        
        XCTAssertEqual(width * height, game.area)
    }
    
    func testTheGameWidthIsAsExpected() {
        let width = Int(arc4random_uniform(100))
        let game = Game(width: width, height: 0)
        
        XCTAssertEqual(width, game.width)
    }
    
    func testTheGameHeightIsAsExpected() {
        let height = Int(arc4random_uniform(100))
        let game = Game(width: 0, height: height)
        
        XCTAssertEqual(height, game.height)
    }
    
    func testThrowsErrorWhenAccessingCellNotWithinGameWidth() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        
        XCTAssertThrowsError(try game.cell(at: Game.CellIndex(x: width, y: height - 1))) { (error) in
            XCTAssertEqual((error as? Game.Error), .cellIndexOutsideGameBounds)
        }
    }
    
}
