import Foundation

@main
enum TestSubtitles {
    static func main() {
        let srt = "\u{FEFF}1\r\n00:00:01,000 --> 00:00:03,500\r\nHello, <i>world</i>\r\nsecond line\r\n\r\n2\r\n00:00:04,000 --> 00:00:06,000 X1:100 X2:200\r\n{\\an8}Top &amp; <b>bold</b>\r\n\r\n\r\n\r\n3\r\n01:02:03,004 --> 01:02:05,000\r\n- One\r\n- Two\r\n"
        let cues = SubtitleParser.parse(srt)
        precondition(cues.count == 3, "\(cues)")
        precondition(cues[0].start == 1 && cues[0].end == 3.5 && SubtitleText.plain(cues[0].text) == "Hello, world\nsecond line", "\(cues[0])")
        precondition(SubtitleText.spans(cues[0].text) == [SubtitleSpan(text: "Hello, ", italic: false, bold: false), SubtitleSpan(text: "world", italic: true, bold: false), SubtitleSpan(text: "\nsecond line", italic: false, bold: false)])
        precondition(SubtitleText.plain(cues[1].text) == "Top & bold" && SubtitleText.spans(cues[1].text).last == SubtitleSpan(text: "bold", italic: false, bold: true))
        precondition(abs(cues[2].start - 3723.004) < 0.0001 && SubtitleText.plain(cues[2].text) == "- One\n- Two")
        print("SubRip with a BOM and CRLF: times, tags, entities, positions: ok")

        let glued = SubtitleParser.parse("1\n00:00:01,000 --> 00:00:02,000\nA\n2\n00:00:03,000 --> 00:00:04,000\nB\n1984\n00:00:05,000 --> 00:00:06,000\nC")
        precondition(glued.map(\.text) == ["A", "B", "C"], "\(glued)")
        let dotted = SubtitleParser.parse("00:00:01.5 --> 00:00:02.25\nDot separator\n")
        precondition(dotted.count == 1 && dotted[0].start == 1.5 && dotted[0].end == 2.25)
        print("cues without blank lines, a line that is only digits, dot separators: ok")

        let broken = "1\n00:00:xx,000 --> 00:00:03,000\nbad start\n\n2\n00:00:05,000 --> 00:00:04,000\nends before start\n\n3\n00:00:06,000 --> \nno end\n\n4\n--> 00:00:07,000\nno start\n\n5\n00:00:08,000 --> 00:00:09,000\n\n\n6\n00:00:10,000 --> 00:00:11,000\nfine\n\n7\n99999999999:00:00,000 --> 99999999999:00:01,000\nhuge\n"
        precondition(SubtitleParser.parse(broken).map(\.text) == ["fine"], "\(SubtitleParser.parse(broken))")
        precondition(SubtitleParser.parse("").isEmpty && SubtitleParser.parse("\n\n\n").isEmpty && SubtitleParser.parse("just some text\nwithout times").isEmpty)
        print("broken times, empty cues, empty file: ok")

        let vtt = "WEBVTT - title\nKind: captions\n\nNOTE this is a comment\n--> not a cue\n\nSTYLE\n::cue { color: red }\n\nintro\n00:01.000 --> 00:03.000 align:start position:10%\n<v Roger>Hello <c.yellow>there</c> <00:00:02.000>again\n\n01:00:00.000 --> 01:00:01.000\nHour cue\n"
        let web = SubtitleParser.parse(vtt)
        precondition(web.map(\.text) == ["Hello there again", "Hour cue"] && web[0].start == 1 && web[1].start == 3600, "\(web)")
        print("WebVTT: header, notes, styles, identifiers, voices, short times: ok")

        let script = "[Script Info]\nTitle: x\n\n[V4+ Styles]\nFormat: Name, Fontname\nStyle: Default,Arial\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,{\\an8\\k20}Karaoke\n"
        precondition(SubtitleParser.isASS(script) && SubtitleParser.isASS("[Events]\nFormat: x") && SubtitleParser.isASS("junk\nDialogue: 0,1,2") && SubtitleParser.isASS(String(repeating: "\n", count: 300) + "[Script Info]"))
        precondition(!SubtitleParser.isASS("WEBVTT\n\n00:01.000 --> 00:02.000\nHello\n") && !SubtitleParser.isASS("") && !SubtitleParser.isASS(String(repeating: "x\n", count: 500) + "[Script Info]"))
        print("ASS detection: script info, events, dialogue lines, not in SRT or WebVTT: ok")

        let moov = Data([0, 5]) + Data("Hello".utf8) + Data([0, 0, 0, 8]) + Data("styl".utf8)
        precondition(SubtitleParser.movText(moov) == "Hello" && SubtitleParser.movText(Data([0, 0])) == nil && SubtitleParser.movText(Data([0])) == nil)
        precondition(SubtitleParser.movText(Data([0, 99]) + Data("short".utf8)) == "short")
        precondition(SubtitleParser.movText(Data([0, 6, 0xFE, 0xFF, 0, 0x48, 0, 0x69])) == "Hi")
        let payload = Data("Line &amp; two".utf8)
        func box(_ kind: String, _ body: Data) -> Data {
            var size = UInt32(8 + body.count).bigEndian
            return Data(bytes: &size, count: 4) + Data(kind.utf8) + body
        }
        precondition(SubtitleParser.webVTTBox(box("vttc", box("sttg", Data("align:start".utf8)) + box("payl", payload))) == "Line & two")
        precondition(SubtitleParser.webVTTBox(box("vtte", Data())) == nil && SubtitleParser.webVTTBox(Data([0, 0, 0, 200, 0x76])) == nil)
        print("mov_text and WebVTT-in-MP4 packets: ok")

        let russian = "1\n00:00:01,000 --> 00:00:03,000\nПривет, как дела? Всё хорошо, спасибо.\n\n2\n00:00:04,000 --> 00:00:06,000\nЯ иду домой.\n"
        let polish = "1\n00:00:01,000 --> 00:00:03,000\nZażółć gęślą jaźń. Dzień dobry, jak się masz?\n"
        let utf16 = russian.data(using: .utf16LittleEndian)!
        let encoded: [(String, Data, String)] = [
            ("UTF-8", Data(russian.utf8), russian), ("UTF-8 BOM", Data([0xEF, 0xBB, 0xBF]) + Data(russian.utf8), russian),
            ("UTF-16 LE BOM", Data([0xFF, 0xFE]) + utf16, russian), ("UTF-16 BE BOM", Data([0xFE, 0xFF]) + russian.data(using: .utf16BigEndian)!, russian),
            ("UTF-16 LE no BOM", utf16, russian), ("UTF-16 BE no BOM", russian.data(using: .utf16BigEndian)!, russian),
            ("cp1251", russian.data(using: .windowsCP1251)!, russian), ("cp1250", polish.data(using: .windowsCP1250)!, polish),
        ]
        for (name, data, expected) in encoded {
            let found = SubtitleParser.parse(data)
            precondition(found.map(\.text) == SubtitleParser.parse(expected).map(\.text) && found.count == (expected == russian ? 2 : 1), "\(name): \(found)")
        }
        print("encodings (UTF-8, BOM, UTF-16, cp1251, cp1250): ok")

        let overlapping = SubtitleCues([SubtitleCue(start: 10, end: 20, text: "long"), SubtitleCue(start: 12, end: 13, text: "short"), SubtitleCue(start: 30, end: 31, text: "later"), SubtitleCue(start: 0, end: 1, text: "first")])
        let probes: [(Double, String?)] = [(-1, nil), (0, "first"), (0.999, "first"), (1, nil), (9.9, nil), (10, "long"), (12.5, "long\nshort"), (13, "long"), (19.99, "long"), (20, nil), (25, nil), (30.5, "later"), (31, nil), (1000, nil)]
        for (time, text) in probes { precondition(overlapping.text(at: time) == text, "\(time) → \(overlapping.text(at: time) ?? "nil")") }
        precondition(overlapping.text(at: 10, delay: 0.1) == nil && overlapping.text(at: 10.1, delay: 0.1) == "long" && overlapping.text(at: 9.9, delay: -0.1) == "long")
        precondition(SubtitleCues([]).text(at: 5) == nil && SubtitleCues([]).isEmpty)
        print("the line for a moment of time: overlaps, gaps, shift: ok")

        precondition(SubtitleText.clean("a < b and c > d, <3 &unknown; &#65;&#x42; &") == "a < b and c > d, <3 &unknown; AB &")
        precondition(SubtitleText.clean("<font color=\"#ff0000\">red</font> <u>under</u>{broken") == "red under{broken")
        precondition(SubtitleText.clean("\u{E000}x\u{E003}") == "x" && SubtitleText.clean("   \n \n") == "")
        precondition(SubtitleText.clean("<i>one\ntwo</i>") == "\u{E000}one\ntwo\u{E001}" && SubtitleText.spans("\u{E000}one\ntwo\u{E001}").count == 1)
        precondition(SubtitleText.clean(String(repeating: "{", count: 100_000) + String(repeating: "<", count: 100_000)).count > 0)
        print("tags: markup stripped, stray < and & kept, long runs of brackets fast: ok")

        var generator = SystemRandomNumberGenerator()
        let started = Date()
        for round in 0..<300 {
            let size = round % 20 == 0 ? 200_000 : Int.random(in: 0..<2000, using: &generator)
            let bytes = (0..<size).map { _ in UInt8.random(in: 0...255, using: &generator) }
            _ = SubtitleParser.parse(Data(bytes))
            let texty = String(decoding: (0..<size).map { _ in Array(" -->:,.\n\r{}<>\\&;0123456789aN".utf8).randomElement()! }, as: UTF8.self)
            _ = SubtitleParser.parse(texty)
            _ = SubtitleParser.parse("[Events]\nDialogue:" + texty)
        }
        precondition(Date().timeIntervalSince(started) < 60, "random input is too slow")
        precondition(SubtitleParser.parse(Data(count: SubtitleParser.sizeLimit + 1)).isEmpty)
        print("random and damaged input: no crash, no hang (\(Int(Date().timeIntervalSince(started) * 1000)) ms): ok")

        precondition(PlayerTracks.language("rus") == "ru" && PlayerTracks.language("fre") == "fr" && PlayerTracks.language("ger") == "de" && PlayerTracks.language("pt-BR") == "pt" && PlayerTracks.language("en") == "en")
        precondition(PlayerTracks.language("und") == nil && PlayerTracks.language("") == nil && PlayerTracks.language(nil) == nil && PlayerTracks.language("zzzz") == nil)
        let english = Locale(identifier: "en")
        precondition(PlayerTracks.title(language: "eng", name: "Commentary", number: 2, locale: english) == "English — Commentary")
        precondition(PlayerTracks.title(language: "eng", name: "English", number: 2, locale: english) == "English")
        precondition(PlayerTracks.title(language: "rus", name: nil, number: 2, locale: english) == "Russian")
        precondition(PlayerTracks.title(language: "und", name: "Director", number: 2, locale: english) == "Director")
        precondition(PlayerTracks.title(language: nil, name: "  ", number: 3, locale: english) == String(localized: "Track \(3)"))
        precondition(PlayerTracks.preferred(among: ["eng", "rus", nil], system: ["ru-RU", "en-US"]) == 1)
        precondition(PlayerTracks.preferred(among: ["eng", "fre"], system: ["ru-RU", "fr-FR"]) == 1)
        precondition(PlayerTracks.preferred(among: ["eng", "fre"], system: ["ja-JP"]) == nil && PlayerTracks.preferred(among: [], system: ["ru"]) == nil)
        print("track names and the language of the system: ok")

        var saved: [String: [String]] = [:]
        for index in 0..<(PlayerChoices.limit + 5) { saved = PlayerChoices.updated(saved, key: "k\(index)", audio: "a1", subtitle: "off", delay: -0.3, at: Double(index)) }
        precondition(saved.count == PlayerChoices.limit && saved["k0"] == nil && saved["k204"] == ["a1", "off", "-0.3", "204.0"])
        precondition(PlayerChoices.delay(saved["k204"] ?? []) == -0.3 && PlayerChoices.delay(["a1", "off", "99.0"]) == 0 && PlayerChoices.delay([]) == 0)
        precondition(PlayerChoices.delay(["a1", "off", "nan", "9.0"]) == 0 && PlayerChoices.delay(["a1", "off", "text", "9.0"]) == 0)
        print("remembered track choices stay within the limit: ok")

        let video = URL(fileURLWithPath: "/m/Movie.mkv")
        let beside = ["Movie.srt", "movie.RU.vtt", "Movie.en.ass", "Movie2.srt", "Other.srt", "Movie.txt", "Movie.mkv"].map { URL(fileURLWithPath: "/m/" + $0) }
        precondition(SubtitleFiles.matching(video: video, among: beside).map(\.lastPathComponent) == ["Movie.en.ass", "movie.RU.vtt", "Movie.srt"])
        precondition(SubtitleFiles.matching(video: video, among: []).isEmpty)
        precondition(SubtitleStyle.clampedScale(0.1) == 0.5 && SubtitleStyle.clampedScale(9) == 3 && SubtitleStyle.clampedScale(1.04) == 1)
        precondition(SubtitleStyle.fontSize(forHeight: 1000, scale: 1) == 45 && SubtitleStyle.fontSize(forHeight: 100, scale: 0.5) == 12)
        print("subtitle files next to the video and the text size: ok")
    }
}
