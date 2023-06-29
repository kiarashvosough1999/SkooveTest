//
//  ContentViewModelTests.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import XCTest
@testable import SkooveTest

final class ContentViewModelTests: XCTestCase {

    private var sut: ContentViewModel!

    private var observeModificationUseCase: ObserveModificationUseCaseStub!
    private var sendModidifcationEventsUseCase: SendModidifcationEventsUseCaseStub!
    
    override func setUpWithError() throws {
        observeModificationUseCase = ObserveModificationUseCaseStub()
        sendModidifcationEventsUseCase = SendModidifcationEventsUseCaseStub()
        sut = ContentViewModel(
            observeModificationUseCase: observeModificationUseCase,
            sendModidifcationEventsUseCase: sendModidifcationEventsUseCase
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        observeModificationUseCase = nil
        sendModidifcationEventsUseCase = nil
    }

    func testStartCollaboration() async throws {
        
        let events: [ModificationEventEntity] = [
            ModificationEventEntity(type: .deleteLine, lineNumber: 5, newContent: nil),
            ModificationEventEntity(type: .editLine, lineNumber: 3, newContent: "Edited Content"),
            ModificationEventEntity(type: .insertLine, lineNumber: 2, newContent: "New Content"),
        ]
        
        sut.startCollaboration()
        
        XCTAssertEqual(sut.contents.count, .zero)
        
        events.forEach { observeModificationUseCase.subject.send($0) }

        var counter = 0
        for await _ in sut.$contents.values {
            counter += 1
            if counter == events.count { break }
        }
        XCTAssertNotEqual(sut.contents.count, .zero)
        XCTAssertEqual(sut.contents.count, events.count - 1)

        XCTAssertEqual(sut.contents[5], nil)
        XCTAssertEqual(sut.contents[3], events[1].newContent)
        XCTAssertEqual(sut.contents[2], events[2].newContent)
    }

    func testInsertSuccessful() async throws {
        let line = 2
        let content = "New Content"
        let event = ModificationEventEntity(type: .insertLine, lineNumber: line, newContent: content)
        
        XCTAssertEqual(sut.contents.count, .zero)
        
        await sut.insertedNewLine(at: line, content: content)
        
        XCTAssertNotNil(sendModidifcationEventsUseCase.modelReceived)
        XCTAssertEqual(event, sendModidifcationEventsUseCase.modelReceived)
    }

    struct TestError: Error, CustomStringConvertible {
        var description: String
        
        init(description: String) {
            self.description = description
        }
    }
    
    func testInsertUnSuccessful() async throws {
        let line = 2
        let content = "New Content"
        let errorDescription = "Smthing Wrong"
        let error = TestError(description: errorDescription)
        
        XCTAssertEqual(sut.contents.count, .zero)
        
        sendModidifcationEventsUseCase.errorToThrow = error
        await sut.insertedNewLine(at: line, content: content)
        
        XCTAssertNil(sendModidifcationEventsUseCase.modelReceived)
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, errorDescription)
    }
}
