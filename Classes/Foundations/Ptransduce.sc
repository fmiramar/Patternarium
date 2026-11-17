// SPDX-License-Identifier: GPL-3.0-or-later
Ptransduce : Pattern {
    var <pattern, <initial, <function, <flush;
    *new { |pattern, initial, function, flush|
        if(function.isKindOf(Function).not) { Error("Ptransduce: function must be a Function.").throw };
        if(flush.notNil and: { flush.isKindOf(Function).not }) { Error("Ptransduce: flush must be a Function or nil.").throw };
        ^super.newCopyArgs(pattern, initial, function, flush)
    }
    storeArgs { ^[pattern, initial, function, flush] }
    embedInStream { |inval|
        var state = initial.value(inval), stream = pattern.asStream, index = 0, input, result;
        loop {
            input = stream.next(inval);
            if(input.isNil) {
                if(flush.notNil) {
                    result = PTRValidation.step(flush.value(state, index, inval));
                    if(result.notNil) { result[\emit].do { |item| inval = item.yield } };
                };
                ^inval
            };
            result = PTRValidation.step(function.value(state, input, index, inval));
            if(result.isNil) { ^inval };
            state = result[\state];
            result[\emit].do { |item| inval = item.yield };
            if(result[\stop] === true) { ^inval };
            index = index + 1;
        }
    }
}
