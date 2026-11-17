// SPDX-License-Identifier: GPL-3.0-or-later
Prenewal : PpointProcess {
    var <distribution;
    *new { |distribution, start = 0, length = inf, output = \delta|
        PTRValidation.staticInteger(length, \Prenewal, \length, 0, true);
        ^super.newCopyArgs(start, length, output, distribution)
    }
    storeArgs { ^[distribution,start,length,output] }
    embedInStream { |inval|
        var parameters = this.prParameters(inval), time = parameters[0], count = parameters[1], mode = parameters[2];
        var stream, delta, index = 0;
        if(count == 0) { ^inval };
        stream = distribution.asStream;
        while { index < count } {
            delta = stream.next(inval);
            if(delta.isNil) { ^inval };
            PTRValidation.finite(delta, \Prenewal, \distribution, 0, true);
            time = PTRPointProcess.advance(time, delta, \Prenewal);
            inval = this.prOutput(time, delta, mode).yield;
            if(index == 2147483646) { Error("Prenewal: exact arrival index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
