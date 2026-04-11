//
//  AppGroup.swift
//  LietLibrary
//
//  Created by Hiromu Nakano on 2026/03/23.
//

import Foundation

/// Shared App Group identifiers and resolved container locations.
public enum AppGroup {
    /// App Group identifier shared by the app and future extensions.
    public static let id = "group.com.muhiro12.Liet"
    /// Root container URL for the shared App Group.
    public static let containerURL: URL = {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: id
        ) else {
            preconditionFailure("Failed to resolve App Group container URL.")
        }
        return url
    }()

    /// Resolves the shared `UserDefaults` suite from the app group.
    public static func userDefaults() -> UserDefaults {
        guard let userDefaults = UserDefaults(
            suiteName: id
        ) else {
            preconditionFailure("Failed to resolve App Group user defaults.")
        }
        return userDefaults
    }
}
