
/// Protocol for the logger used by Kauppa.
public protocol Logger {

    /// Writes a debug message to the relevant IO stream(s).
    func debug(_ msg: String, functionName: String, lineNum: Int, filePath: String)

    /// Writes an information message to the relevant IO stream(s).
    func info(_ msg: String, functionName: String, lineNum: Int, filePath: String)

    /// Writes a warning message to the reelvant IO stream(s).
    func warn(_ msg: String, functionName: String, lineNum: Int, filePath: String)

    /// Writes an error message to the relevant IO stream(s).
    func error(_ msg: String, functionName: String, lineNum: Int, filePath: String)
}


/// Log provides direct access to the underlying logger methods.
public class Log {

    /// Logger (implementing `Logger`) used to format and write log messages.
    public static var logger: Logger? = nil

    public static func debug(_ msg: String,
                             functionName: String = #function,
                             lineNum: Int = #line,
                             filePath: String = #file)
    {
        self.logger?.debug(msg, functionName: functionName, lineNum: lineNum, filePath: filePath)
    }

    public static func info(_ msg: String,
                             functionName: String = #function,
                             lineNum: Int = #line,
                             filePath: String = #file)
    {
        self.logger?.info(msg, functionName: functionName, lineNum: lineNum, filePath: filePath)
    }

    public static func warn(_ msg: String,
                             functionName: String = #function,
                             lineNum: Int = #line,
                             filePath: String = #file)
    {
        self.logger?.warn(msg, functionName: functionName, lineNum: lineNum, filePath: filePath)
    }

    public static func error(_ msg: String,
                             functionName: String = #function,
                             lineNum: Int = #line,
                             filePath: String = #file)
    {
        self.logger?.error(msg, functionName: functionName, lineNum: lineNum, filePath: filePath)
    }
}
