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

    private let viewModel: VM

    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: VM) {
        self.viewModel = viewModel
        super.init(nibName: "PokemonListViewController", bundle: Bundle.module)
        title = "Pokemon"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
