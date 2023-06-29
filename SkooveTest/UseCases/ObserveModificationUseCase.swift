//
//  ObserveModificationUseCase.swift
//  SkooveTest
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation
import Combine

// MARK: - Abstraction

protocol ObserveModificationUseCaseProtocol {
    func observeModifications() -> AnyPublisher<ModificationEventEntity, Never>
}

// MARK: - Implementation

struct ObserveModificationUseCase {

    init() {
    }
}

extension ObserveModificationUseCase: ObserveModificationUseCaseProtocol {

    func observeModifications() -> AnyPublisher<ModificationEventEntity, Never> {
        Timer
            .publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .map { _ in
                ModificationEventEntity.random()
            }
            .eraseToAnyPublisher()
    }
}

fileprivate extension ModificationEventEntity {

    static var sampleText: String {
        """
        Someone have modified this line.
        """
    }

    static func random() -> ModificationEventEntity {
        let randomNumber = Int.random(in: 1...30)
        if randomNumber%2 == 0 {
            return ModificationEventEntity(
                type: .deleteLine,
                lineNumber: randomNumber,
                newContent: nil
            )
        } else if randomNumber%3 == 0 {
            return ModificationEventEntity(
                type: .editLine,
                lineNumber: randomNumber,
                newContent: sampleText
            )
        } else {
            return ModificationEventEntity(
                type: .insertLine,
                lineNumber: randomNumber,
                newContent: sampleText
            )
        }
    }
}
