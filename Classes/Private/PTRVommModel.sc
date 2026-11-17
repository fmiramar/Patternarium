// SPDX-License-Identifier: GPL-3.0-or-later
PTRVommModel {
    var tables, alphabet, known, order;
    *new { |corpus, maxOrder| ^super.new.init(corpus,maxOrder) }
    init { |corpus, maxOrder|
        var sequences, history, total = 0;
        order = PTRValidation.integer(maxOrder,\Pvomm,\maxOrder,0);
        if(order > 64) { Error("Pvomm: maxOrder received %; expected at most 64.".format(order)).throw };
        if(corpus.isKindOf(SequenceableCollection).not or: { corpus.isEmpty }) { Error("Pvomm: corpus must be a nonempty SequenceableCollection.").throw };
        sequences = if(corpus.every { |x| x.isKindOf(SequenceableCollection) }) { corpus } { [corpus] };
        total = sequences.collect { |sequence| sequence.size.asFloat }.sum;
        if(total == 0 or: { total > 1000000 }) { Error("Pvomm: corpus must contain 1..1000000 symbols.").throw };
        tables = Dictionary.new; alphabet = List.new; known = Set.new;
        sequences.do { |sequence|
            history = [];
            sequence.do { |symbol|
                this.observe(history,symbol);
                history = this.nextHistory(history,symbol);
            };
        };
        ^this
    }
    nextHistory { |history, symbol|
        var next = history ++ [symbol];
        ^next.drop((next.size-order).max(0))
    }
    suffix { |history, n|
        ^if(n == 0) { [] } { history.copyRange(history.size-n,history.size-1) }
    }
    observe { |history, symbol|
        var key, counts;
        if(symbol.isNil) { Error("Pvomm: corpus/generated symbols cannot be nil.").throw };
        if(known.includes(symbol).not) { alphabet.add(symbol); known.add(symbol) };
        (0..history.size.min(order)).do { |n|
            key = this.suffix(history,n);
            counts = tables[key];
            if(counts.isNil) { counts = Dictionary.new; tables[key] = counts };
            counts[symbol] = (counts[symbol] ? 0.0) + 1.0;
        };
    }
    countsFor { |context| ^tables[context].copy }
    distribution { |history, excludeSeen = true|
        var result = Dictionary.new, excluded = Set.new, mass = 1.0, counts, eligible, remaining, count, types, escape, denominator;
        (0..history.size.min(order)).reverseDo { |n|
            if(mass > 0) {
                counts = tables[this.suffix(history,n)];
                if(counts.notNil) {
                    eligible = alphabet.select { |x| counts[x].notNil and: { excluded.includes(x).not } };
                    if(eligible.notEmpty) {
                        remaining = alphabet.size - excluded.size;
                        count = eligible.collect { |x| counts[x] }.sum; types = eligible.size;
                        // Closed observed alphabet: suppress an escape with no unseen destination.
                        escape = if(types == remaining) { 0 } { types };
                        denominator = count + escape;
                        eligible.do { |x| result[x] = (result[x] ? 0.0) + (mass * counts[x] / denominator) };
                        mass = mass * escape / denominator;
                        if(excludeSeen) { eligible.do { |x| excluded.add(x) } };
                    };
                };
            };
        };
        if(mass > 1e-10) { Error("Pvomm: PPM-C backoff exhausted its observed alphabet.").throw };
        ^result
    }
    sample { |history, excludeSeen|
        var probabilities = this.distribution(history,excludeSeen);
        var weights = alphabet.collect { |x| probabilities[x] ? 0.0 }.asArray;
        ^alphabet[weights.normalizeSum.windex]
    }
}
