//
//  SendModificationEventsUseCaseTests.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import XCTest
@testable import SkooveTest

final class SendModificationEventsUseCaseTests: XCTestCase {

    private var sut: SendModificationEventsUseCaseProtocol!
    private var sendModificationEventsRepository: SendModificationEventsRepositoryStub!
    private var fetchUserIDRepository: FetchUserIDRepositoryStub!
    
    override func setUpWithError() throws {
        sendModificationEventsRepository = SendModificationEventsRepositoryStub()
        fetchUserIDRepository = FetchUserIDRepositoryStub()

        sut =  SendModidifcationEventsUseCase(
            sendModificationEventsRepository: sendModificationEventsRepository,
            fetchUserIDRepository: fetchUserIDRepository
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        sendModificationEventsRepository = nil
        fetchUserIDRepository = nil
    }

    func testZeroLineNumber() async throws {
        let lineNumber = 0
        let event = ModificationEventEntity(
            type: .deleteLine,
            lineNumber: lineNumber,
            newContent: "some text"
        )
        
        await XCTAssertThrowsError(try await sut.modify(with: event))
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }

    func testNegativeLineNumber() async throws {
        let lineNumber = -2
        let event = ModificationEventEntity(
            type: .deleteLine,
            lineNumber: lineNumber,
            newContent: "some text"
        )
        
        await XCTAssertThrowsError(try await sut.modify(with: event))
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }

    func testNonZeroLineNumber() async throws {
        let lineNumber = 2
        let newContent = "some text"
        let event = ModificationEventEntity(
            type: .insertLine,
            lineNumber: lineNumber,
            newContent: newContent
        )

        await XCTAssertNoThrowsError(try await sut.modify(with: event))
        XCTAssertNotNil(sendModificationEventsRepository.modelReceived)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.lineNumber, lineNumber)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.newContent, newContent)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.type, .insertLine)
    }

    func testEditLineNewContentNil() async throws {
        let lineNumber = 2
        let event = ModificationEventEntity(
            type: .editLine,
            lineNumber: lineNumber,
            newContent: nil
        )

        await XCTAssertThrowsError(try await sut.modify(with: event))
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }

    func testEditLineNewContentEmpty() async throws {
        let lineNumber = 2
        let event = ModificationEventEntity(
            type: .editLine,
            lineNumber: lineNumber,
            newContent: ""
        )

        await XCTAssertThrowsError(try await sut.modify(with: event))
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }
    
    func testEditLineWithNewContent() async throws {
        let lineNumber = 2
        let newContent = "Somthing"
        let event = ModificationEventEntity(
            type: .editLine,
            lineNumber: lineNumber,
            newContent: newContent
        )

        await XCTAssertNoThrowsError(try await sut.modify(with: event))
        XCTAssertNotNil(sendModificationEventsRepository.modelReceived)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.lineNumber, lineNumber)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.newContent, newContent)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.type, .editLine)
    }
}
