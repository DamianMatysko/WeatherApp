//
//  DatabaseManager.swift
//  WeatherApp
//
//  Created by Damián Matysko on 8/16/22.
//

import Foundation
import CoreData


class DatabaseManager {
    let container: NSPersistentContainer
    init(){
        container = NSPersistentContainer(name: "Database")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error durring database initialization with \(error.localizedDescription)")
            }
        }
    }
    
    func insert(_ name: String){
        let city = City(context: container.viewContext)
        city.name = name
        try? self.container.viewContext.save()
    }
    
    func delete(_ name: String){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = City.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        //let item = try? container.viewContext.fetch(fetchRequest: fetchRequest)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try? container.viewContext.execute(deleteRequest)
    }
    
    func getData(by name: String? = nil) -> [City] {
        let fetchRequest = City.fetchRequest()
        if let name = name {
            fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        }
        let sortByName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByName]
        let cities = try? container.viewContext.fetch(fetchRequest)
        return cities ?? []
    }
    
}
