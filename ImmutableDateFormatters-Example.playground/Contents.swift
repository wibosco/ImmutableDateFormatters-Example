import UIKit
import XCTest

extension Date {
    static func randomWithinDaysBeforeToday(_ days: Int) -> Date {
        let today = Date()
        let earliest = today.addingTimeInterval(TimeInterval(-days*24*60*60))
        
        return Date.random(between: earliest, and: today)
    }
    
    static func random(between initial: Date, and final:Date) -> Date {
        let interval = final.timeIntervalSince(initial)
        let randomInterval = TimeInterval(arc4random_uniform(UInt32(interval)))
        return initial.addingTimeInterval(randomInterval)
    }
}

class RandomDateGenerator {
    
    static func generate(numberToBeGenerated count: Int) -> [Date] {
        var dates = [Date]()
        for _ in 0..<count {
            let date = Date.randomWithinDaysBeforeToday(5000)
            dates.append(date)
        }
        
        return dates
    }
}

/*-------- Formatter Performance ---------*/

class DateConverter {
    let dates = RandomDateGenerator.generate(numberToBeGenerated: 100)
    
    func convertDateWithUniqueFormatter() {
        for date in dates {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY/MM/DD"
            
            _ = formatter.string(from: date)
        }
    }
    
    func convertDateWithReusedFormatter() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/DD"
        
        for date in dates {
            _ = formatter.string(from: date)
        }
    }
}

class DateConverterTests: XCTestCase {
    var sut: DateConverter!
    
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
            sut.convertDateWithUniqueFormatter()
        }
    }
    
    func test_convertDateWithReusedFormatter_performance() {
        
        self.measure {
            sut.convertDateWithReusedFormatter()
        }
    }
}

DateConverterTests.defaultTestSuite.run()

/*-------- Date Formatter Helper ---------*/

class DateFormatterHelper {
    
    // MARK: - Formatters
    
    private static let numericalDayMonthYearFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yyyy"
        
        return dateFormatter
    }()
    
    private static let longMonthFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter
    }()
    
    private static let shortMonthWithTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy @ HH:mm"
        
        return dateFormatter
    }()
    
    // MARK: - User
    
    static func string(forDOB date: Date) -> String {
        let formatter = numericalDayMonthYearFormatter
        return formatter.string(from: date)
    }
    
    static func string(forAccountCreationDate date: Date) -> String {
        let formatter = numericalDayMonthYearFormatter
        return formatter.string(from: date)
    }
    
    // MARK: - Post
    
    static func string(forPostedDate date: Date) -> String {
        let formatter = longMonthFormatter
        return formatter.string(from: date)
    }
    
    // MARK: - Comment
    
    static func string(forCommentedDate date: Date) -> String {
        let formatter = shortMonthWithTimeFormatter
        return formatter.string(from: date)
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

class DateFormatterHelperTests: XCTestCase {
    
    func test_forDOB_converted() {
        let date = Date.dateFrom(year: 1998, month: 8, day: 23)!
        let formattedDate = DateFormatterHelper.string(forDOB: date)
        
        XCTAssertEqual(formattedDate, "23/8/1998")
    }
    
    func test_forAccountCreationDate_converted() {
        let date = Date.dateFrom(year: 2017, month: 11, day: 3)!
        let formattedDate = DateFormatterHelper.string(forAccountCreationDate: date)
        
        XCTAssertEqual(formattedDate, "3/11/2017")
    }
    
    func test_forPostedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18)!
        let formattedDate = DateFormatterHelper.string(forPostedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018")
    }
    
    func test_forCommentedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let formattedDate = DateFormatterHelper.string(forCommentedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018 @ 14:56")
    }
}

DateFormatterHelperTests.defaultTestSuite.run()

/*-------- Immutable Date Formatters ---------*/

private protocol DateFormatterType {
    func string(from date: Date) -> String
    func date(from string: String) -> Date?
}
extension DateFormatter: DateFormatterType { }

class ImmutableDateFormatterHelper {
    
    // MARK: - Formatters
    
    private static let numericalDayMonthYearFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yyyy"
        
