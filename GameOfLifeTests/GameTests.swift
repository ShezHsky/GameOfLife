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
    
    struct CellIndex: Equatable, Hashable {
        var x: Int
        var y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        var hashValue: Int {
            return x.hashValue ^ y.hashValue
        }
        
        static func ==(lhs: CellIndex, rhs: CellIndex) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
    }
    
    enum Error: Swift.Error {
        case cellIndexOutsideGameBounds
    }
    
    var area: Int
    var width: Int
    var height: Int
    private var cells = [CellIndex : Cell]()
    private var alive = false
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        area = width * height
        
        (0..<width).forEach { (x) in
            (0..<height).forEach { (y) in
                let index = Game.CellIndex(x: x, y: y)
                let cell = Cell(isAlive: false)
                cells[index] = cell
            }
        }
    }
    
    func cell(at index: Game.CellIndex) throws -> Game.Cell {
        guard let cell = cells[index] else {
            throw Game.Error.cellIndexOutsideGameBounds
        }
        
        return cell
    }
    
    mutating func toggleCell(at index: Game.CellIndex) {
        guard var cell = cells[index] else { return }
        
        cell.isAlive = !cell.isAlive
        cells[index] = cell
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
    
    func testTogglingSingleCellDoesNotAffectOtherCells() {
        let width = 2
        let height = 1
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 0, y: 0)
        game.toggleCell(at: index)
        
        XCTAssertEqual(false, (try? game.cell(at: Game.CellIndex(x: 1, y: 0)))?.isAlive)
    }
    
}
