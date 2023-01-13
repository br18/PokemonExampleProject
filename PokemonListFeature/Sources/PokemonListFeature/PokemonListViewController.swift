//
//  PokemonListViewController.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import UIKit

class PokemonListViewController<VM: ViewModel>:
    UIViewController, UITableViewDelegate where VM.State == PokemonListViewState,
                                                VM.Action == PokemonListViewAction {

    @IBOutlet var tableView: UITableView!
    private let viewModel: VM

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
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard row >= 0 && row < viewModel.state.items.count else {
            return
        }
        let pokemonId = viewModel.state.items[row].id
        viewModel.perform(.viewDetails(id: pokemonId))
    }
}


