//
//  ModalTransition.swift
//  Transitions
//
//  Created by Max Ovtsin on 15/4/19.
//  Copyright © 2019 Max Ovtsin. All rights reserved.
//

import UIKit

public final class ModalTransition: BaseTransition, Transition {

    public func handle<FlowT>(
        flow: FlowT,
        params: UIViewController,
        coordinator: MainCoordinator
        ) where FlowT: Flow {

        let frame = coordinator.lastVisibleFrame()
        let viewController = frame.visibleViewController()

        viewController?.present(
            params,
            animated: true,
            completion: nil
        )

        coordinator.injectOnDeinitHandler(
            object: params,
            flow: flow
        )

        coordinator.append(
            frame: Frame(
                flow: flow,
                viewController: params,
                presentationMode: .modal
            )
        )
    }
}
