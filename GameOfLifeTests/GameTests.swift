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
    
    struct Cell: CustomStringConvertible, CustomDebugStringConvertible {
        
        var isAlive = false
        var index: CellIndex

        mutating func toggleLiveState() {
            isAlive = !isAlive
        }

        var description: String {
            let liveState = isAlive ? "Alive" : "Dead"
            return "\(liveState): \(index)"
        }

        var debugDescription: String {
            return description
        }
        
    }
    
    struct CellIndex: Equatable, Hashable, CustomStringConvertible, CustomDebugStringConvertible {
        var x: Int
        var y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
        
        var hashValue: Int {
            return x.hashValue ^ y.hashValue
        }

        var description: String {
            return "(x: \(x), y: \(y))"
        }

        var debugDescription: String {
            return description
        }
        
        static func ==(lhs: CellIndex, rhs: CellIndex) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }
        
    }
    
    var area: Int
    var width: Int
    var height: Int
    private var cells = [Cell]()
    private var alive = false
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        
        area = width * height
        
        (0..<width).forEach { (x) in
            (0..<height).forEach { (y) in
                let index = Game.CellIndex(x: x, y: y)
                let cell = Cell(isAlive: false, index: index)
                cells.append(cell)
            }
        }
    }
    
    func cell(at index: Game.CellIndex) -> Game.Cell {
        precondition(isValidIndex(index))
        return cells.first(where: { $0.index == index })!
    }
    
    mutating func toggleCell(at index: Game.CellIndex) {
        precondition(isValidIndex(index))

        let index = cells.index(where: { $0.index == index })!
        var cell = cells[index]
        cell.toggleLiveState()
        cells[index] = cell
    }

    mutating func tick() {
        var cells = self.cells
        for (idx, var cell) in cells.enumerated() {
            let neighbours = neighbouringIndiciesFor(cell).map(cell(at:))
            cell.isAlive = neighbours.filter({ $0.isAlive }).count > 1

            cells[idx] = cell
        }

        self.cells = cells
    }

    private func neighbouringIndiciesFor(_ cell: Game.Cell) -> [Game.CellIndex] {
        let offsets = [(-1, -1), (0, -1), (1, -1),
                       (-1, 0), /* Cell */ (1, 0),
                       (-1, 1), (0, 1), (1, 1)]
        return offsets.map { (offset) in
            var index = cell.index
            index.x = max(0, min(width - 1, index.x + offset.0))
            index.y = max(0, min(height - 1, index.y + offset.1))

            return index
        }
    }

    private func isValidIndex(_ index: Game.CellIndex) -> Bool {
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
    
    func testAllCellsAtTheStartOfTheGameShouldBeDead() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        
        (0..<width).forEach { (x) in
            (0..<height).forEach { (y) in
                let cell = game.cell(at: Game.CellIndex(x: x, y: y))
                XCTAssertFalse(cell.isAlive)
            }
        }
    }
    
    func testTogglingCellStateAtIndexAtTheStartOfTheGameShouldBringItToLife() {
        let width = 5
        let height = 5
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        game.toggleCell(at: index)
        
        XCTAssertTrue(game.cell(at: index).isAlive)
    }
    
    func testTogglingSingleCellDoesNotAffectOtherCells() {
        let width = 2
        let height = 1
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 0, y: 0)
        game.toggleCell(at: index)
        
        XCTAssertFalse(game.cell(at: Game.CellIndex(x: 1, y: 0)).isAlive)
    }
    
    func testAccessingCellShouldProvideItsIndex() {
        let width = 5
        let height = 5
        let game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        let cell = game.cell(at: index)
        
        XCTAssertEqual(index, cell.index)
    }

    func testCellThatIsAliveWithoutNeighboursShouldDieWhenProceedingToNextGeneration() {
        let width = 5
        let height = 5
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        game.toggleCell(at: index)
        game.tick()

        XCTAssertFalse(game.cell(at: index).isAlive)
    }

    func testCellThatIsAliveWithOnlyOneNeighbourShouldDieWhenProceedingToNextGeneration() {
        let width = 5
        let height = 5
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        game.toggleCell(at: index)
        game.toggleCell(at: Game.CellIndex(x: 4, y: 3))
        game.tick()

        XCTAssertFalse(game.cell(at: index).isAlive)
    }

    func testCellThatIsAliveWithTwoNeighboursShouldLiveWhenProceedingToNextGeneration() {
        let width = 5
        let height = 5
        var game = Game(width: width, height: height)
        let index = Game.CellIndex(x: 3, y: 3)
        game.toggleCell(at: index)
        game.toggleCell(at: Game.CellIndex(x: 4, y: 3))
        game.toggleCell(at: Game.CellIndex(x: 3, y: 4))
        game.tick()

        XCTAssertTrue(game.cell(at: index).isAlive)
    }
    
}
