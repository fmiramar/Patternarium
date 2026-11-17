// SPDX-License-Identifier: GPL-3.0-or-later
PTRValidation {
    *finite { |value, owner, argument, minimum = -inf, strict = false|
        if(value.isKindOf(SimpleNumber).not or: {
            value.isNaN or: { value.abs == inf or: { if(strict) { value <= minimum } { value < minimum } } }
        }) { Error("%: % received %; expected a finite number % %.".format(owner, argument, value, if(strict) { ">" } { ">=" }, minimum)).throw };
        ^value
    }
    *once { |value, inval|
        ^if(value.isKindOf(Pattern)) { value.asStream.next(inval) } { value.value(inval) }
    }
    *staticInteger { |value, owner, argument, minimum = 0, infinity = false|
        if(value.isKindOf(Function) or: { value.isKindOf(Pattern) }) { ^value };
        ^this.integer(value, owner, argument, minimum, infinity)
    }
    *integer { |value, owner, argument, minimum = 0, infinity = false|
        if(infinity and: { value == inf }) { ^value };
        if(value.isKindOf(Integer).not or: { value < minimum }) {
            Error("%: % received %; expected an Integer >= %%.".format(owner, argument, value, minimum,
                if(infinity) { " or inf" } { "" })).throw;
        };
        ^value
    }
    *boolean { |value, owner, argument|
        if((value !== true) and: { value !== false }) {
            Error("%: % received %; expected true or false.".format(owner, argument, value)).throw;
        };
        ^value
    }
    *step { |result|
        if(result.isNil) { ^nil };
        if(result.isKindOf(Event).not) { Error("Ptransduce: function/flush must return an Event or nil.").throw };
        if(result.includesKey(\stop)) { this.boolean(result[\stop], \Ptransduce, \stop) };
        if((result[\stop] !== true) and: { result.includesKey(\state).not }) {
            Error("Ptransduce: state is required unless stop is true.").throw;
        };
        if(result[\emit].notNil) {
            if(result[\emit].isKindOf(SequenceableCollection).not) {
                Error("Ptransduce: emit must be a SequenceableCollection or nil.").throw;
            };
            if(result[\emit].includes(nil)) { Error("Ptransduce: emit cannot contain nil.").throw };
        };
        ^result
    }
}
