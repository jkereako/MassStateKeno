//
//  DrawingsCoordinator.swift
//  MassLotteryKeno
//
//  Created by Jeff Kereakoglow on 5/24/19.
//  Copyright © 2019 Alexis Digital. All rights reserved.
//

import Foundation
import Kringle

final class DrawingsCoordinator: RootCoordinator {
    var rootViewController: UIViewController {
        let drawingTableViewController = DrawingTableViewController()

        refreshData(for: drawingTableViewController)

        navigationController = UINavigationController(
            rootViewController: drawingTableViewController
        )

        return navigationController!
    }

    private let networkClient: NetworkClient
    private let dateFormatter: DateFormatter
    private var navigationController: UINavigationController?

    init(networkClient: NetworkClient, dateFormatter: DateFormatter) {
        self.networkClient = networkClient
        self.dateFormatter = dateFormatter
    }
}


// MARK: - DrawingTableViewModelDelegate
extension DrawingsCoordinator: DrawingTableViewModelDelegate {
    func refreshData(for viewController: DrawingTableViewController) {
        let promise = networkClient.get(
            MassLotteryEndpoint.todaysGames,
            decodingResponseTo: GameDayContract.self,
            query: ["buster": String(Date().timeIntervalSince1970)]
        )

        promise.then { [weak self] gameDayContract in
            self?.buildViewModel(for: viewController, with: gameDayContract)
            }.catch { [weak self] _ in
                self?.showNetworkErrorAlert(on: viewController)
        }
    }

    func didSelect(_ drawingViewModel: DrawingViewModel) {
        let numberViewController = NumberViewController()
        let numberViewModel = NumberViewModel(
            drawing: drawingViewModel.model, dateFormatter: dateFormatter
        )

        numberViewModel.dataSource = numberViewController
        numberViewController.viewModel = numberViewModel

        navigationController?.show(numberViewController, sender: self)
    }
}

// MARK: - Private Helpers
private extension DrawingsCoordinator {
    func buildViewModel(for tableViewController: DrawingTableViewController,
                        with gameDayContract: GameDayContract) {

        var drawingViewModels =  [DrawingViewModel]()
        let aDateFormatter = dateFormatter

        gameDayContract.drawings.forEach { drawingContract in
            let drawingModel = DrawingModel(
                contract: drawingContract, dateFormatter: aDateFormatter
            )

            drawingViewModels.append(
                DrawingViewModel(model: drawingModel, dateFormatter: aDateFormatter)
            )
        }

        let refreshedDrawingTableViewModel = DrawingTableViewModel(
            drawingViewModels: drawingViewModels
        )

        refreshedDrawingTableViewModel.dataSource = tableViewController
        refreshedDrawingTableViewModel.delegate = self
        tableViewController.delegate = refreshedDrawingTableViewModel
        tableViewController.viewModel = refreshedDrawingTableViewModel
    }

    func showNetworkErrorAlert(on viewController: UIViewController) {
        // Displays an alert if the promise is rejected
        let alertController = UIAlertController(
            title: "Network Error",
            message: "We weren't able to load today's winning numbers. Please try again later.",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Okay", style: .cancel))

        viewController.present(alertController, animated: true)
    }
}
