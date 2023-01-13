//
//  PokemonListViewController.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import UIKit
import Combine

class PokemonListViewController<VM: ViewModel>:
    UIViewController, UITableViewDelegate where VM.State == PokemonListViewState,
                                                VM.Action == PokemonListViewAction {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    private let viewModel: VM

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: "PokemonListViewController",
                   bundle: Bundle.module)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.statePublisher.sink { [weak self] state in
            self?.loadingView.isHidden = !state.isLoading
        }.store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let items = viewModel.stateValue.items
        guard items.containsInRange(row) else {
            return
        }
        let pokemonId = items[row].id
        viewModel.perform(.viewDetails(id: pokemonId))
    }
}

private extension Array {
    func containsInRange(_ index: Int) -> Bool {
        range().contains(index)
    }

    private func range() -> Range<Int> {
        return 0..<count
    }
}


