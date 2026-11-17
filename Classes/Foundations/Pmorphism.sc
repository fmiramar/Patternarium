// SPDX-License-Identifier: GPL-3.0-or-later
Pmorphism : Pattern {
    var <seed, <rules, <generations, <output, <includeSeed, <maxSymbols;
    *new { |seed, rules, generations = 1, output = \symbols, includeSeed = false, maxSymbols|
        if(rules.isKindOf(Dictionary).not) { Error("Pmorphism: rules must be a Dictionary or Event.").throw };
        PTRValidation.staticInteger(generations, \Pmorphism, \generations, 0, true);
        if(maxSymbols.notNil) { PTRValidation.staticInteger(maxSymbols, \Pmorphism, \maxSymbols, 1) };
        ^super.newCopyArgs(seed, rules, generations, output, includeSeed, maxSymbols)
    }
    storeArgs { ^[seed, rules, generations, output, includeSeed, maxSymbols] }
    prAppend { |value, list, limit, inval|
        var stream, item;
        if(value.isKindOf(Pattern)) {
            stream = value.asStream;
            loop {
                item = stream.next(inval);
                if(item.isNil) { ^list };
                this.prAdd(item, list, limit);
            };
        } {
            if(value.isKindOf(SequenceableCollection)) {
                value.do { |symbol| this.prAdd(symbol, list, limit) };
            } {
                this.prAdd(value, list, limit);
            };
        };
        ^list
    }
    prAdd { |value, list, limit|
        if(value.isNil) { Error("Pmorphism: nil is not a symbol; use [] for deletion.").throw };
        if(list.size >= limit) { Error("Pmorphism: maxSymbols exceeded during bounded expansion.").throw };
        list.add(value);
    }
    embedInStream { |inval|
        var count = PTRValidation.integer(PTRValidation.once(generations, inval), \Pmorphism, \generations, 0, true);
        var mode = PTRValidation.once(output, inval);
        var first = PTRValidation.boolean(PTRValidation.once(includeSeed, inval), \Pmorphism, \includeSeed);
        var limit = PTRValidation.integer(PTRValidation.once(maxSymbols ? 100000, inval), \Pmorphism, \maxSymbols, 1);
        var current, next, rule, replacement, generation = 0;
        if(count == inf and: { maxSymbols.isNil }) { Error("Pmorphism: infinite generations require explicit maxSymbols.").throw };
        if([\symbols, \generations].includes(mode).not) { Error("Pmorphism: output must be symbols or generations.").throw };
        if(count == 0 and: { first.not }) { ^inval };
        current = this.prAppend(seed, List.new, limit, inval).asArray;
        loop {
            if(first or: { generation > 0 }) {
                if(mode == \generations) { inval = current.copy.yield } {
                    current.do { |symbol| inval = symbol.yield };
                };
            };
            if(generation >= count) { ^inval };
            // An empty infinite rewrite can never emit another symbol.
            if(current.isEmpty and: { mode == \symbols }) { ^inval };
            generation = generation + 1;
            next = List.new;
            current.do { |symbol, index|
                if(rules.includesKey(symbol)) {
                    rule = rules.at(symbol);
                    replacement = if(rule.isKindOf(Function)) {
                        rule.value(symbol, if(index > 0) { current[index - 1] },
                            if(index < (current.size - 1)) { current[index + 1] }, generation, index, inval)
                    } { rule };
                    this.prAppend(replacement, next, limit, inval);
                } {
                    this.prAdd(symbol, next, limit);
                };
            };
            current = next.asArray;
        }
    }
}
