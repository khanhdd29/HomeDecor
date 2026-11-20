//
//  ArtMagicService+Catalog.swift
//

import Foundation

extension ArtMagicService {

    /// The catalog as screen rows: each category (of one group, or all) with its first templates. Templates load in
    /// parallel; a category whose templates fail to load is skipped. Throws when the categories can't be fetched or
    /// understood, or when no category ends up with templates.
    func sections(groupCode: String? = nil, categorySize: Int = 10, templateSize: Int = 6) async throws -> [HomeSection] {
        let payload = try await categories(page: 0, size: categorySize, groupCode: groupCode)
        let categories = HomeContentParser.categories(from: payload)
        guard !categories.isEmpty else {
            let error = CatalogError.unrecognized("categories", in: payload)
            #if DEBUG
            // The server answered but listed nothing: also show what it has without a category filter, to tell
            // "this app has no catalog" from "the filter is wrong".
            func body(_ payload: Any) -> Any { (payload as? [String: Any])?["data"] ?? payload }
            let groups = (try? await categoryGroups()).map { CatalogError.preview(body($0), limit: 200) } ?? "error"
            let all = (try? await templates(page: 0, size: 3)).map { CatalogError.preview(body($0), limit: 200) } ?? "error"
            throw CatalogError(message: error.message + "\ngroups: \(groups)\ntemplates: \(all)")
            #else
            throw error
            #endif
        }

        var byIndex: [Int: HomeSection] = [:]
        var firstProblem: Error?
        await withTaskGroup(of: (Int, Result<HomeSection, Error>).self) { group in
            for (index, category) in categories.enumerated() {
                group.addTask { [service = self] in
                    do {
                        let payload = try await service.templates(page: 0, size: templateSize, category: category.id)
                        let templates = HomeContentParser.templates(from: payload)
                        guard !templates.isEmpty else { throw CatalogError.unrecognized("templates for \(category.id)", in: payload) }
                        return (index, .success(HomeSection(category: category, templates: templates)))
                    } catch {
                        return (index, .failure(error))
                    }
                }
            }
            for await (index, result) in group {
                switch result {
                case .success(let section): byIndex[index] = section
                case .failure(let error): firstProblem = firstProblem ?? error
                }
            }
        }
        let result = byIndex.keys.sorted().compactMap { byIndex[$0] }
        if result.isEmpty, let firstProblem { throw firstProblem }
        return result
    }

    /// Every template of one category, page by page (50 per page, at most 20 pages).
    func allTemplates(category: String, pageSize: Int = 50) async throws -> [HomeTemplate] {
        var all: [HomeTemplate] = []
        for page in 0..<20 {
            let payload = try await templates(page: page, size: pageSize, category: category)
            all += HomeContentParser.templates(from: payload)
            let hasNext = ((payload as? [String: Any])?["page"] as? [String: Any])?["has_next"] as? Bool
            if hasNext != true { break }
        }
        return all
    }

    /// The server's code of the category group whose code or name contains `keyword` ("inside" finds `INSIDE`), so the
    /// app doesn't hardcode codes the server may change. Throws when no group matches.
    func groupCode(containing keyword: String) async throws -> String {
        let payload = try await categoryGroups()
        let group = HomeContentParser.groups(from: payload).first { [$0.id, $0.name].contains { $0.localizedCaseInsensitiveContains(keyword) } }
        guard let group else { throw CatalogError.unrecognized("\(keyword) group", in: payload) }
        return group.id
    }
}
