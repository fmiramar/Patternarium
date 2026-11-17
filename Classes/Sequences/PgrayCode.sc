// SPDX-License-Identifier: GPL-3.0-or-later
PgrayCode : Pattern {
    var <radices, <repeats;
    *new { |radices, repeats = 1|
        PTRValidation.staticInteger(repeats, \PgrayCode, \repeats, 0, true);
        ^super.newCopyArgs(radices, repeats)
    }
    storeArgs { ^[radices, repeats] }
    embedInStream { |inval|
        var bases = radices.copy;
        var count = PTRValidation.integer(PTRValidation.once(repeats, inval), \PgrayCode, \repeats, 0, true);
        var state, directions, index, next;
        if(bases.isKindOf(SequenceableCollection).not or: { bases.isEmpty }) { Error("PgrayCode: radices must be a nonempty collection.").throw };
        bases.do { |r| PTRValidation.integer(r, \PgrayCode, \radices, 2) };
        count.do {
            state = Array.fill(bases.size, 0);
            directions = Array.fill(bases.size, 1);
            index = 0;
            while { index >= 0 } {
                inval = state.copy.yield;
                index = bases.size - 1;
                while { index >= 0 and: {
                    next = state[index] + directions[index];
                    (next < 0) or: { next >= bases[index] }
                } } {
                    directions[index] = directions[index].neg;
                    index = index - 1;
                };
                if(index >= 0) { state[index] = next };
            };
        };
        ^inval
    }
}
