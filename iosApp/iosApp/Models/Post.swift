
import Foundation
import CoreData

@objc(Post)
public class Post: NSManagedObject {

    @NSManaged public var userId: Int64
    @NSManaged public var title: String?
    @NSManaged public var content: String?

}

extension Post {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }
}
