
import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {

    @NSManaged public var name: String?
    @NSManaged public var email: String?

}

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
}
