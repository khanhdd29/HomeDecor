//
//  Self-check of the three parsers. Run: Checks/run.sh   (needs only Xcode's swiftc, no iOS SDK, no network)
//
//  The payloads below are SYNTHETIC: they follow the shapes the app was written against
//  (`{status, data, page}`), not captured server answers. Passing here means the parsers do what they say;
//  it does NOT prove the real server answers look like this. Check that with the smoke test in README.
//

import Foundation

var failures = 0
func check(_ ok: Bool, _ what: String, line: Int = #line) {
    if !ok { failures += 1; print("FAIL (line \(line)): \(what)") }
}
func json(_ text: String) -> Any { try! JSONSerialization.jsonObject(with: Data(text.utf8)) }

// MARK: GenerationParser

let done = json(#"{"status":{"code":200,"requestId":"call-1"},"data":{"resultUrl":"https://cdn.example/out.jpg","originalUrl":"https://cdn.example/in.jpg"}}"#)
check(GenerationParser.imageURL(in: done)?.absoluteString == "https://cdn.example/out.jpg", "picks resultUrl, not the original")

let pending = json(#"{"status":{"code":200,"requestId":"call-1"},"data":{"requestId":"job-9","status":"PROCESSING"}}"#)
check(GenerationParser.imageURL(in: pending) == nil, "no URL while processing")
check(GenerationParser.requestId(in: pending) == "job-9", "poll id is data.requestId, not status.requestId")
check(GenerationParser.requestId(in: json(#"{"status":{"requestId":"call-1"},"data":{}}"#)) == nil, "status.requestId is not a poll id")

let nested = json(#"{"data":{"output":{"images":[{"url":"https://cdn.example/a.jpg"}]},"input":{"url":"https://cdn.example/in.jpg"}}}"#)
check(GenerationParser.imageURL(in: nested)?.absoluteString == "https://cdn.example/a.jpg", "finds nested URL, skips input")
check(GenerationParser.imageURL(in: json(#"{"data":{"image":"not-a-url"}}"#)) == nil, "ignores non-http text")

// MARK: HomeContentParser

let templates = json(#"""
{"status":{"code":200},"data":[
  {"code":"home_decor_japan","categoryCode":"LIVING","displayName":"Japan","imageUrl":"https://cdn.example/jp.jpg","premium":true},
  {"code":"no_picture","displayName":"Skipped"},
  {"code":"wabi","name":"Wabi Sabi","thumbnail":"https://cdn.example/wabi.jpg"}
],"page":{"has_next":false}}
"""#)
let parsed = HomeContentParser.templates(from: templates)
check(parsed.map(\.id) == ["home_decor_japan", "wabi"], "drops a template without a picture")
check(parsed.first?.isPremium == true && parsed.last?.isPremium == false, "premium flag, default false")
check(parsed.first?.name == "Japan", "displayName wins")

let cats = HomeContentParser.categories(from: json(#"{"data":[{"code":"LIVING","name":"Living room"},{"categoryCode":"BATH"}]}"#))
check(cats.map(\.id) == ["LIVING", "BATH"] && cats.last?.name == "BATH", "categories, name falls back to code")

let groups = HomeContentParser.groups(from: json(#"{"data":[{"groupCode":"INSIDE","groupName":"Inside"}]}"#))
check(groups.first?.id == "INSIDE", "groups read groupCode")
check(HomeContentParser.templates(from: json(#"{"unexpected":true}"#)).isEmpty, "unknown shape gives an empty list")

// MARK: ChatReplyParser

check((try? ChatReplyParser.reply(in: json(#"{"status":{"code":200},"data":{"content":"  Hello **there**  "}}"#))) == "Hello **there**", "reads and trims data.content")
do {
    _ = try ChatReplyParser.reply(in: json(#"{"status":{"code":401,"message":"bad key"},"data":null}"#))
    check(false, "an error status must throw")
} catch { check(error.localizedDescription == "bad key", "throws the server's message") }
do {
    _ = try ChatReplyParser.reply(in: json(#"{"status":{"code":200},"data":{"content":"   "}}"#))
    check(false, "an empty reply must throw")
} catch { check(error.localizedDescription.hasPrefix("No reply in:"), "empty reply is reported as unrecognized") }

print(failures == 0 ? "OK: all parser checks passed" : "\(failures) check(s) failed")
exit(failures == 0 ? 0 : 1)
