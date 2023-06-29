//
//  SendModificationEventsUseCaseProtocol.swift
//  SkooveTest
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation

enum SendModificationEventsError: String, Error, CustomStringConvertible {
    case editLineMustContaintNewContent
    case insertLineMustContaintNewContent
    case deleteLineMustNotContaintNewContent
    case lineNumberMustBeGreaterThanZero
    
    var description: String { rawValue }
}

// MARK: - Repository

protocol SendModificationEventsRepositoryProtocol {
    func modify(with model: UserModificationEventEntity) async throws
}

protocol FetchUserIDRepositoryProtocol {
    func fetchUserId() async throws -> Int
}
// MARK: - Abstraction

protocol SendModificationEventsUseCaseProtocol {
    func modify(with model: ModificationEventEntity) async throws
}

// MARK: - Implementation

final class SendModidifcationEventsUseCase {
    private let sendModificationEventsRepository: SendModificationEventsRepositoryProtocol
    private let fetchUserIDRepository: FetchUserIDRepositoryProtocol
    
    init(
        sendModificationEventsRepository: SendModificationEventsRepositoryProtocol,
        fetchUserIDRepository: FetchUserIDRepositoryProtocol
    ) {
        self.sendModificationEventsRepository = sendModificationEventsRepository
        self.fetchUserIDRepository = fetchUserIDRepository
    }
}

extension SendModidifcationEventsUseCase: SendModificationEventsUseCaseProtocol {
    
    func modify(with model: ModificationEventEntity) async throws {
        guard model.lineNumber > .zero else {
            throw SendModificationEventsError.lineNumberMustBeGreaterThanZero
        }

        switch model.type {
        case .editLine:
            if model.newContent == nil || model.newContent?.isEmpty == true {
                throw SendModificationEventsError.editLineMustContaintNewContent
            }
        case .insertLine:
            if model.newContent == nil || model.newContent?.isEmpty == true {
                throw SendModificationEventsError.insertLineMustContaintNewContent
            }
        case .deleteLine:
            if model.newContent != nil {
                throw SendModificationEventsError.deleteLineMustNotContaintNewContent
            }
        }

        let id = try await fetchUserIDRepository.fetchUserId()
        let modification = UserModificationEventEntity(userId: id, event: model)
        try await sendModificationEventsRepository.modify(with: modification)
    }
}