        return dateFormatter
    }()
    
    private static let longMonthFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        return dateFormatter
    }()
    
    private static let shortMonthWithTimeFormatter: DateFormatterType = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy @ HH:mm"
        
        return dateFormatter
    }()
    
    // MARK: - User
    
    static func string(forDOB date: Date) -> String {
        let formatter = numericalDayMonthYearFormatter
        return formatter.string(from: date)
    }
    
    static func string(forAccountCreationDate date: Date) -> String {
        let formatter = numericalDayMonthYearFormatter
        return formatter.string(from: date)
    }
    
    // MARK: - Post
    
    static func string(forPostedDate date: Date) -> String {
        let formatter = longMonthFormatter
        return formatter.string(from: date)
    }
    
    // MARK: - Comment
    
    static func string(forCommentedDate date: Date) -> String {
        let formatter = shortMonthWithTimeFormatter
        return formatter.string(from: date)
    }
}

class ImmutableDateFormatterHelperTests: XCTestCase {
    
    func test_forDOB_converted() {
        let date = Date.dateFrom(year: 1998, month: 8, day: 23)!
        let formattedDate = DateFormatterHelper.string(forDOB: date)
        
        XCTAssertEqual(formattedDate, "23/8/1998")
    }
    
    func test_forAccountCreationDate_converted() {
        let date = Date.dateFrom(year: 2017, month: 11, day: 3)!
        let formattedDate = DateFormatterHelper.string(forAccountCreationDate: date)
        
        XCTAssertEqual(formattedDate, "3/11/2017")
    }
    
    func test_forPostedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18)!
        let formattedDate = DateFormatterHelper.string(forPostedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018")
    }
    
    func test_forCommentedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let formattedDate = DateFormatterHelper.string(forCommentedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018 @ 14:56")
    }
}

ImmutableDateFormatterHelperTests.defaultTestSuite.run()

/*-------- Cached Imuutable Date Formatters ---------*/

class ImmutableCachedDateFormatterHelper {
    
    private static var cachedDateFormatters = [String : DateFormatterType]()
    
    // MARK: - Cached Formatters
    
    private static func cachedDateFormatter(withFormat format: String) -> DateFormatterType {
        let key = format
        if let cachedFormatter = cachedDateFormatters[key] {
            return cachedFormatter
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        cachedDateFormatters[key] = formatter
        
        return formatter
    }
    
    // MARK: - User
    
    static func string(forDOB date: Date) -> String {
        let formatter = ImmutableCachedDateFormatterHelper.cachedDateFormatter(withFormat: "d/M/yyyy")
        return formatter.string(from: date)
    }
    
    static func string(forAccountCreationDate date: Date) -> String {
        let formatter = ImmutableCachedDateFormatterHelper.cachedDateFormatter(withFormat: "d/M/yyyy")
        return formatter.string(from: date)
    }
    
    // MARK: - Post
    
    static func string(forPostedDate date: Date) -> String {
        let formatter = ImmutableCachedDateFormatterHelper.cachedDateFormatter(withFormat: "MMM d, yyyy")
        return formatter.string(from: date)
    }
    
    // MARK: - Comment
    
    static func string(forCommentedDate date: Date) -> String {
        let formatter = ImmutableCachedDateFormatterHelper.cachedDateFormatter(withFormat: "MMM d, yyyy @ HH:mm")
        return formatter.string(from: date)
    }
}

class ImmutableCachedDateFormatterHelperTests: XCTestCase {
    
    func test_forDOB_converted() {
        let date = Date.dateFrom(year: 1998, month: 8, day: 23)!
        let formattedDate = DateFormatterHelper.string(forDOB: date)
        
        XCTAssertEqual(formattedDate, "23/8/1998")
    }
    
    func test_forAccountCreationDate_converted() {
        let date = Date.dateFrom(year: 2017, month: 11, day: 3)!
        let formattedDate = DateFormatterHelper.string(forAccountCreationDate: date)
        
        XCTAssertEqual(formattedDate, "3/11/2017")
    }
    
    func test_forPostedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18)!
        let formattedDate = DateFormatterHelper.string(forPostedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018")
    }
    
    func test_forCommentedDate_converted() {
        let date = Date.dateFrom(year: 2018, month: 8, day: 18, hour: 14, minute: 56)!
        let formattedDate = DateFormatterHelper.string(forCommentedDate: date)
        
        XCTAssertEqual(formattedDate, "Aug 18, 2018 @ 14:56")
    }
}

ImmutableCachedDateFormatterHelperTests.defaultTestSuite.run()
