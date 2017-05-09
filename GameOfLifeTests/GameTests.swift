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
    
    var area = 100
    
    init(width: Any, height: Any) {
        
    }
    
}

class GameTests: XCTestCase {
    
    func testTheGameAreaIsAsExpected() {
        let width = 10
        let height = 10
        let game = Game(width: width, height: height)
        
        XCTAssertEqual(width * height, game.area)
    }
    
}
