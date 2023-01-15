//
//  PokemonListViewController.swift
//  
//
//  Created by Ben on 13/01/2023.
//

import UIKit
import Combine

enum PokemonTableViewItem {
    case loading
    case pokemon(item: PokemonListViewItem)
}

class PokemonListViewController<VM: ViewModel>:
    UIViewController, UITableViewDelegate where VM.State == PokemonListViewState,
                                                VM.Action == PokemonListViewAction {
    @IBOutlet var tableView: UITableView!
    private let viewModel: VM
    private lazy var dataSource: PokemonListDataSourceFactory.DataSource = PokemonListDataSourceFactory.createDataSource()

    private var cancellables = Set<AnyCancellable>()

    init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: "PokemonListViewController", bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
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

    private func bindViewModel() {
        viewModel.statePublisher.sink { [weak self] state in
            var tableViewItems: [PokemonTableViewItem] = state.items.map{ .pokemon(item: $0) }

            switch state.dataFetchState {
            case .loading:
                tableViewItems.append(.loading)
            case .loaded:
                break
            case .error:
                break
            }

            self?.dataSource.update(newItems: tableViewItems)
            self?.tableView.reloadData()
        }
        .store(in: &cancellables)
    }

    private func setupTableView() {
        tableView.registerCellWithNib(type: PokemonListTableViewCell.self)
        tableView.registerCellWithNib(type: LoadingTableViewCell.self)
        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        
    }
}


private extension UITableView {
    func registerCellWithNib(type: UITableViewCell.Type) {
        let name = String(describing: type)
        register(UINib(nibName: name, bundle: Bundle.module), forCellReuseIdentifier: name)
    }
}

private class PokemonListDataSourceFactory {
    typealias DataSource = ArrayTableViewDataSource<PokemonTableViewItem>

    static func createDataSource() -> DataSource {
        return DataSource (items: []) { tableView, item in
            let cell: UITableViewCell?
            switch item {
            case .loading:
                cell = Self.loadingCell(in: tableView)
            case .pokemon(item: let item):
                cell = Self.pokemonCell(item: item, in: tableView)
            }
            return cell ?? UITableViewCell()
        }
    }

    private static func loadingCell(in tableView: UITableView) -> UITableViewCell? {
        tableView.dequeueReusableCell(withIdentifier: String(describing: LoadingTableViewCell.self))
    }

    private static func pokemonCell(item: PokemonListViewItem, in tableView: UITableView) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PokemonListTableViewCell.self)) as? PokemonListTableViewCell else {
            return nil
        }

        cell.nameLabel.text = item.name
        return cell
    }
}
