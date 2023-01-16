//
//  PokemonListViewModelTests.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import XCTest
import PokemonDomain
import Combine
import SharedTestHelpers
@testable import PokemonListFeature

final class PokemonListViewModelTests: XCTestCase {
    private let pokemonFetchResultPage1: (pokemon: [Pokemon], totalCount: Int) =  ([Pokemon(id: 667, name: "bulbasaur"), Pokemon(id: 543, name: "charizard")], 3)
    private let pokemonFetchResultPage2: (pokemon: [Pokemon], totalCount: Int) =  ([Pokemon(id: 43, name: "pikachu")], 3)

    func test_initialState_isLoadingWithZeroItems() {
        let sut = makeSut()
        let expectedState = PokemonListViewState(dataFetchState: .loading, items: [])
        XCTAssertEqual(sut.stateValue, expectedState)
        expect(sut: sut, toPublishNext: expectedState)
    }

    func test_performViewDetails_givenInitWithPerformDetailsClosure_callClosureWithId() {
        var viewDetailsIds = [Int]()
        let viewDetails: (Int) -> Void = { id in
            viewDetailsIds.append(id)
        }

        let sut = makeSut(viewDetails: viewDetails)

        sut.perform(.viewDetails(id: 1))
        sut.perform(.viewDetails(id: 65))

        XCTAssertEqual(viewDetailsIds.count, 2)
        XCTAssertEqual(viewDetailsIds.first, 1)
        XCTAssertEqual(viewDetailsIds.last, 65)
    }

    func test_performLoadPokemon_whenNoPokemonLoadedAndResponseContainsPokemon_stateIsLoadedWithPokemon() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)

        await taskManager.awaitCurrentTasks()

        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .loaded, items: pokemonFetchResultPage1.pokemon.map { PokemonListViewItem(id: $0.id, name: $0.name) } )

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 1)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.offset, 0)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.limit, 2)
        XCTAssertEqual(sut.stateValue, expectedState)
        expect(sut: sut, toPublishNext: expectedState)
    }

    func test_performLoadPokemon_whenNoPokemonLoadedAndResponseIsError_stateIsErrorWithEmptyPokemon() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.failure(MockError.mock1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)

        await taskManager.awaitCurrentTasks()

        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .error, items: [])

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 1)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.offset, 0)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.limit, 2)
        XCTAssertEqual(sut.stateValue, expectedState)
        expect(sut: sut, toPublishNext: expectedState)
    }

    private func expect(sut: PokemonListViewModel,
                        toPublishNext expectedState: PokemonListViewState,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let expectation = XCTestExpectation(description: "Next state publish")
        var cancellable: AnyCancellable?

        cancellable = sut.statePublisher.sink { state in
            XCTAssertEqual(state, expectedState, file: file, line: line)
            expectation.fulfill()
            cancellable?.cancel()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeSut(pageSize: Int = 2,
                         repository: PokemonRepository = StubPokemonRepository(),
                         viewDetails: @escaping (Int) -> Void = { _ in },
                         createTask: @escaping PokemonListViewModel.CreateTask = { closure in Task { await closure() } } ) -> PokemonListViewModel {
        let sut = PokemonListViewModel(pageSize: pageSize,
                                       pokemonRepository: repository,
                                       viewDetails: viewDetails,
                                       createTask: createTask)
        trackForMemoryLeaks(sut)
        return sut
    }
}

class TaskManager {
    private var tasks = [Task<(), Never>]()

    func createTask(_ closure: @escaping () async -> Void) {
        let task = Task {
            await closure()
        }
        tasks.append(task)
    }

    func awaitCurrentTasks() async {
        for task in tasks {
            _ = await task.result
        }
    }
}

private class StubPokemonRepository: PokemonRepository {
    typealias FetchPokemonSuccess = (pokemon: [Pokemon], totalCount: Int)
    var fetchPokemonParametersList = [(offset: Int, limit: Int)]()
    var fetchPokemonResult: Result<FetchPokemonSuccess, Error> = .success((pokemon: [], totalCount: 0))

    func fetchPokemon(offset: Int, limit: Int) async throws -> FetchPokemonSuccess {
        fetchPokemonParametersList.append((offset: offset, limit: limit))
        return try fetchPokemonResult.get()
    }
}

extension PokemonListViewState: Equatable {
    public static func == (lhs: PokemonListFeature.PokemonListViewState, rhs: PokemonListFeature.PokemonListViewState) -> Bool {
        return lhs.dataFetchState == rhs.dataFetchState && lhs.items == rhs.items
    }
}

extension PokemonListViewItem: Equatable {
    public static func == (lhs: PokemonListViewItem, rhs: PokemonListViewItem) -> Bool {
        lhs.name == rhs.name && lhs.id == rhs.id
    }
}
