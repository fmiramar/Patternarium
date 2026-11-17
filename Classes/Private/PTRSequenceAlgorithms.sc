// SPDX-License-Identifier: GPL-3.0-or-later
PTRSequenceAlgorithms {
    *names { ^#[recaman, vanEck, golomb, kolakoski, paperfolding, rudinShapiro, stern, calkinWilf, lookAndSay, norgard].copy }
    *checkedInteger { |number|
        if(number.abs > 2147483647) { Error("PnumSeq: exact Integer range exceeded.").throw };
        ^number.asInteger
    }
    *stream { |name, seed, options|
        var allowed, maxTerm, alphabet;
        if(this.names.includes(name).not) { Error("PnumSeq: unknown name %. Valid names: %".format(name, this.names)).throw };
        if(options.isKindOf(Dictionary).not) { Error("PnumSeq: options must be a Dictionary or Event.").throw };
        allowed = switch(name, \lookAndSay, { [\maxTermSize] }, \rudinShapiro, { [\binary] }, \kolakoski, { [\alphabet] }, { [] });
        options.keys.do { |key| if(allowed.includes(key).not) { Error("PnumSeq: unsupported option % for %.".format(key, name)).throw } };
        if([\recaman,\vanEck,\lookAndSay].includes(name).not and: { seed.notNil }) { Error("PnumSeq: seed is not supported for " ++ name).throw };
        switch(name,
            \recaman, {
                seed = seed ? 0;
                PTRValidation.integer(seed, \PnumSeq, \seed, 0);
                ^Routine {
                    var value = seed, seen = Set[seed], n = 1, candidate;
                    value.yield;
                    loop {
                        candidate = value - n;
                        value = if(candidate >= 0 and: { seen.includes(candidate).not }) { candidate } { this.checkedInteger(value.asFloat + n) };
                        seen.add(value);
                        value.yield;
                        n = this.checkedInteger(n.asFloat + 1);
                    };
                }
            },
            \vanEck, {
                seed = seed ? [0];
                if(seed.isKindOf(SequenceableCollection).not or: { seed.isEmpty }) { Error("PnumSeq: vanEck seed must be a nonempty Integer collection.").throw };
                seed.do { |x| PTRValidation.integer(x, \PnumSeq, \seed, 0) };
                seed = seed.asArray.copy;
                ^Routine {
                    var seen = Dictionary.new, position = seed.size - 1, value = seed.last, previous;
                    seed.do { |x,i| if(i < position) { seen[x] = i }; x.yield };
                    loop {
                        previous = seen[value]; seen[value] = position;
                        value = if(previous.isNil) { 0 } { position - previous };
                        position = this.checkedInteger(position.asFloat + 1);
                        value.yield;
                    };
                }
            },
            \golomb, {
                ^Routine {
                    var history = List[0,1], n = 1;
                    loop {
                        if(n >= history.size) { history.add(1 + history[n - history[history[n-1]]]) };
                        history[n].yield;
                        n = n + 1;
                    };
                }
            },
            \kolakoski, {
                alphabet = options[\alphabet] ? [1,2];
                if(alphabet.isKindOf(SequenceableCollection).not or: { alphabet.size != 2 }) { Error("PnumSeq: alphabet must contain two distinct positive Integers.").throw };
                alphabet.do { |x| PTRValidation.integer(x, \PnumSeq, \alphabet, 1) };
                if(alphabet[0] == alphabet[1] or: { alphabet.maxItem > 1000000 }) { Error("PnumSeq: alphabet must be distinct and at most 1000000.").throw };
                alphabet = alphabet.copy;
                ^Routine {
                    var history, read, symbol, n = 0;
                    if(alphabet[0] == 1) {
                        history = List[1]; alphabet[1].do { history.add(alphabet[1]) }; read = 2; symbol = alphabet[0];
                    } {
                        history = List.new; alphabet[0].do { history.add(alphabet[0]) }; read = 1; symbol = alphabet[1];
                    };
                    loop {
                        if(n >= history.size) {
                            history[read].do { history.add(symbol) };
                            read = read + 1;
                            symbol = if(symbol == alphabet[0]) { alphabet[1] } { alphabet[0] };
                        };
                        history[n].yield;
                        n = n + 1;
                    };
                }
            },
            \paperfolding, {
                ^Routine {
                    var n = 1, odd;
                    loop {
                        odd = n;
                        while { odd.even } { odd = odd.div(2) };
                        if((odd % 4) == 1) { 1.yield } { 0.yield };
                        n = this.checkedInteger(n.asFloat + 1);
                    };
                }
            },
            \rudinShapiro, {
                PTRValidation.boolean(options[\binary] ? false, \PnumSeq, \binary);
                ^Routine {
                    var n = 0, bits, parity;
                    loop {
                        bits = n.bitAnd(n.div(2)); parity = 0;
                        while { bits > 0 } { parity = parity.bitXor(bits % 2); bits = bits.div(2) };
                        if(options[\binary] == true) { parity.yield } { (1 - (2 * parity)).yield };
                        n = this.checkedInteger(n.asFloat + 1);
                    };
                }
            },
            \stern, { ^this.rationals(true) },
            \calkinWilf, { ^this.rationals(false) },
            \lookAndSay, {
                seed = seed ? [1];
                if(seed.isKindOf(SequenceableCollection).not or: { seed.isEmpty }) { Error("PnumSeq: lookAndSay seed must be a nonempty digit collection.").throw };
                seed.do { |x| PTRValidation.integer(x, \PnumSeq, \seed, 0); if(x > 9) { Error("PnumSeq: seed digits must be in 0..9.").throw } };
                maxTerm = PTRValidation.integer(options[\maxTermSize] ? 100000, \PnumSeq, \maxTermSize, 1);
                if(seed.size > maxTerm) { Error("PnumSeq: seed exceeds maxTermSize.").throw };
                seed = seed.asArray.copy;
                ^Routine {
                    var term = seed, next, index, end, digits;
                    loop {
                        term.copy.yield;
                        next = List.new; index = 0;
                        while { index < term.size } {
                            end = index + 1;
                            while { end < term.size and: { term[end] == term[index] } } { end = end + 1 };
                            digits = (end - index).asDigits ++ [term[index]];
                            if((next.size + digits.size) > maxTerm) { Error("PnumSeq: maxTermSize exceeded.").throw };
                            digits.do { |digit| next.add(digit) };
                            index = end;
                        };
                        term = next.asArray;
                    };
                }
            },
            \norgard, {
                ^Routine {
                    var n = 0, value;
                    loop {
                        value = 0;
                        n.asDigits(2).do { |bit| value = if(bit == 0) { value.neg } { value + 1 } };
                        value.yield;
                        n = this.checkedInteger(n.asFloat + 1);
                    };
                }
            }
        );
    }
    *rationals { |stern|
        ^Routine {
            var a = if(stern) { 0 } { 1 }, b = 1, next;
            loop {
                if(stern) { a.yield } { [a,b].yield };
                next = this.checkedInteger(((2.0 * a.div(b)) + 1) * b - a);
                a = b; b = next;
            };
        }
    }
}
