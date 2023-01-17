//
//  PokemonDetailsViewModelTests.swift
//  
//
//  Created by Ben on 17/01/2023.
//

import XCTest
import SharedTestHelpers
import Combine
@testable import PokemonDetailsFeature
import PokemonDomain

@MainActor final class PokemonDetailsViewModelTests: XCTestCase {

    func test_initialState_isLoading() {
        let sut = makeSut()
        expect(sut: sut, toHaveState: .loading)
    }

    func test_performLoadData_callsRepositoryFetchWithPokemonId() async {
        let pokemonId = 94853
        let repository = MockPokemonDetailsRepository()
        let taskManager = TaskManager()

        let sut = makeSut(pokemonId: pokemonId,
                          repository: repository,
                          createTask: taskManager.createTask(_:))

        sut.perform(.loadData)

        await taskManager.awaitCurrentTasks()

        XCTAssertEqual(repository.fetchPokemonDetailsParameters.count, 1)
        XCTAssertEqual(repository.fetchPokemonDetailsParameters.first, pokemonId)
    }

    func test_performLoadData_whenRepositoryFetchFails_goesToErrorState() async {
        let pokemonId = 94853
        let repository = MockPokemonDetailsRepository()
        repository.stubbedFetchPokemonDetailsResult = .failure(MockError.mock1)
        let taskManager = TaskManager()

        let sut = makeSut(pokemonId: pokemonId,
                          repository: repository,
                          createTask: taskManager.createTask(_:))

        sut.perform(.loadData)

        await taskManager.awaitCurrentTasks()

        expect(sut: sut, toHaveState: .error)
    }

    private func makeSut(pokemonId: Int = 0,
                         repository: PokemonDetailsRepository = MockPokemonDetailsRepository(),
                         createTask: @escaping PokemonDetailsViewModel.CreateTask = { closure in Task { await closure() } } ) -> PokemonDetailsViewModel {
        let sut = PokemonDetailsViewModel(pokemonId: pokemonId,
                                          repository: repository,
                                          createTask: createTask)
        trackForMemoryLeaks(sut)
        return sut
    }

    private func expect(sut: PokemonDetailsViewModel,
                        toHaveState expectedState: PokemonDetailsViewState,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Next state publish")
        var cancellable: AnyCancellable?
        XCTAssertEqual(sut.stateValue, expectedState, file: file, line: line)

        cancellable = sut.statePublisher.sink { state in
            XCTAssertEqual(state, expectedState, file: file, line: line)
            expectation.fulfill()
            cancellable?.cancel()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

private class MockPokemonDetailsRepository: PokemonDetailsRepository {
    var fetchPokemonDetailsParameters = [Int]()
    var stubbedFetchPokemonDetailsResult: Result<PokemonDetails, Error> = .failure(MockError.mock1)

    func fetchPokemonDetails(id: Int) async throws -> PokemonDomain.PokemonDetails {
        fetchPokemonDetailsParameters.append(id)
        return try stubbedFetchPokemonDetailsResult.get()
    }
}

extension PokemonDetailsViewState: Equatable {
    public static func == (lhs: PokemonDetailsFeature.PokemonDetailsViewState, rhs: PokemonDetailsFeature.PokemonDetailsViewState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.error, .error):
            return true
        case (.loaded(details: let lhsDetails), .loaded(details: let rhsDetails)):
            return lhsDetails == rhsDetails
        default:
            return false
        }
    }
}

extension PokemonLoadedDetailsViewState: Equatable {
    public static func == (lhs: PokemonLoadedDetailsViewState, rhs: PokemonLoadedDetailsViewState) -> Bool {
        return lhs.name == rhs.name && lhs.imageURL == rhs.imageURL && lhs.weight == rhs.weight && lhs.height == rhs.height && lhs.types == rhs.types
    }
}
