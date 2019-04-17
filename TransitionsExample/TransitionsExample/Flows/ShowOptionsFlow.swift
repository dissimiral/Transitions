//
//  ShowOptionsFlow.swift
//  TransitionsExample
//
//  Created by Max Ovtsin on 1/4/19.
//  Copyright © 2019 Max Ovtsin. All rights reserved.
//

import UIKit
import Transitions

final class ShowOptionsFlow: Flow {

    func start(
        injection: Injection,
        coordinator: Coordinator,
        transitionHandler: TransitionHandler
        ) {
        
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let runAction = UIAlertAction(title: "Run Preparation", style: .default) { (_) in
            self.didPressRun(
                coordinator: coordinator,
                injection: injection
            )
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            coordinator.didFinish(flow: self)
        }
        
        alertController.addAction(runAction)
        alertController.addAction(cancel)

        transitionHandler.present(
            flow: self,
            transition: BaseTransition.modal,
            params: alertController
        )
    }

    private func didPressRun(coordinator: Coordinator, injection: Injection) {
        coordinator.didFinish(flow: self)

        coordinator.show(
            PrepareDataFlow.self,
            injection: PrepareDataFlow.Injection(prepared: injection.prepared)
        )
    }

    struct Injection {
        let prepared: (String) -> Void
    }
}