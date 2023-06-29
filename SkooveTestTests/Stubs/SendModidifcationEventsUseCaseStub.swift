//
//  SendModidifcationEventsUseCaseStub.swift
//  SkooveTestTests
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation
@testable import SkooveTest

final class SendModidifcationEventsUseCaseStub {
    var modelReceived: ModificationEventEntity?
    var errorToThrow: Error?
}

extension SendModidifcationEventsUseCaseStub: SendModificationEventsUseCaseProtocol {

    func modify(with model: ModificationEventEntity) async throws {
        if let errorToThrow { throw errorToThrow }
        modelReceived = model
    }
}
