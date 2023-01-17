//
//  PokemonDetailsViewController.swift
//  
//
//  Created by Ben on 16/01/2023.
//

import UIKit
import Combine
import SharedUI

class PokemonDetailsViewController<VM: ViewModel>:  UIViewController where VM.State == PokemonDetailsViewState, VM.Action == PokemonDetailsViewAction {

    @IBOutlet var detailsContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var typesLabel: UILabel!
    @IBOutlet var errorView: UIView!
    @IBOutlet var loadingView: UIView!
    private let viewModel: VM

    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: "PokemonDetailsViewController", bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.perform(.loadData)

        viewModel.statePublisher.sink { [weak self] state in
            self?.changeState(state: state)
        }.store(in: &cancellables)
    }

    private func changeState(state: PokemonDetailsViewState) {
        loadingView.isHidden = true
        errorView.isHidden = true
        detailsContainerView.isHidden = true

        switch state {
        case .loading:
            loadingView.isHidden = false
        case .error:
            errorView.isHidden = false
        case .loaded(details: let details):
            title = details.name
            imageView.load(url: details.imageURL)
            heightLabel.text = details.height
            weightLabel.text = details.weight
            typesLabel.text = details.types
            detailsContainerView.isHidden = false
        }
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        viewModel.perform(.loadData)
    }
}
