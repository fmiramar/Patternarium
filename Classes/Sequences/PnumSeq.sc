// SPDX-License-Identifier: GPL-3.0-or-later
PnumSeq : Pattern {
    var <name, <seed, <length, <options;
    *new { |name, seed, length = inf, options|
        PTRValidation.staticInteger(length, \PnumSeq, \length, 0, true);
        ^super.newCopyArgs(name, seed, length, options ? ())
    }
    *names { ^PTRSequenceAlgorithms.names }
    storeArgs { ^[name, seed, length, options] }
    embedInStream { |inval|
        var which = PTRValidation.once(name, inval), initial = seed.value(inval);
        var count = PTRValidation.integer(PTRValidation.once(length, inval), \PnumSeq, \length, 0, true);
        var stream = PTRSequenceAlgorithms.stream(which, initial, options.copy), index = 0, value;
        while { index < count } {
            value = stream.next(inval);
            if(value.isNil) { ^inval };
            inval = value.yield;
            if(index == 2147483646) { Error("PnumSeq: exact index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
