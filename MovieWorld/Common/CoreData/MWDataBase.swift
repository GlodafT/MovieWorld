//
//  MWDataBase.swift
//  MovieWorld
//
//  Created by Mikita Igonin on 12.04.21.
//

import Foundation
import CoreData

typealias MWDB = MWDataBase

class MWDataBase {
    static let sh = MWDataBase()

    // MARK: - properties

    private static let dataBaseContainerName = "MWDataModel"

    private let documentsDirectory: URL

    // MARK: - core data

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: MWDB.dataBaseContainerName)
        container.loadPersistentStores { (description, error) in
            if let error = error {
            Swift.debugPrint(error.localizedDescription)
        }
        Swift.debugPrint("Store description: \(description)")
        }

        return container
    }()

    private var context: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }


    // MARK: - initialization

    private init() {

        let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if docDirectory.count > 0 {
            self.documentsDirectory = docDirectory[0]
        } else {
            fatalError("Directory doesnt exist")
        }

    }


    // MARK: - core data functions

    func saveContext() {
        if self.context.hasChanges {
            Swift.debugPrint("Context inserted objects: \(self.context.insertedObjects)")
            Swift.debugPrint("Context inserted objects: \(self.context.deletedObjects)")

            do {
                try self.context.save()
                Swift.debugPrint("Context was saved")
            } catch {
                let nsError = error as NSError
                Swift.debugPrint("Couldent saved data. Reason: \(nsError.localizedDescription) \(nsError.userInfo)")
            }
        }
    }

    func save(movie: MWMovie) {
        self.getCoreDataObject(from: movie)
        self.saveContext()
    }

    func loadMovies() -> [MWMovie] {

        // 1
        let featchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()

        let sortDescriptor = NSSortDescriptor(key: #keyPath(Movie.title), ascending: true)
        featchRequest.sortDescriptors = [sortDescriptor]

        do {
            // 2
            let movies = try self.context.fetch(featchRequest)
            // 3
            return movies.map { $0.getMovie() }
        } catch {
            Swift.debugPrint(error.localizedDescription)
            return []
        }
    }

    func delite(_ movies: [MWMovie]) {
        movies.forEach { movie in
            self.context.delete(self.getCoreDataObject(from: movie))
        }
        self.saveContext()
    }


    @discardableResult
    private func getCoreDataObject(from movie: MWMovie) -> Movie {
        let coreDataMovie = Movie(context: self.context)
        coreDataMovie.set(movie)

        return coreDataMovie
    }
}
