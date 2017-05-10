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
    
    struct Cell {
        
        var isAlive = false
        
    }
    
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
    private var alive = false
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        area = width * height
    }
    
    func cell(at index: Game.CellIndex) throws -> Game.Cell {
        guard isValidCellIndex(index) else {
            throw Game.Error.cellIndexOutsideGameBounds
        }
        
        return Cell(isAlive: alive)
    }
    
    mutating func toggleCell(at index: Game.CellIndex) {
        alive = true
    }
    
    private func isValidCellIndex(_ index: Game.CellIndex) -> Bool {
        return index.x < width && index.y < height
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
    
    func testDoesNotThrowErrorWhenAccessingCellWithinGameWidth() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        
        do {
            try game.cell(at: Game.CellIndex(x: width - 1, y: height - 1))
        }
        catch {
            XCTFail()
        }
    }
    
    func testThrowsErrorWhenAccessingCellNotWithinGameHeight() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        
        XCTAssertThrowsError(try game.cell(at: Game.CellIndex(x: width - 1, y: height))) { (error) in
            XCTAssertEqual((error as? Game.Error), .cellIndexOutsideGameBounds)
        }
    }
    
    func testAllCellsAtTheStartOfTheGameShouldBeDead() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        
        (0..<width).forEach { (x) in
            (0..<height).forEach { (y) in
                let cell = try? game.cell(at: Game.CellIndex(x: x, y: y))
                XCTAssertEqual(cell?.isAlive, false)
            }
        }
    }
    
    func testTogglingCellStateAtIndexAtTheStartOfTheGameShouldBringItToLife() {
        let width = 5
        let height = 5
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        game.toggleCell(at: index)
        
        XCTAssertEqual(true, (try? game.cell(at: index))?.isAlive)
    }
    
}
