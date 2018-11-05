import XCTest

/*-------- Formatter Performance ---------*/

class DateConverter {
    func convertDateWithUniqueFormatter(_ dates: [Date]) {
        for date in dates {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            _ = dateFormatter.string(from: date)
        }
    }
    
    func convertDateWithReusedFormatter(_ dates: [Date]) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        for date in dates {
            _ = dateFormatter.string(from: date)
        }
    }
}

class DateConverterTests: XCTestCase {
    var sut: DateConverter!
    let dates = Array(repeating: Date(), count: 100)
    
    override func setUp() {
        super.setUp()
        sut = DateConverter()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_convertDateWithUniqueFormatter_performance() {
        
        self.measure {
            sut.convertDateWithUniqueFormatter(dates)
        }
    }
    
    func test_convertDateWithReusedFormatter_performance() {
        
        self.measure {
            sut.convertDateWithReusedFormatter(dates)
        }
    }
}

DateConverterTests.defaultTestSuite.run()

/*-------- Pass-by-reference Vs Pass-by-value ---------*/

struct PersonValueTypeExample: CustomStringConvertible {
    var name: String
    var age: Int
    
    var description: String {
        return ("name: \(name), age: \(age)")
    }
}

var a = PersonValueTypeExample(name: "Susie", age: 29)
var b = a
b.name = "Samantha"
a.age = 56

print("a: \(a)") // prints "a: name: Susie, age: 56"
print("b: \(b)") // prints "b: name: Samantha, age: 29"

class PersonReferenceTypeExample: CustomStringConvertible {
    var name: String
    var age: Int
    
    var description: String {
    return ("name: \(name), age: \(age)")
    }
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

let c = PersonReferenceTypeExample(name: "Susie", age: 29)
var d = c
d.name = "Samantha"
c.age = 56

print("c: \(c)") // prints "c: name: Samantha, age: 56"
print("d: \(d)") // prints "d: name: Samantha, age: 56"

/*-------- Singleton Date Formatter Helper ---------*/

private protocol DateFormatterType {
    func string(from date: Date) -> String
}

extension DateFormatter: DateFormatterType { }

class DateFormatingHelper {
    
    // MARK: - Shared
    
    static let shared = DateFormatingHelper()
    
    // MARK: - Formatters
    
    private let dobDateFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd @ HH:mm"
        
        return dateFormatter
    }()
    
    private let dayMonthTimeDateFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd MMM @ HH:mm"
        
        return dateFormatter
    }()
    
    private let hourMinuteDateFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    
    private let dayMonthYearDateFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "d MMM 'of' yyyy"
        
        return dateFormatter
    }()
    
    // MARK: - DOB
    
    func formatDOBDate(_ date: Date) -> String {
        let formattedDate = dobDateFormatter.string(from: date)
        return ("Date of birth: \(formattedDate)")
    }
    
    // MARK: - Account
    
    func formatLastActiveDate(_ date: Date, now: Date = Date()) -> String {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        
        var dateFormatter = dayMonthTimeDateFormatter
        if date > yesterday {
            dateFormatter = hourMinuteDateFormatter
        }
        
        let formattedDate = dateFormatter.string(from: date)
        return ("Last active: \(formattedDate)")
    }
    
    // MARK: - Post
    
    func formatPostCreateddate(_ date: Date) -> String {
        let formattedDate = dayMonthYearDateFormatter.string(from: date)
        return formattedDate
    }
    
    // MARK: - Commenting
    
    func formatCommenteddate(_ date: Date) -> String {
        let formattedDate = dayMonthTimeDateFormatter.string(from: date)
        return ("Comment posted: \(formattedDate)")
    }
}

extension Date {

    static func dateFrom(year: Int, month: Int,  day: Int, hour: Int = 0, minute: Int = 0, second: Int = 0) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = Calendar.current.timeZone

        return Calendar.current.date(from: components)
    }
}

class DateFormatingHelperTests: XCTestCase {

    func test_formatDOBDate_formatted() {
        let dob = Date.dateFrom(year: 1992, month: 6, day: 23, hour: 4, minute: 56)!

        let formattedDate = DateFormatingHelper.shared.formatDOBDate(dob)

        XCTAssertEqual(formattedDate, "Date of birth: 1992/06/23 @ 04:56")
    }

    func test_formatLastActivityDate_yesterday() {
        let now = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let earlierToday = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 9, minute: 28)!

        let formattedDate = DateFormatingHelper.shared.formatLastActiveDate(earlierToday, now: now)

