//
//  ObserveModificationUseCaseStub.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Combine
@testable import SkooveTest

struct ObserveModificationUseCaseStub {
    let subject: PassthroughSubject<ModificationEventEntity, Never>

    init() {
        self.subject = PassthroughSubject<ModificationEventEntity, Never>()
    }
}

extension ObserveModificationUseCaseStub: ObserveModificationUseCaseProtocol {

    func observeModifications() -> AnyPublisher<ModificationEventEntity, Never> {
        subject.eraseToAnyPublisher()
    }
}
