//
//  Logger.swift
//  SurveyNative
//
//  Created by Nora Mullaney on 2/21/17.
//  Copyright © 2017 Recovery Record. All rights reserved.
//

import os.log

public enum LogLevel : Int {
   case debug, warning, info, error, fault
}

public class Logger: NSObject {

   // Sets the default for the print messages (the osLog message logLevel allows you to filter later, but
   // does not affect what is logged)
   #if DEBUG
   static let defaultLogLevel = LogLevel.fault
   #else
   static let defaultLogLevel = LogLevel.error
   #endif
   
   @available(iOS 10.0, *)
   static let osLog = OSLog.init(subsystem: "com.guardiansd.recoveryrecord", category: "questionnaire")
   
   public class func log(_ message: CVarArg, level : LogLevel = .debug) {
      if #available(iOS 10.0, *) {
            os_log("%@", log: osLog, type: osLogType(level), message)
      } else {
         if level.rawValue >= defaultLogLevel.rawValue {
            print(message)
         }
      }
   }
   
   @available(iOS 10.0, *)
   class func osLogType(_ logLevel :  LogLevel) -> OSLogType {
      switch logLevel {
      case .debug :
         return OSLogType.debug
      case .warning :
         return OSLogType.default
      case .info :
         return OSLogType.info
      case .error:
         return OSLogType.error
      case .fault:
         return OSLogType.fault
      }
   }
}
