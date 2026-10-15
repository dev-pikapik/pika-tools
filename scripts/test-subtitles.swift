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

        let ass = "[Script Info]\nTitle: x\n\n[V4+ Styles]\nFormat: Name, Fontname\nStyle: Default,Arial\n\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,{\\an8\\i1}Italic{\\i0}, with comma\\Nsecond\nComment: 0,0:00:01.00,0:00:02.50,Default,,0,0,0,,hidden\nDialogue: 0,0:00:03.00,0:00:04.00,Sign,,0,0,0,,{\\p1}m 0 0 l 100 100{\\p0}\nDialogue: 0,0:00:00.50,0:00:00.90,Default,,0,0,0,,{\\b1}Bold{\\b0}\\hText\nDialogue: 0,bad,0:00:05.00,Default,,0,0,0,,broken\n"
        let styled = SubtitleParser.parse(ass)
        precondition(styled.count == 2, "\(styled)")
        precondition(styled[0].start == 1 && styled[0].end == 2.5 && SubtitleText.plain(styled[0].text) == "Italic, with comma\nsecond" && SubtitleText.spans(styled[0].text)[0] == SubtitleSpan(text: "Italic", italic: true, bold: false), "\(styled[0])")
        precondition(SubtitleText.plain(styled[1].text) == "Bold\u{A0}Text" && styled[1].start == 0.5, "\(styled)")
        precondition(SubtitleParser.ass(packet: "12,0,Default,,0,0,0,,{\\i1}Hi, you{\\i0}\\Nthere") == "\u{E000}Hi, you\u{E001}\nthere")
        precondition(SubtitleParser.ass(packet: "12,0,Default") == nil && SubtitleParser.ass(packet: "1,0,Default,,0,0,0,,{\\p1}m 0 0{\\p0}") == nil)
        print("ASS: format line, commas in text, overrides, drawings, Matroska packets: ok")

        let header = "[Script Info]\nPlayResY: 480\n\n[V4+ Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding\nStyle: Default,Arial,40,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,3,0,2,10,10,20,1\nStyle: Top,Georgia,30,&H0000FF00,&H000000FF,&H00FF0000,&H00000000,0,-1,-1,0,100,100,0,0,1,1,0,8,15,15,25,1\n"
        let look = AssScript.styles(header)
        let normal = look.style(named: "Default")
        precondition(look.height == 480 && normal.size == 40 && normal.bold && normal.color == 0xFFFFFF && normal.outline == 0 && normal.outlineWidth == 3 && normal.alignment == 2 && normal.margins.v == 20 && normal.font == "Arial")
        let top = look.style(named: "top")
        precondition(top.italic && top.underline && !top.bold && top.color == 0x00FF00 && top.outline == 0x0000FF && top.alignment == 8 && top.font == "Georgia" && look.style(named: "Missing").size == 40 && look.style(named: "*Default").size == 40)
        precondition(AssScript.color("&H00FFFFFF") == 0xFFFFFF && AssScript.color("&HFF&") == 0xFF0000 && AssScript.color("&H0000FF&") == 0xFF0000 && AssScript.color("16711680") == 0x0000FF && AssScript.color("&Hzz&") == nil && AssScript.color("") == nil)
        let mixed = AssScript.block("{\\i1}slanted{\\i0} plain {\\c&H0000FF&\\u1}red{\\r}reset\\Nline two", style: "Default", margins: (0, 0, 0), styles: look)!
        precondition(mixed.spans.map(\.text) == ["slanted", " plain ", "red", "reset\nline two"], "\(mixed.spans.map(\.text))")
        precondition(mixed.spans[0].italic && !mixed.spans[1].italic && mixed.spans[2].color == 0xFF0000 && mixed.spans[2].underline && !mixed.spans[3].underline && mixed.spans[3].color == 0xFFFFFF && mixed.spans[1].bold && mixed.spans[0].size == 40)
        let moved = AssScript.block("{\\an7\\b0\\fs20\\3c&H00FF00&\\bord5\\fn@Helvetica}x", style: "Default", margins: (0, 0, 0), styles: look)!
        precondition(moved.alignment == 7 && !moved.spans[0].bold && moved.spans[0].size == 20 && moved.spans[0].outline == 0x00FF00 && moved.outline == 5 && moved.spans[0].font == "@Helvetica" && moved.height == 480 && moved.marginV == 20)
        let animated = AssScript.block("{\\t(0,500,\\fs80\\c&HFF&)\\k20\\pos(100,100)\\fad(200,200)\\blur2\\shad3\\fscx150\\alpha&H80&\\clip(0,0,10,10)}ab{\\p1}m 0 0 l 9 9{\\p0}cd", style: "Default", margins: (4, 5, 6), styles: look)!
        precondition(animated.text == "abcd" && animated.spans.count == 1 && animated.spans[0].size == 40 && animated.spans[0].color == 0xFFFFFF && animated.marginL == 4 && animated.marginR == 5 && animated.marginV == 6, "\(animated)")
        precondition(AssScript.block("{\\p1}m 0 0 l 1 1{\\p0}", style: "Default", margins: (0, 0, 0), styles: look) == nil && AssScript.block("   ", style: "Default", margins: (0, 0, 0), styles: look) == nil)
        precondition(AssScript.block("{\\rTop}back", style: "Default", margins: (0, 0, 0), styles: look)!.spans[0].font == "Georgia" && AssScript.block("{no closing", style: "Default", margins: (0, 0, 0), styles: look)!.text == "{no closing")
        let legacy = AssScript.styles("[V4 Styles]\nFormat: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding\nStyle: A,Arial,20,16777215,0,255,0,0,0,1,2,0,6,0,0,10,0,0\nStyle: B,Arial,20,16777215,0,0,0,0,0,1,2,0,10,0,0,10,0,0\nStyle: C,Arial,20,16777215,0,0,0,0,0,1,2,0,3,0,0,10,0,0\n")
        precondition(legacy.style(named: "A").alignment == 8 && legacy.style(named: "B").alignment == 5 && legacy.style(named: "C").alignment == 3 && legacy.style(named: "A").outline == 0xFF0000 && legacy.height == 288)
        precondition(AssScript.block("{\\a1}x", style: "A", margins: (0, 0, 0), styles: legacy)!.alignment == 1)
        let event = SubtitleParser.assEvent(packet: "5,0,Top,,0,0,0,,Hello", styles: look)!
        precondition(event.text == "Hello" && event.block?.alignment == 8 && event.block?.spans[0].font == "Georgia" && SubtitleParser.assEvent(packet: "5,0,Top", styles: look) == nil)
        let file = SubtitleParser.parse(header + "\n[Events]\nFormat: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text\nDialogue: 0,0:00:01.00,0:00:02.00,Top,,0,0,0,,{\\i0}Up there\n")
        precondition(file.count == 1 && file[0].block?.alignment == 8 && file[0].block?.spans[0].italic == false && file[0].block?.spans[0].underline == true && file[0].block?.marginL == 15, "\(file)")
        precondition(SubtitleParser.parse("1\n00:00:01,000 --> 00:00:02,000\nplain\n")[0].block == nil)
        let blocks = SubtitleCues([SubtitleCue(start: 0, end: 5, text: "a", block: moved), SubtitleCue(start: 1, end: 5, text: "b")]).active(at: 2)
        precondition(blocks.map(\.text) == ["a", "b"] && SubtitleBlock(plain: "\u{E000}x\u{E001}y").spans.map(\.text) == ["x", "y"] && SubtitleBlock(plain: "x").height == 0)
        print("ASS styles: bold, italic, underline, colours, outline, alignment, size, resets, animations ignored, old SSA numbers: ok")

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
            let tags = ["{", "}", "\\", "(", ")", "an", "fs", "c&H", "1c", "3c", "r", "b", "i", "u", "t(", "p1", "fn", "bord", "a", "9", "99999999999", "-", ",", "&", "H", "ab", "\\N", "*"]
            let tagged = (0..<min(size / 4, 400)).map { _ in tags.randomElement()! }.joined()
            _ = AssScript.block(tagged, style: tagged.prefix(3).description, margins: (1, 2, 3), styles: look)
            _ = AssScript.styles("[Script Info]\nPlayResY:" + tagged + "\n[V4+ Styles]\nFormat:" + tagged + "\nStyle:" + tagged)
            _ = SubtitleParser.assEvent(packet: tagged + ",,,,,,,," + tagged, styles: look)
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
