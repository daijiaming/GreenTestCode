//
//  ViewControllerViewModel.swift
//  GreenTest
//
//  Created by djm on 2024/3/7.
//

import Foundation
import RxSwift

enum SortType: Int {
    case off
    case price
}

class ViewControllerViewModel: NSObject {
    let data = PublishSubject<[MusicModel]>()
    
    weak var viewController: ViewController?
    
    private lazy var disposeBag = DisposeBag()
    
    let modelServer = MusicModelServer()
    
    var sortType = SortType.off
    
    var dataArr: [MusicModel] = []
    var sortPriceArr: [MusicModel] = []
    var searchText: String = ""
    
    func getiTunesApiData() {
        modelServer.getiTunesApiData()
            .subscribe { [weak self] array in
                guard let self = self else { return }
                self.dataArr = array
                self.data.onNext(array)
            } onError: { [weak self] error in
                self?.viewController?.show(tips: "服务出错，请重试")
            }
            .disposed(by: disposeBag)
    }
    
    /*
     AC2:Search data before the list as follows
     Search by local response field artistName and trackName.
     */
    func search(_ text: String) {
        searchText = text
        let array = getCurrentUseDataArray(sortType: sortType)
        let rst = modelServer.search(array, text: text, sortType: sortType)
        data.onNext(rst)
    }
    
    /*
     AC5:Sorting by toggle on/off and sort by trackPrice
     Implement sorting functionality based on the toggle switch status.
     When enabled, first sort song items by track price in ascending order and then by artist name in ascending order.
     Update the list view to display the sorted items in the appropriate order.
     */
    func sortedByPrice() {
        let array = getCurrentUseDataArray(sortType: .price)
        let rst = modelServer.search(array, text: searchText, sortType: .price)
        data.onNext(rst)
    }
    
    func sortedByDefault() {
        let array = getCurrentUseDataArray(sortType: .off)
        let rst = modelServer.search(array, text: searchText, sortType: .off)

        data.onNext(rst)
        
    }
}

extension ViewControllerViewModel {
    private func getCurrentUseDataArray(sortType: SortType) -> [MusicModel] {
        if sortType == .off {
            return dataArr
        } else {
            if sortPriceArr.count != dataArr.count {
                sortPriceArr = modelServer.sortedByPrice(dataArr, sortType: .price)
            }
            return sortPriceArr
        }
    }
}

extension Reactive where Base: ViewControllerViewModel {
    var dataArrSorted: Binder<Int> {
        Binder(self.base) { vm, index in
            vm.sortType = SortType(rawValue: index) ?? .off
            index > 0
            ? vm.sortedByPrice()
            : vm.sortedByDefault()
        }
    }
}
