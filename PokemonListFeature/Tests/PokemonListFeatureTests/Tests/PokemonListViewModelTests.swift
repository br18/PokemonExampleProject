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
    private var pokemonFetchResultPage1: (pokemon: [Pokemon], totalCount: Int) =  ([Pokemon(id: 667, name: "bulbasaur"), Pokemon(id: 543, name: "charizard")], 3)
    private let pokemonFetchResultPage2: (pokemon: [Pokemon], totalCount: Int) =  ([Pokemon(id: 43, name: "pikachu")], 3)

    func test_initialState_isLoadingWithZeroItems() {
        let sut = makeSut()
        let expectedState = PokemonListViewState(dataFetchState: .loading, items: [])
        expect(sut: sut, toHaveState: expectedState)
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

        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .loaded, items: pokemonFetchResultPage1.pokemon.map { $0.toListItem() } )

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 1)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.offset, 0)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.limit, 2)
        expect(sut: sut, toHaveState: expectedState)
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
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenPokemonPreviouslyLoadedAndResponseIsSecondPage_fetchesAndAppendsSecondPageOfPokemonToState() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage2)

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        let expectedItems = (pokemonFetchResultPage1.pokemon + pokemonFetchResultPage2.pokemon).map { $0.toListItem() }
        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .loaded, items: expectedItems)

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.offset, 0)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.limit, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.last?.offset, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.last?.limit, 2)
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenPokemonPreviouslyLoadedAndResponseError_isErrorStateWithFetchedPokemon() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        repository.fetchPokemonResult = Result.failure(MockError.mock1)

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        let expectedItems = (pokemonFetchResultPage1.pokemon).map { $0.toListItem() }
        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .error, items: expectedItems)

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.offset, 0)
        XCTAssertEqual(repository.fetchPokemonParametersList.first?.limit, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.last?.offset, 2)
        XCTAssertEqual(repository.fetchPokemonParametersList.last?.limit, 2)
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenPokemonFetchedToCount_doesNotFetchMorePokemon() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage2)

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        let expectedItems = (pokemonFetchResultPage1.pokemon + pokemonFetchResultPage2.pokemon).map { $0.toListItem() }
        let expectedState: PokemonListViewState = PokemonListViewState(dataFetchState: .loaded, items: expectedItems)

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 2)
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenInitialFetchIsSuccess_setsStateToLoadingBeforeLoadingFromRepository() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.success(pokemonFetchResultPage1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        taskManager.ignoreNewTasks = true

        sut.perform(.loadPokemon)

        let expectedItems = (pokemonFetchResultPage1.pokemon).map { $0.toListItem() }
        let expectedState = PokemonListViewState(dataFetchState: .loading, items: expectedItems)
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenInitialFetchIsFailed_setsStateToLoadingBeforeLoadingFromRepository() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.failure(MockError.mock1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        taskManager.ignoreNewTasks = true

        sut.perform(.loadPokemon)

        let expectedState = PokemonListViewState(dataFetchState: .loading, items: [])
        expect(sut: sut, toHaveState: expectedState)
    }

    func test_performLoadPokemon_whenAlreadyLoadingPokemon_doesNotLoadMorePokemon() async {
        let taskManager = TaskManager()
        let repository = StubPokemonRepository()
        repository.fetchPokemonResult = Result.failure(MockError.mock1)

        let sut = makeSut(repository: repository, createTask: taskManager.createTask(_:))

        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        sut.perform(.loadPokemon)
        await taskManager.awaitCurrentTasks()

        XCTAssertEqual(repository.fetchPokemonParametersList.count, 1)
    }


    private func expect(sut: PokemonListViewModel,
                        toHaveState expectedState: PokemonListViewState,
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
    var ignoreNewTasks = false

    var taskClosures = [() async -> Void]()

    func createTask(_ closure: @escaping () async -> Void) {
        if ignoreNewTasks {
            return
        }

        taskClosures.append(closure)
    }

    func awaitCurrentTasks() async {
        while let taskClosure = taskClosures.popLast() {
            _ = await Task {
                await taskClosure()
            }.result
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

private extension Pokemon {
    func toListItem() -> PokemonListViewItem {
        PokemonListViewItem(id: id, name: name)
    }
}
