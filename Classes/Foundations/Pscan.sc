// SPDX-License-Identifier: GPL-3.0-or-later
Pscan : Pattern {
    var <pattern, <initial, <function, <length, <includeInitial;
    *new { |pattern, initial, function, length = inf, includeInitial = false|
        if(function.isKindOf(Function).not) { Error("Pscan: function must be a Function.").throw };
        PTRValidation.staticInteger(length, \Pscan, \length, 0, true);
        ^super.newCopyArgs(pattern, initial, function, length, includeInitial)
    }
    storeArgs { ^[pattern, initial, function, length, includeInitial] }
    embedInStream { |inval|
        var state = initial.value(inval), stream, input, index = 0;
        var count = PTRValidation.integer(PTRValidation.once(length, inval), \Pscan, \length, 0, true);
        var first = PTRValidation.boolean(PTRValidation.once(includeInitial, inval), \Pscan, \includeInitial);
        if(first) {
            if(state.isNil) { ^inval };
            inval = state.yield;
        };
        if(count == 0) { ^inval };
        stream = pattern.asStream;
        while { index < count } {
            input = stream.next(inval);
            if(input.isNil) { ^inval };
            state = function.value(state, input, index, inval);
            if(state.isNil) { ^inval };
            inval = state.yield;
            index = index + 1;
        };
        ^inval
    }
}
