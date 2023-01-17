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

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var heightLabel: UILabel!
    @IBOutlet var typesLabel: UILabel!
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

        viewModel.statePublisher.sink { state in
            
        }.store(in: &cancellables)
    }
}
