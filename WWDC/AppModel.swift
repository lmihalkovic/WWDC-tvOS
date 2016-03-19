//
//  AppModel.swift
//  WWDC
//
//  Created by Laurent Mihalkovic on 3/19/16.
//  Copyright © 2016 Laurent Mihalkovic. All rights reserved.
//

import Foundation
import RealmSwift

private let _sharedAppModel = AppModel()

public class AppModel {

    class var sharedModel: AppModel {
        return _sharedAppModel
    }
    
    func reloadSessions() {
        fetchLocalSessions()
        
        WWDCDatabase.sharedDatabase.sessionListChangedCallback = { newSessionKeys in
            print("\(newSessionKeys.count) new session(s) available")
            
            self.fetchLocalSessions()
        }
        WWDCDatabase.sharedDatabase.refresh()
    }
    
    func fetchLocalSessions() {
        allSessions = WWDCDatabase.sharedDatabase.standardSessionList
    }
    
    var sessionYears: [Int] = []
    var allSessions: Results<Session>? {
        didSet {
            //            guard allSessions != nil else { sessionYears = []; allSessions = []; return     }
            
            // compute sorted list of years
            var years = Set<Int>()
            for session in allSessions! {
                years.insert(session.year)
            }
            sessionYears = years.sort { $0 > $1 }
            
        }
        
    }
    
    func sessionsMatchingYear(year:String) -> Results<Session>? {
        if let year = Int(year) {
            let filteredSessions:Results<Session> = allSessions!.filter("year = %d", year)
            return filteredSessions
        }
        return nil;
    }
    
    private let searchQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
    
    func sessionsMatchingSearchString(filter:String, onComplete: (Results<Session>?)->Void) {
        dispatch_async(searchQueue) {
            let realm = try! Realm()
            let transcripts = realm.objects(Transcript.self).filter("fullText CONTAINS[c] %@", filter)
            let keysMatchingTranscripts = transcripts.map({ $0.session!.uniqueId })
            mainQ {
                let criteria = NSPredicate(format: "title CONTAINS[c] %@ OR summary CONTAINS[c] %@ OR uniqueId IN %@", filter, filter, keysMatchingTranscripts)
                let results = self.allSessions?.filter(criteria)
                onComplete(results)
            }
        }
        
    }
    
}
