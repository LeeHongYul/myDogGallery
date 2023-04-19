//
//  CoreDataManager.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var memoList = [MemoEntity]()
    var profileList = [ProfileEntity]()
    
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
    
    func fetchProfile() {
        
        let request = ProfileEntity.fetchRequest()
        
        do {
            profileList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    func addNewMemo(memoTitle: String, memoContext: String, timeStamp: Date, walkCount: Int?, walkTime: Int?, pooCount: Int?) {
        let newMemo = MemoEntity(context:  mainContext)
        newMemo.title = memoTitle
        newMemo.context = memoContext
        newMemo.timeStamp = timeStamp
        newMemo.walkCount = Int16(walkCount!)
        newMemo.walkTime = Int16(walkTime!)
        newMemo.pooCount = Int16(walkCount!)
        
        memoList.insert(newMemo, at: 0)
        saveContext()
    }
    
    func updateMemo(memo: MemoEntity, memoTitle: String, memoContext: String, walkCount: Int?, walkTime: Int?, pooCount: Int?) {
        memo.title = memoTitle
        memo.context = memoContext
        memo.walkCount = Int16(walkCount!)
        memo.walkTime = Int16(walkTime!)
        memo.pooCount = Int16(pooCount!)
        
        do {
            try mainContext.save()
        } catch {
            print(error)
        }
    }
    
    func addNewProfile(name: String, age: Int, gender: Bool, birthDay: Date, detail: String?, image: Data) {
        
        let newProfile = ProfileEntity(context: mainContext)
        newProfile.name = name
        newProfile.age = Int16(age)
        newProfile.gender = gender
        newProfile.birthDay = birthDay
        newProfile.detail  = detail
        newProfile.image = image
        
        
        profileList.insert(newProfile, at: 0)
        
        saveContext()
    }
    
    func updateProfile(update: ProfileEntity ,name: String, age: Int, gender: Bool, birthDay: Date, detail: String?, image: Data) {
        
        update.name = name
        update.age = Int16(age)
        update.gender = true
        update.birthDay = birthDay
        update.detail  = detail
        update.image = image
        
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
    
    func deleteProfile(profile: ProfileEntity) {
        mainContext.delete(profile)
        saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "myDogGallery")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
