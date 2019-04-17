//
//  MainCoordinator.swift
//  Transitions
//
//  Created by Max Ovtsin on 27/3/19.
//  Copyright © 2019 Max Ovtsin. All rights reserved.
//

import UIKit

public protocol Coordinator {

    func launch<FlowT>(
        rootFlowType: FlowT.Type,
        injection: FlowT.Injection
        ) -> FlowT.FlowInput where FlowT: Flow

    func show<FlowT>(
        _ flowType: FlowT.Type,
        injection: FlowT.Injection
        ) -> FlowT.FlowInput where FlowT: Flow

    func show<FlowT>(
        _ flowType: FlowT.Type
        ) -> FlowT.FlowInput where FlowT: Flow, FlowT.Injection == Void

    func didFinish<FlowT>(
        flow: FlowT
        ) where FlowT: Flow
}

public class MainCoordinator: Coordinator {

    // MARK: - Properties
    var window: UIWindow?
    private let list = LinkedList<Frame>()
    private let leaksDetector = LeaksDetector()

    // MARK: - Life cycle
    public init() { }

    public func launch<FlowT>(
        rootFlowType: FlowT.Type,
        injection: FlowT.Injection
        ) -> FlowT.FlowInput where FlowT: Flow {
        guard window == nil else { fatalError("Must be called once") }
        window = UIWindow(frame: UIScreen.main.bounds)
        let input = show(rootFlowType, injection: injection)
        window?.makeKeyAndVisible()
        return input
    }
    
    public func show<FlowT>(
        _ flowType: FlowT.Type,
        injection: FlowT.Injection
        ) -> FlowT.FlowInput where FlowT: Flow  {

        guard window != nil else { fatalError("Coordinator is not launched") }
        let flow = flowType.init()
        return flow.start(
            injection: injection,
            coordinator: self,
            transitionHandler: self
        )
    }

    public func show<FlowT>(
        _ flowType: FlowT.Type
        ) -> FlowT.FlowInput where FlowT: Flow, FlowT.Injection == Void {

        guard window != nil else { fatalError("Coordinator is not launched") }
        let flow = flowType.init()
        return flow.start(
            injection: Void(),
            coordinator: self,
            transitionHandler: self
        )
    }

    public func didFinish<FlowT>(flow: FlowT) where FlowT: Flow {
        guard var last = list.last else { fatalError("Stack is empty") }

        while last.value.presentationMode != .root {
            if last.value.flow === flow {
                if let left = last.next {
                    leaksDetector.detect(from: left)
                }
                list.remove(node: last)
                return
            } else {
                last = last.previous!
            }
        }

        fatalError("Flow doesn't exist.")
    }
}

extension MainCoordinator {

    public func cleanStack() {
        list.removeAll()
    }

    public func append(frame: Frame) {
        list.append(frame)
    }

    public func lastVisibleFrame() -> Frame {
        var last = list.last

        while let _last = last {
            let viewController = _last.value.viewController
            let mode = _last.value.presentationMode

            if (viewController == nil || viewController?.view.window == nil) ||
                (mode == .viewless || mode == .custom) {
                last = last?.previous
            } else {
                break
            }
        }

        if let frame = last?.value { return frame }
        fatalError("Must not happen")
    }
}

extension MainCoordinator: TransitionHandler {

    public func present<TransitionT, ParametersT, FlowT>(
        flow: FlowT,
        transition: TransitionT,
        params: ParametersT
        ) where FlowT: Flow, TransitionT: Transition, TransitionT: BaseTransition, ParametersT == TransitionT.ParametersT {

        leaksDetector.detect(in: list)

        transition.handle(
          flow: flow,
          params: params,
          coordinator: self
      )
    }
}
