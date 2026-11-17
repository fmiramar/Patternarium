// SPDX-License-Identifier: GPL-3.0-or-later
PdeBruijn : Pattern {
    var <alphabet, <order, <repeats, <rotation;
    *new { |alphabet, order, repeats = 1, rotation = 0|
        PTRValidation.staticInteger(order, \PdeBruijn, \order, 1);
        PTRValidation.staticInteger(repeats, \PdeBruijn, \repeats, 0, true);
        ^super.newCopyArgs(alphabet, order, repeats, rotation)
    }
    storeArgs { ^[alphabet, order, repeats, rotation] }
    embedInStream { |inval|
        var symbols = alphabet.copy, n = PTRValidation.integer(PTRValidation.once(order, inval), \PdeBruijn, \order, 1);
        var count = PTRValidation.integer(PTRValidation.once(repeats, inval), \PdeBruijn, \repeats, 0, true);
        var offset = PTRValidation.integer(PTRValidation.once(rotation, inval), \PdeBruijn, \rotation, -inf);
        var k, total, work, cycle = List.new, necklace;
        if(symbols.isKindOf(SequenceableCollection).not or: { symbols.isEmpty }) { Error("PdeBruijn: alphabet must be a nonempty collection.").throw };
        if(symbols.includes(nil) or: { symbols.as(Set).size != symbols.size }) { Error("PdeBruijn: alphabet must contain unique non-nil values.").throw };
        if(count == 0) { ^inval };
        k = symbols.size;
        total = k.asFloat.pow(n);
        if(total > 1000000) { Error("PdeBruijn: cycle exceeds the 1000000 symbol allocation limit.").throw };
        if(k == 1) { cycle.add(0) } {
            work = Array.fill(n + 1, 0);
            necklace = { |t, period|
                if(t > n) {
                    if((n % period) == 0) { (1..period).do { |j| cycle.add(work[j]) } };
                } {
                    work[t] = work[t - period];
                    necklace.value(t + 1, period);
                    if(work[t - period] < (k - 1)) {
                        ((work[t - period] + 1)..(k - 1)).do { |j|
                            work[t] = j;
                            necklace.value(t + 1, t);
                        };
                    };
                };
            };
            necklace.value(1, 1);
        };
        count.do { cycle.size.do { |i| inval = symbols[cycle.wrapAt(i + (offset % cycle.size))].yield } };
        ^inval
    }
}
