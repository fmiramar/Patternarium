// SPDX-License-Identifier: GPL-3.0-or-later
ProtationWord : Pattern {
    var <alpha, <phase, <length, <cuts;
    *new { |alpha, phase = 0, length = inf, cuts|
        PTRValidation.staticInteger(length, \ProtationWord, \length, 0, true);
        ^super.newCopyArgs(alpha, phase, length, cuts)
    }
    storeArgs { ^[alpha, phase, length, cuts] }
    embedInStream { |inval|
        var increment = PTRValidation.once(alpha, inval), position = PTRValidation.once(phase, inval);
        var count = PTRValidation.integer(PTRValidation.once(length, inval), \ProtationWord, \length, 0, true);
        var boundaries = cuts.copy, value, coordinate, index = 0;
        [increment, position].do { |x|
            if(x.isNumber.not or: { x.isNaN or: { x.abs == inf } }) { Error("ProtationWord: alpha and phase must be finite numbers.").throw };
        };
        if(boundaries.notNil) {
            if(boundaries.isKindOf(SequenceableCollection).not) { Error("ProtationWord: cuts must be a sorted collection or nil.").throw };
            boundaries.do { |cut, i|
                if(cut.isNumber.not or: { (cut > 0 and: { cut < 1 }).not }) { Error("ProtationWord: cuts must be strictly inside (0,1).").throw };
                if(i > 0 and: { boundaries[i-1] >= cut }) { Error("ProtationWord: cuts must be strictly increasing.").throw };
            };
        };
        increment = increment % 1;
        position = position % 1;
        while { index < count } {
            coordinate = (index.asFloat * increment) + position;
            value = if(boundaries.isNil) {
                ((((index.asFloat + 1) * increment) + position).floor - coordinate.floor).asInteger
            } { boundaries.count { |cut| (coordinate % 1) >= cut } };
            inval = value.yield;
            if(index == 2147483646) { Error("ProtationWord: exact index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
