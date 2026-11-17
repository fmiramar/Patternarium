// SPDX-License-Identifier: GPL-3.0-or-later
Ppetri : Pattern {
    var <marking, <transitions, <length, <policy, <deadlock, <output;
    *new { |marking, transitions, length = inf, policy = \weighted, deadlock = \stop, output = \event|
        PTRValidation.staticInteger(length,\Ppetri,\length,0,true);
        ^super.newCopyArgs(marking,transitions,length,policy,deadlock,output)
    }
    storeArgs { ^[marking,transitions,length,policy,deadlock,output] }
    prTokens { |dictionary, argument|
        if(dictionary.isKindOf(Dictionary).not) { Error("Ppetri: % must be a Dictionary/Event of place tokens.".format(argument)).throw };
        dictionary.keysValuesDo { |place,tokens|
            if(place.isKindOf(Symbol).not) { Error("Ppetri: place % must be a Symbol.".format(place)).throw };
            PTRValidation.integer(tokens,\Ppetri,argument,0);
        };
        ^dictionary.copy
    }
    embedInStream { |inval|
        var state = this.prTokens(marking,\marking), entries;
        var count = PTRValidation.integer(PTRValidation.once(length,inval),\Ppetri,\length,0,true);
        var selection = PTRValidation.once(policy,inval), failure = PTRValidation.once(deadlock,inval), mode = PTRValidation.once(output,inval);
        var enabled, selected, weights, next, result, total, index = 0;
        if([\uniform,\weighted,\priority].includes(selection).not) { Error("Ppetri: policy must be uniform, weighted or priority.").throw };
        if([\stop,\warn,\error].includes(failure).not) { Error("Ppetri: deadlock must be stop, warn or error.").throw };
        if(mode != \event) { Error("Ppetri: output must be event; received %.".format(mode)).throw };
        if(transitions.isKindOf(Dictionary).not) { Error("Ppetri: transitions must be a Dictionary/Event keyed by transition name.").throw };
        if(transitions.keys.every { |key| key.isKindOf(Symbol) }.not) { Error("Ppetri: transition names must be Symbols.").throw };
        entries = transitions.keys.asArray.sort.collect { |name|
            var definition = transitions[name], consume, produce, weight, priority, delta;
            if(name.isKindOf(Symbol).not or: { definition.isKindOf(Dictionary).not }) { Error("Ppetri: transitions require Symbol names and Dictionary/Event definitions.").throw };
            consume = this.prTokens(definition[\consume] ? (),\consume);
            produce = this.prTokens(definition[\produce] ? (),\produce);
            (consume.keys ++ produce.keys).do { |place| if(state[place].isNil) { state[place] = 0 } };
            weight = PTRValidation.finite(definition[\weight] ? 1,\Ppetri,\weight,0);
            priority = PTRValidation.finite(definition[\priority] ? 0,\Ppetri,\priority);
            delta = PTRValidation.finite(definition[\delta] ? 1,\Ppetri,\delta,0);
            (name: name,consume: consume,produce: produce,weight: weight,priority: priority,delta: delta,value: definition[\value] ? name)
        };
        while { index < count } {
            enabled = entries.select { |entry| entry[\consume].keys.every { |place| state[place] >= entry[\consume][place] } };
            if(selection == \priority and: { enabled.notEmpty }) {
                total = enabled.collect { |e| e[\priority] }.maxItem;
                enabled = enabled.select { |e| e[\priority] == total };
            };
            if(selection != \uniform) { enabled = enabled.select { |e| e[\weight] > 0 } };
            if(enabled.isEmpty) {
                if(failure == \error) { Error("Ppetri: deadlock; no enabled selectable transition.").throw };
                if(failure == \warn) { "Ppetri: deadlock; no enabled selectable transition.".warn };
                ^inval
            };
            if(selection == \uniform) { selected = enabled.choose } {
                weights = enabled.collect { |e| e[\weight] };
                PTRValidation.finite(weights.sum,\Ppetri,\totalWeight,0,true);
                selected = enabled[weights.normalizeSum.windex];
            };
            next = state.copy;
            selected[\consume].keysValuesDo { |place,n| next[place] = next[place] - n };
            selected[\produce].keysValuesDo { |place,n|
                total = next[place].asFloat + n;
                if(total > 2147483647) { Error("Ppetri: marking at % exceeds exact Integer range.".format(place)).throw };
                next[place] = total.asInteger;
            };
            state = next;
            result = (transition: selected[\name],value: selected[\value],marking: state.copy,delta: selected[\delta]);
            inval = result.yield;
            if(index == 2147483646) { Error("Ppetri: output index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
