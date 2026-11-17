// SPDX-License-Identifier: GPL-3.0-or-later
Pconstraint : Pattern {
    var <domain, <constraints, <length, <solutions, <randomize, <maxBacktracks, <failure, <output;
    *new { |domain, constraints, length, solutions = 1, randomize = false, maxBacktracks = 10000, failure = \empty, output = \solution|
        PTRValidation.staticInteger(length,\Pconstraint,\length,0);
        PTRValidation.staticInteger(solutions,\Pconstraint,\solutions,0);
        PTRValidation.staticInteger(maxBacktracks,\Pconstraint,\maxBacktracks,0);
        ^super.newCopyArgs(domain,constraints,length,solutions,randomize,maxBacktracks,failure,output)
    }
    storeArgs { ^[domain,constraints,length,solutions,randomize,maxBacktracks,failure,output] }
    prCandidates { |value, shuffle|
        var array;
        if(value.isKindOf(Collection).not) { Error("Pconstraint: domain received %; expected a finite Collection.".format(value)).throw };
        if(value.size > 100000) { Error("Pconstraint: domain exceeds 100000 candidates per position.").throw };
        array = value.asArray.copy;
        if(array.includes(nil)) { Error("Pconstraint: domain cannot contain nil candidates.").throw };
        ^if(shuffle) { array.scramble } { array }
    }
    embedInStream { |inval|
        var n = PTRValidation.integer(PTRValidation.once(length,inval),\Pconstraint,\length,0);
        var wanted = PTRValidation.integer(PTRValidation.once(solutions,inval),\Pconstraint,\solutions,0);
        var shuffle = PTRValidation.boolean(PTRValidation.once(randomize,inval),\Pconstraint,\randomize);
        var budget = PTRValidation.integer(PTRValidation.once(maxBacktracks,inval),\Pconstraint,\maxBacktracks,0);
        var policy = PTRValidation.once(failure,inval), mode = PTRValidation.once(output,inval);
        var rules = if(constraints.isKindOf(Function)) { [constraints] } { constraints };
        var cached, source, atPosition, candidates, cursors, history = List.new, depth = 0, found = 0, backtracks = 0, candidate, valid, solution;
        if(n > 4096) { Error("Pconstraint: length received %; expected at most 4096.".format(n)).throw };
        if([\empty,\warn,\error].includes(policy).not) { Error("Pconstraint: failure must be empty, warn or error.").throw };
        if([\solution,\values].includes(mode).not) { Error("Pconstraint: output must be solution or values.").throw };
        if(rules.isKindOf(Collection).not or: { rules.every { |r| r.isKindOf(Function) }.not }) { Error("Pconstraint: constraints must be a Function or collection of Functions.").throw };
        rules = rules.asArray.copy;
        if(wanted == 0) { ^inval };
        if(n == 0) { if(mode == \solution) { inval = [].yield }; ^inval };
        if(domain.isKindOf(Pattern)) {
            source = domain.asStream;
            cached = Array.fill(n,{ |i|
                var values = source.next(inval);
                if(values.isNil) { Error("Pconstraint: domain Pattern exhausted at position %.".format(i)).throw };
                this.prCandidates(values,false)
            });
        };
        atPosition = { |i|
            var values = if(cached.notNil) { cached[i] } {
                if(domain.isKindOf(Function)) { domain.value(i,history.asArray,inval) } { domain }
            };
            this.prCandidates(values,shuffle)
        };
        candidates = Array.newClear(n); cursors = Array.fill(n,0); candidates[0] = atPosition.value(0);
        while { depth >= 0 and: { found < wanted } } {
            if(depth == n) {
                solution = history.asArray;
                if(mode == \solution) { inval = solution.yield } { solution.do { |x| inval = x.yield } };
                found = found + 1; depth = depth - 1; history.pop;
            } {
                if(cursors[depth] >= candidates[depth].size) {
                    backtracks = backtracks.asFloat + 1; depth = depth - 1;
                    if(depth >= 0) { history.pop };
                } {
                    candidate = candidates[depth][cursors[depth]]; cursors[depth] = cursors[depth] + 1;
                    valid = rules.every { |rule| PTRValidation.boolean(rule.value(history.asArray,candidate,depth,inval),\Pconstraint,\constraintResult) };
                    if(valid) {
                        history.add(candidate); depth = depth + 1;
                        if(depth < n) { candidates[depth] = atPosition.value(depth); cursors[depth] = 0 };
                    } { backtracks = backtracks.asFloat + 1 };
                };
                if(backtracks > budget) { Error("Pconstraint: maxBacktracks % exhausted after % rejected candidates/dead branches.".format(budget,backtracks)).throw };
            };
        };
        if(found == 0) {
            if(policy == \warn) { "Pconstraint: no complete solution exists within the supplied finite domains.".warn };
            if(policy == \error) { Error("Pconstraint: no complete solution exists within the supplied finite domains.").throw };
        };
        ^inval
    }
}
