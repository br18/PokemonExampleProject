//
//  PokemonListViewModelTests.swift
//  
//
//  Created by Ben on 15/01/2023.
//

import XCTest
import PokemonDomain
import Combine
@testable import PokemonListFeature

final class PokemonListViewModelTests: XCTestCase {

    func test_initialState_isLoadingWithZeroItems() {
        let sut = makeSut()
        let expectedState = PokemonListViewState(dataFetchState: .loading, items: [])
        XCTAssertEqual(sut.stateValue, expectedState)
        expect(sut: sut, toPublishNext: expectedState)
    }

    private func expect(sut: PokemonListViewModel, toPublishNext expectedState: PokemonListViewState) {
        let expectation = XCTestExpectation(description: "Next state publish")
        var cancellable: AnyCancellable?

        cancellable = sut.statePublisher.sink { state in
            XCTAssertEqual(state, expectedState)
            expectation.fulfill()
            cancellable?.cancel()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    private func makeSut(repository: PokemonRepository = StubPokemonRepository()) -> PokemonListViewModel {
        return PokemonListViewModel(pokemonRepository: repository)
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
