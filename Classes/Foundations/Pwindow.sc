// SPDX-License-Identifier: GPL-3.0-or-later
Pwindow : Pattern {
    var <pattern, <size, <step, <partial;
    *new { |pattern, size, step = 1, partial = false|
        PTRValidation.staticInteger(size, \Pwindow, \size, 1);
        PTRValidation.staticInteger(step, \Pwindow, \step, 1);
        ^super.newCopyArgs(pattern, size, step, partial)
    }
    storeArgs { ^[pattern, size, step, partial] }
    embedInStream { |inval|
        var n = PTRValidation.integer(PTRValidation.once(size, inval), \Pwindow, \size, 1);
        var stride = PTRValidation.integer(PTRValidation.once(step, inval), \Pwindow, \step, 1);
        var tail = PTRValidation.boolean(PTRValidation.once(partial, inval), \Pwindow, \partial);
        var stream = pattern.asStream, buffer = Array.newClear(n), head = 0, held = 0, input, added;
        loop {
            added = 0;
            while { held < n } {
                input = stream.next(inval);
                if(input.isNil) {
                    if(tail and: { added > 0 }) {
                        inval = Array.fill(held,{ |i| buffer[(head+i) % n] }).yield;
                    };
                    ^inval
                };
                buffer[(head+held) % n] = input;
                held = held + 1;
                added = added + 1;
            };
            inval = Array.fill(n,{ |i| buffer[(head+i) % n] }).yield;
            if(stride < n) {
                // Release dropped items without shifting retained references.
                stride.do { |i| buffer[(head+i) % n] = nil };
                head = (head+stride) % n;
                held = n-stride;
            } {
                buffer.fill(nil);
                head = 0;
                held = 0;
                (stride - n).do {
                    if(stream.next(inval).isNil) { ^inval };
                };
            };
        }
    }
}
