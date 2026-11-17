// Parse and render Help; evaluate numerical examples and Event streams without audio.
(
var root = thisProcess.nowExecutingPath.dirname.dirname;
var output = Platform.defaultTempDir +/+ "Patternarium-help";
var visit, paths, blocks = 0, docs = 0;
try {
    visit = { |node, path|
        var code, function;
        if(node.id == \CODEBLOCK) {
            code = node.text;
            if(code.contains("s.boot").not) {
                // Generate Events instead of starting EventStreamPlayers.
                code = code.replace(".play;", ".asStream.nextN(8, ());");
                // Build documentation instrument definitions without sending to a server.
                code = code.replace("}).add;", "}).asBytes;");
                function = code.compile;
                if(function.isNil) { Error("Help example compile failed: " ++ path).throw };
                function.value;
                blocks = blocks + 1;
            };
        };
        node.children.do { |child| visit.value(child, path) };
    };
    SCDoc.helpTargetDir = output;
    paths = ["Classes", "Guides", "Reference"].collect { |folder|
        (root +/+ "HelpSource" +/+ folder +/+ "*.schelp").pathMatch
    }.flatten(1);
    paths.do { |path|
        var relative = path.drop((root +/+ "HelpSource").size + 1);
        var entry = SCDoc.parseFileMetaData(root +/+ "HelpSource", relative);
        SCDoc.documents[entry.path] = entry;
    };
    ["Classes", "Guides", "Reference"].do { |folder|
        (root +/+ "HelpSource" +/+ folder +/+ "*.schelp").pathMatch.do { |path|
            var tree = SCDoc.parseFileFull(path), entry;
            if(tree.isNil) { Error("Help parse failed: " ++ path).throw };
            visit.value(tree, path);
            entry = SCDoc.parseFileMetaData(root +/+ "HelpSource", folder +/+ path.basename);
            SCDocHTMLRenderer.renderToFile(output +/+ folder +/+ path.basename.replace(".schelp", ".html"), entry, tree);
            docs = docs + 1;
        };
    };
    "Patternarium Help: % documents rendered, % code blocks evaluated without audio.".format(docs, blocks).postln;
    0.exit;
} { |error| error.reportError; 1.exit };
)
