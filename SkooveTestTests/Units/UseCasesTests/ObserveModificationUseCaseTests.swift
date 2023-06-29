//
//  ObserveModificationUseCaseTests.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import XCTest
@testable import SkooveTest

final class ObserveModificationUseCaseTests: XCTestCase {

    private var sut: ObserveModificationUseCaseProtocol!

    override func setUpWithError() throws {
        sut = ObserveModificationUseCase()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testPublishingModifications() async throws {
        var iterationToCheck = 5
        
        let publisher = sut.observeModifications()

        for await modification in publisher.values {
            XCTAssert(modification.lineNumber > 0)
            switch modification.type {
            case .editLine, .insertLine:
                XCTAssertNotNil(modification.newContent)
            case .deleteLine:
                XCTAssertNil(modification.newContent)
            }
            // stop receiving value after specified iterations
            iterationToCheck -= 1
            if iterationToCheck == .zero {
                break
            }
        }
    }
}