        XCTAssertEqual(formattedDate, "Last active: 09:28")
    }

    func test_formatLastActivityDate_7DaysAgo() {
        let now = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let sevenDaysAgo = Date.dateFrom(year: 2018, month: 8, day: 11, hour: 9, minute: 28)!

        let formattedDate = DateFormatingHelper.shared.formatLastActiveDate(sevenDaysAgo, now: now)

        XCTAssertEqual(formattedDate, "Last active: 11 Aug @ 09:28")
    }

    func test_formatPostCreateddate_formatted() {
        let postCreated = Date.dateFrom(year: 1992, month: 6, day: 23, hour: 17, minute: 6)!

        let formattedDate = DateFormatingHelper.shared.formatPostCreateddate(postCreated)

        XCTAssertEqual(formattedDate, "23 Jun of 1992")
    }

    func test_formatCommenteddate_formatted() {
        let commented = Date.dateFrom(year: 2018, month: 11, day: 9, hour: 4, minute: 56)!

        let formattedDate = DateFormatingHelper.shared.formatCommenteddate(commented)

        XCTAssertEqual(formattedDate, "Comment posted: 09 Nov @ 04:56")
    }
}

DateFormatingHelperTests.defaultTestSuite.run()

/*-------- Cached Singleton Date Formatter Helper ---------*/

class CacheddateFormatingHelper {

    // MARK: - Shared

    static let shared = CacheddateFormatingHelper()

    // MARK: - Cached Formatters

    private var cacheddateFormatters = [String : DateFormatterType]()

    private func cacheddateFormatter(withFormat format: String) -> DateFormatterType {
        let key = format
        if let cachedFormatter = cacheddateFormatters[key] {
            return cachedFormatter
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format

        cacheddateFormatters[key] = formatter

        return formatter
    }

    // MARK: - DOB

    func formatDOBDate(_ date: Date) -> String {
        let dateFormatter = cacheddateFormatter(withFormat: "yyyy/MM/dd @ HH:mm")
        let formattedDate = dateFormatter.string(from: date)
        return ("Date of birth: \(formattedDate)")
    }

    // MARK: - Account

    func formatLastActiveDate(_ date: Date, now: Date = Date()) -> String {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        var dateFormatter = cacheddateFormatter(withFormat: "dd MMM @ HH:mm")
        if date > yesterday {
            dateFormatter = cacheddateFormatter(withFormat: "HH:mm")
        }

        let formattedDate = dateFormatter.string(from: date)
        return ("Last active: \(formattedDate)")
    }

    // MARK: - Post

    func formatPostCreateddate(_ date: Date) -> String {
        let dateFormatter = cacheddateFormatter(withFormat: "d MMM 'of' yyyy")
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    // MARK: - Commenting

    func formatCommenteddate(_ date: Date) -> String {
        let dateFormatter = cacheddateFormatter(withFormat: "d MMM 'of' yyyy")
        let formattedDate = dateFormatter.string(from: date)
        return ("Comment posted: \(formattedDate)")
    }
}

class CacheddateFormatingHelperTests: XCTestCase {
    
    func test_formatDOBDate_formatted() {
        let dob = Date.dateFrom(year: 1992, month: 6, day: 23, hour: 4, minute: 56)!
        
        let formattedDate = CacheddateFormatingHelper.shared.formatDOBDate(dob)
        
        XCTAssertEqual(formattedDate, "Date of birth: 1992/06/23 @ 04:56")
    }
    
    func test_formatLastActivityDate_yesterday() {
        let now = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let earlierToday = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 9, minute: 28)!
        
        let formattedDate = DateFormatingHelper.shared.formatLastActiveDate(earlierToday, now: now)
        
        XCTAssertEqual(formattedDate, "Last active: 09:28")
    }
    
    func test_formatLastActivityDate_7DaysAgo() {
        let now = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let sevenDaysAgo = Date.dateFrom(year: 2018, month: 8, day: 11, hour: 9, minute: 28)!
        
        let formattedDate = DateFormatingHelper.shared.formatLastActiveDate(sevenDaysAgo, now: now)
        
        XCTAssertEqual(formattedDate, "Last active: 11 Aug @ 09:28")
    }
    
    func test_formatPostCreateddate_formatted() {
        let postCreated = Date.dateFrom(year: 1992, month: 6, day: 23, hour: 17, minute: 6)!
        
        let formattedDate = DateFormatingHelper.shared.formatPostCreateddate(postCreated)
        
        XCTAssertEqual(formattedDate, "23 Jun of 1992")
    }
    
    func test_formatCommenteddate_formatted() {
        let commented = Date.dateFrom(year: 2018, month: 11, day: 9, hour: 4, minute: 56)!
        
        let formattedDate = DateFormatingHelper.shared.formatCommenteddate(commented)
        
        XCTAssertEqual(formattedDate, "Comment posted: 09 Nov @ 04:56")
    }
}

CacheddateFormatingHelperTests.defaultTestSuite.run()
