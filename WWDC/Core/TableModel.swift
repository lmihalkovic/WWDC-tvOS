//
//  TableModel.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/18/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import Foundation
import RealmSwift

// TODO: fix api - deal with missing groupby value

struct Group<E> {
    let name:String
    var values:[E]
}

enum Groups<E> {
    case Single([E])
    case Multiple([Group<E>])
    case Empty
}

struct TableModel<E:Object> {
    typealias Entry = (key: String, val: [E])
    var grouped: Groups<E>
    init(_ list:Results<E>, mapper:((E) -> String)?) {
        self.grouped = .Empty
        if let m = mapper {
            refresh(list, mapper:m)
        } else {
            refresh(list)
        }
    }
    mutating func refresh(data:Results<E>) {
        self.grouped = .Empty
        var all = Array<E>()
        for session in data {
            all.append(session)
        }
        self.grouped = .Single(all)
    }
    mutating func refresh(data:Results<E>, mapper: (E) -> String) {
        self.grouped = .Empty
        
        if(data.count > 0) {
            var mapped = Dictionary<String, Entry>()
            for session in data {
                let key = mapper(session)
                var group : Entry = mapped[key] != nil ? mapped[key]! : (key: key, val: [])
                group.val.append(session)
                mapped[key] = group
            }
            
            let entries = mapped.sort {$0.0.localizedCaseInsensitiveCompare($1.0) == NSComparisonResult.OrderedDescending }
            var all = Array<Group<E>>()
            entries.forEach { (key: String, v: Entry) -> Void in
                var values:[E] = [];
                for session in v.val {
                    values.append(session)
                }
                all.append(Group(name:key, values: values))
            }
            self.grouped = .Multiple(all)
        }
    }
    var countGroups: Int {
        switch grouped {
        case .Single(_):
            return 1
        case .Multiple(let list):
            return list.count
        case .Empty:
            return 0
        }
    }
    func groupName(index: Int) -> String? {
        switch grouped {
        case .Single(_):
            return nil
        case .Multiple(let list):
            return list[index].name
        case .Empty:
            return nil
        }
    }
    func item(index: Int, inGroup group: Int) -> E? {
        switch grouped {
        case .Single(let list):
            return list[index]
        case .Multiple(let list):
            return list[group].values[index]
        case .Empty:
            return nil
        }
    }
    func itemsInGroup(index: Int) -> Int{
        switch grouped {
        case .Single(let list):
            return list.count
        case .Multiple(let list):
            return list[index].values.count
        case .Empty:
            return 0
        }
    }
  
}

extension TableModel {

    func indexPathForElement(element:E) -> NSIndexPath? {
        switch self.grouped {
        case .Single(let list):
            for index in 0..<list.count where list[index] == element {
                return NSIndexPath(index: index)
            }
            return nil
        case .Multiple(let lists):
            for section in 0..<lists.count {
                let list = lists[section].values
                for index in 0..<list.count where list[index] == element {
                    return NSIndexPath(forRow: index, inSection: section)
                }
            }
            return nil
        case .Empty:
            return nil;
        }
    }
    
}
