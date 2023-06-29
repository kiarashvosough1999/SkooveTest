//
//  ContentViewModelIntegrationTests.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import XCTest
@testable import SkooveTest

final class ContentViewModelIntegrationTests: XCTestCase {

    private var sut: ContentViewModel!
    private var sendModificationEventsRepository: SendModificationEventsRepositoryStub!
    private var fetchUserIDRepository: FetchUserIDRepositoryStub!

    override func setUpWithError() throws {
        sendModificationEventsRepository = SendModificationEventsRepositoryStub()
        fetchUserIDRepository = FetchUserIDRepositoryStub()

        let observeModificationUseCase = ObserveModificationUseCase()
        let sendModidifcationEventsUseCase = SendModidifcationEventsUseCase(
            sendModificationEventsRepository: sendModificationEventsRepository,
            fetchUserIDRepository: fetchUserIDRepository
        )
        sut = ContentViewModel(
            observeModificationUseCase: observeModificationUseCase,
            sendModidifcationEventsUseCase: sendModidifcationEventsUseCase
        )
    }
    
    override func tearDownWithError() throws {
        sut = nil
        sendModificationEventsRepository = nil
        fetchUserIDRepository = nil
    }

    func testStartCollaborationReceiveEvents() async throws {
        let id = 1
        fetchUserIDRepository.id = id

        var counter = 5
        
        sut.startCollaboration()
        
        XCTAssertEqual(sut.contents.count, .zero)

        var receivedEvents: [Int: String] = [:]
        for await event in sut.$contents.values {
            receivedEvents = event
            counter -= 1
            if counter == .zero { break }
        }
        XCTAssertNotEqual(sut.contents.count, .zero)

        receivedEvents.forEach { event in
            XCTAssert(event.key > 0)
            XCTAssert(event.value.isEmpty == false)
        }
    }
    
    func testStartCollaborationSendEventsSuccessful() async throws {
        let userId = 1
        let line = 10
        let content = "new content"
        
        fetchUserIDRepository.id = userId
        await sut.insertedNewLine(at: line, content: content)
        
        XCTAssertNotNil(sendModificationEventsRepository.modelReceived)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.type, .insertLine)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.lineNumber, line)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.newContent, content)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.userId, userId)
    }
    
    func testStartCollaborationSendEventsWithInvalidLineNumber() async throws {
        let userId = 1
        let line = -10
        let content = "new content"

        fetchUserIDRepository.id = userId
        
        await sut.insertedNewLine(at: line, content: content)
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, SendModificationEventsError.lineNumberMustBeGreaterThanZero.rawValue)
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }
    
    func testStartCollaborationSendEventsWithEmptyContent() async throws {
        let userId = 1
        let line = 10
        let content: String = ""

        fetchUserIDRepository.id = userId
        
        await sut.insertedNewLine(at: line, content: content)
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, SendModificationEventsError.insertLineMustContaintNewContent.rawValue)
        XCTAssertNil(sendModificationEventsRepository.modelReceived)
    }

    func testStartCollaborationSendDeleteEvents() async throws {
        let userId = 1
        let line = 10

        fetchUserIDRepository.id = userId
        
        await sut.deletedLine(at: line)
        
        XCTAssertNotNil(sendModificationEventsRepository.modelReceived)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.type, .deleteLine)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.lineNumber, line)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.event.newContent, nil)
        XCTAssertEqual(sendModificationEventsRepository.modelReceived?.userId, userId)
    }
}
