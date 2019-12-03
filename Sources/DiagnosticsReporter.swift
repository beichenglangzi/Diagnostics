//
//  DiagnosticsReporter.swift
//  Diagnostics
//
//  Created by Antoine van der Lee on 02/12/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

import Foundation

public protocol DiagnosticsReporting {
    static func report() -> DiagnosticsChapter
}

public struct DiagnosticsChapter {
    public let title: String
    public let diagnostics: Diagnostics
}

public enum DiagnosticsReporter {

    public enum DefaultReporter: CaseIterable {
        case generalInfo
        case appSystemMetadata
        case logs
        case userDefaults

        var reporter: DiagnosticsReporting.Type {
            switch self {
            case .generalInfo:
                return GeneralInfoReporter.self
            case .appSystemMetadata:
                return AppSystemMetadataReporter.self
            case .logs:
                return LogsReporter.self
            case .userDefaults:
                return UserDefaultsReporter.self
            }
        }

        public static var allReporters: [DiagnosticsReporting.Type] {
            allCases.map { $0.reporter }
        }
    }

    public static func create(using reporters: [DiagnosticsReporting.Type] = DefaultReporter.allReporters) -> DiagnosticsReport {
        var html = "<html>"
        html += header()

        reporters.forEach { (reporter) in
            html += reporter.report().html()
        }

        let data = html.data(using: .utf8)!
        return DiagnosticsReport(filename: "DiagnosticsReport.html", data: data)
    }

    private static func header() -> HTML {
        var html = "<head>"
        html += "<title>\(Bundle.appName) - Diagnostics Report</title>"
        html += style()
        html += "</head>"
        return html
    }

    private static func style() -> HTML {
        let bundle = Bundle(for: DiagnosticsLogger.self)
        let cssFile = bundle.url(forResource: "style", withExtension: "css")!
        let css = try! String(contentsOf: cssFile, encoding: .utf8).minifiedCSS()

        return "<style>\(css)</style>"
    }
}

private extension String {
    func minifiedCSS() -> String {
        let components = filter { !$0.isNewline }.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}