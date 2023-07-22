//
//  CoreDataManager.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import Foundation
import CoreData

class BaseManger {
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "myDogGallery")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError

                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

class ProfileManager: BaseManger {

    static let shared = ProfileManager()

    private override init() {}

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var profileList = [ProfileEntity]()

    func fetchProfile() {
        let request = ProfileEntity.fetchRequest()
        let sortByTimeStamp = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortByTimeStamp]
        do {
            profileList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchProfileByPin() {
        let request = ProfileEntity.fetchRequest()
        let sortByPin = NSSortDescriptor(key: "pin", ascending: false)

        request.sortDescriptors = [sortByPin]
        do {
            profileList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func addNewProfile(name: String,
                       age: Int,
                       gender: Int,
                       birthDay: Date,
                       detail: String?,
                       image: Data,
                       timeStamp: Date?) {
        let newProfile = ProfileEntity(context: mainContext)
        newProfile.name = name
        newProfile.age = Int16(age)
        newProfile.gender = Int16(gender)
        newProfile.birthDay = birthDay
        newProfile.detail  = detail
        newProfile.image = image
        newProfile.timeStamp = timeStamp
        profileList.insert(newProfile, at: 0)
        saveContext()
    }

    func updateProfile(update: ProfileEntity,
                       name: String,
                       age: Int,
                       gender: Int,
                       birthDay: Date,
                       detail: String?,
                       image: Data)
    {
        update.name = name
        update.age = Int16(age)
        update.gender = Int16(gender)
        update.birthDay = birthDay
        update.detail = detail
        update.image = image
        do {
            try mainContext.save()
        } catch {
            print(error)
        }
    }

    func deleteProfile(profile: ProfileEntity) {
        mainContext.delete(profile)
        saveContext()
    }
}

class WalkManger: BaseManger {

    static let shared = WalkManger()

    private override init() {}

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var walkList = [WalkEntity]()

    func fetchWalk() {

        let request = WalkEntity.fetchRequest()
        do {
            walkList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func addNewWalk(cuurentDate: Date,
                    totalDistance: Double,
                    totalTime: String,
                    profile: Data,
                    startLon: Double,
                    startLat: Double,
                    endLon: Double,
                    endLat: Double)
    {
        let newWalk = WalkEntity(context: mainContext)
        newWalk.currentDate = cuurentDate
        newWalk.totalDistance = totalDistance
        newWalk.totalTime = totalTime
        newWalk.profile = profile
        newWalk.startLon = startLon
        newWalk.startLat = startLat
        newWalk.endLon = endLon
        newWalk.endLat = endLat

        walkList.insert(newWalk, at: 0)
        saveContext()
    }
}

class MemoManager : BaseManger {

    static let shared = MemoManager()

    private override init() {}

    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    var memoList = [MemoEntity]()

    var searchBarlist = [NSManagedObject]()

    func searchByName(_ keyword: String?) {
        guard let keyword = keyword else { return }
        let predicate = NSPredicate(format: "title CONTAINS[c] %@", keyword)
        fetchSearchedMemo(predicate: predicate)
    }

    func fetchSearchedMemo(predicate: NSPredicate? = nil) {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Memo")
        request.predicate = predicate
        do {
            searchBarlist = try MemoManager.shared.mainContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func fetchMemo() {
        let request = MemoEntity.fetchRequest()
        let sortByTimeStamp = NSSortDescriptor(key: "timeStamp", ascending: false)
        request.sortDescriptors = [sortByTimeStamp]
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }

    func addNewMemo(memoTitle: String?,
                    memoContext: String?,
                    timeStamp: Date?,
                    walkCount: Int?,
                    walkTime: Int?,
                    pooCount: Int?,
                    inputDate: Date?)
    {
        let newMemo = MemoEntity(context: mainContext)
        newMemo.title = memoTitle
        newMemo.context = memoContext
        newMemo.timeStamp = timeStamp
        if let walkCount {
            newMemo.walkCount = Int16(walkCount)
        }
        if let walkTime {
            newMemo.walkTime = Int16(walkTime)
        }
        if let pooCount {
            newMemo.pooCount = Int16(pooCount)
        }
        if let inputDate {
            newMemo.inputDate = inputDate
        }
        memoList.insert(newMemo, at: 0)
        saveContext()
    }

    func updateMemo(memo: MemoEntity,
                    memoTitle: String?,
                    memoContext: String?,
                    walkCount: Int?,
                    walkTime: Int?,
                    pooCount: Int?,
                    inputDate: Date?)
    {
        memo.title = memoTitle
        memo.context = memoContext
        if let walkCount {
            memo.walkCount = Int16(walkCount)
        }
        if let walkTime {
            memo.walkTime = Int16(walkTime)
        }
        if let pooCount {
            memo.pooCount = Int16(pooCount)
        }
        if let inputDate {
            memo.inputDate = inputDate
        }
        do {
            try mainContext.save()
        } catch {
            print(error)
        }
    }

    func deleteMemo(memo: MemoEntity) {
        mainContext.delete(memo)
        saveContext()
    }
}
