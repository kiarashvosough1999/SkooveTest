//
//  ContentViewModel.swift
//  SkooveTest
//
//  Created by Kiarash Vosough on 6/29/23.
//

import Foundation
import Combine

final class ContentViewModel: ObservableObject {
    
    // MARK: - Properties

    @Published var errorMessage: String?
    @Published var contents: [Int: String] = [:]

    private var cancelablles: Set<AnyCancellable>

    // MARK: - Dependencies

    private let observeModificationUseCase: ObserveModificationUseCaseProtocol
    private let sendModidifcationEventsUseCase: SendModificationEventsUseCaseProtocol

    init(
        observeModificationUseCase: ObserveModificationUseCaseProtocol,
        sendModidifcationEventsUseCase: SendModificationEventsUseCaseProtocol
    ) {
        self.observeModificationUseCase = observeModificationUseCase
        self.sendModidifcationEventsUseCase = sendModidifcationEventsUseCase
        self.cancelablles = Set<AnyCancellable>()
    }

    func startCollaboration() {
        observeModificationUseCase
            .observeModifications()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entity in
                guard let self else { return }
                self.applyEvents(entity)
            }
            .store(in: &cancelablles)
    }
    
    private func applyEvents(_ event:  ModificationEventEntity) {
        switch event.type {
        case .deleteLine:
            contents.removeValue(forKey: event.lineNumber)
        case .editLine, .insertLine:
            guard let newContent = event.newContent else { return }
            contents.updateValue(newContent, forKey: event.lineNumber)
        }
    }

    func insertedNewLine(at index: Int, content: String) async {
        let entity = ModificationEventEntity(
            type: .insertLine,
            lineNumber: index,
            newContent: content
        )
        do {
            try await sendModidifcationEventsUseCase.modify(with: entity)
        } catch let error as CustomStringConvertible {
            errorMessage = error.description
        }
    }
    
    func editedLine(at index: Int, content: String) async {
        let entity = ModificationEventEntity(
            type: .editLine,
            lineNumber: index,
            newContent: content
        )
        do {
            try await sendModidifcationEventsUseCase.modify(with: entity)
        } catch let error as CustomStringConvertible {
            errorMessage = error.description
        }
    }

    func deletedLine(at index: Int) async {
        let entity = ModificationEventEntity(
            type: .deleteLine,
            lineNumber: index,
            newContent: nil
        )
        do {
            try await sendModidifcationEventsUseCase.modify(with: entity)
        } catch let error as CustomStringConvertible {
            errorMessage = error.description
        }
    }
}
