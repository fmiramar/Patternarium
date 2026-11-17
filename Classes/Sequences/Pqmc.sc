// SPDX-License-Identifier: GPL-3.0-or-later
Pqmc : Pattern {
    var <dimensions, <engine, <length, <scramble, <skip, <leap;
    *new { |dimensions = 1, engine = \halton, length = inf, scramble = false, skip = 0, leap = 1|
        PTRValidation.staticInteger(dimensions, \Pqmc, \dimensions, 1);
        PTRValidation.staticInteger(length, \Pqmc, \length, 0, true);
        PTRValidation.staticInteger(skip, \Pqmc, \skip, 0);
        PTRValidation.staticInteger(leap, \Pqmc, \leap, 1);
        ^super.newCopyArgs(dimensions, engine, length, scramble, skip, leap)
    }
    storeArgs { ^[dimensions, engine, length, scramble, skip, leap] }
    embedInStream { |inval|
        var d = PTRValidation.integer(PTRValidation.once(dimensions, inval), \Pqmc, \dimensions, 1);
        var mode = PTRValidation.once(engine, inval);
        var count = PTRValidation.integer(PTRValidation.once(length, inval), \Pqmc, \length, 0, true);
        var randomize = PTRValidation.boolean(PTRValidation.once(scramble, inval), \Pqmc, \scramble);
        var start = PTRValidation.integer(PTRValidation.once(skip, inval), \Pqmc, \skip, 0);
        var stride = PTRValidation.integer(PTRValidation.once(leap, inval), \Pqmc, \leap, 1);
        var primes = List.new, candidate = 2, shifts, increments, index = 0, n, point;
        if([\halton,\additive].includes(mode).not) { Error("Pqmc: engine must be halton or additive.").throw };
        if(d > 4096) { Error("Pqmc: dimensions exceeds the 4096 allocation limit.").throw };
        if(count == 0) { ^inval };
        while { primes.size < d } {
            if(primes.every { |p| (p > candidate.sqrt) or: { (candidate % p) != 0 } }) { primes.add(candidate) };
            candidate = candidate + 1;
        };
        increments = primes.collect { |p| p.sqrt % 1 };
        shifts = Array.fill(d, { if(randomize) { 1.0.rand } { 0.0 } });
        while { index < count } {
            n = start.asFloat + (index.asFloat * stride);
            if(n > 2147483646) { Error("Pqmc: sample index exceeds exact Integer range.").throw };
            point = Array.fill(d, { |i|
                var value = 0.0, factor, digits;
                if(mode == \halton) {
                    factor = 1.0 / primes[i];
                    digits = n.asInteger;
                    while { digits > 0 } {
                        value = value + ((digits % primes[i]) * factor);
                        digits = digits.div(primes[i]);
                        factor = factor / primes[i];
                    };
                } { value = (n * increments[i]) % 1 };
                (value + shifts[i]) % 1
            });
            inval = point.yield;
            index = index + 1;
        };
        ^inval
    }
}
