
public protocol Logger {
    
    func debug(_ msg: String)

    func info(_ msg: String)

    func warn(_ msg: String)

    func error(_ msg: String)
}


// Log provides direct access to log messages.
public class Log {
    
    // Logger used to format and write log messages.
    public static var logger: Logger? {
        didSet {
            
        }
    }
    
    // Prints a trace message to the relevant IO stream(s).
    public static func trace(_ msg: String) {
        self.logger?.debug(msg)
    }
    
    // Prints an information message to the relevant IO stream(s).
    public static func info(_ msg: String) {
        self.logger?.info(msg)
    }
    
    // Prints a warning message to the reelvant IO stream(s).
    public static func warn(_ msg: String) {
        self.logger?.info(msg)
    }
    
    // Prints an error message to the relevant IO stream(s).
    public static func error(_ msg: String) {
        self.logger?.error(msg)
    }
}
