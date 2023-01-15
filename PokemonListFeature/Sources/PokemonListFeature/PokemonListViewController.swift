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

    private let cellName = "PokemonListTableViewCell"
    @IBOutlet var tableView: UITableView!
    @IBOutlet var loadingView: UIView!
    private let viewModel: VM

    private typealias DataSource = ArrayTableViewDataSource<PokemonListViewItem>

    private lazy var dataSource: DataSource = {
        return DataSource (items: []) { tableView, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PokemonListTableViewCell.self)) as? PokemonListTableViewCell else {
                return UITableViewCell()
            }
            cell.nameLabel.text = item.name
            return cell
       }
    }()

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
        setupTableView()

        viewModel.statePublisher.sink { [weak self] state in
            self?.loadingView.isHidden = !state.isLoading
            self?.dataSource.update(newItems: state.items)
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)

        viewModel.perform(.loadData)
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

    private func setupTableView() {
        tableView.register(UINib(nibName: cellName, bundle: Bundle.module),
                           forCellReuseIdentifier: cellName)

        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
    }
}


