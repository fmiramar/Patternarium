// SPDX-License-Identifier: GPL-3.0-or-later
Pkuramoto : Pattern {
    var <frequencies, <coupling, <phases, <step, <length, <method, <output;
    *new { |frequencies, coupling = 1, phases, step = 0.01, length = inf, method = \rk4, output = \state|
        PTRValidation.staticInteger(length,\Pkuramoto,\length,0,true);
        ^super.newCopyArgs(frequencies,coupling,phases,step,length,method,output)
    }
    storeArgs { ^[frequencies,coupling,phases,step,length,method,output] }
    prDerivative { |angles, omega, matrix|
        ^Array.fill(omega.size,{ |i|
            omega[i] + (Array.fill(omega.size,{ |j| matrix[i][j] * (angles[j]-angles[i]).sin }).sum / omega.size)
        })
    }
    embedInStream { |inval|
        var omega = PTRValidation.once(frequencies,inval), matrix = PTRValidation.once(coupling,inval), initial = PTRValidation.once(phases,inval);
        var h = PTRValidation.finite(PTRValidation.once(step,inval),\Pkuramoto,\step,0,true);
        var count = PTRValidation.integer(PTRValidation.once(length,inval),\Pkuramoto,\length,0,true);
        var solver = PTRValidation.once(method,inval), mode = PTRValidation.once(output,inval), n, angles, k1, k2, k3, k4, increment, unwrapped, wraps, magnitude, time = 0.0, next, index = 0, silent = 0;
        if(omega.isKindOf(SequenceableCollection).not or: { omega.isEmpty or: { omega.size > 128 } }) { Error("Pkuramoto: frequencies must contain 1..128 finite angular frequencies.").throw };
        omega = omega.asArray.copy; n = omega.size;
        omega.do { |x| PTRValidation.finite(x,\Pkuramoto,\frequencies) };
        if(matrix.isKindOf(SequenceableCollection)) {
            if(matrix.size != n) { Error("Pkuramoto: coupling must be a square matrix matching frequencies.").throw };
            matrix = matrix.collect { |row|
                if(row.isKindOf(SequenceableCollection).not or: { row.size != n }) { Error("Pkuramoto: coupling rows must match frequencies.").throw };
                row.do { |x| PTRValidation.finite(x,\Pkuramoto,\coupling) }; row.asArray.copy
            };
        } {
            PTRValidation.finite(matrix,\Pkuramoto,\coupling);
            matrix = Array.fill(n,{ matrix.dup(n) });
        };
        if([\rk4,\euler].includes(solver).not) { Error("Pkuramoto: method must be rk4 or euler.").throw };
        if([\state,\phases,\order,\wraps].includes(mode).not) { Error("Pkuramoto: output must be state, phases, order or wraps.").throw };
        if(initial.notNil) {
            if(initial.isKindOf(SequenceableCollection).not or: { initial.size != n }) { Error("Pkuramoto: phases must match frequencies.").throw };
            initial.do { |x| PTRValidation.finite(x,\Pkuramoto,\phases) };
        };
        if(count == 0) { ^inval };
        angles = if(initial.isNil) { Array.fill(n,{ 2pi.rand }) } { initial.asArray.collect { |x| x % 2pi } };
        while { index < count } {
            k1 = this.prDerivative(angles,omega,matrix);
            if(mode == \wraps and: { k1.every { |x| x == 0 } }) { ^inval };
            increment = if(solver == \euler) { k1*h } {
                k2 = this.prDerivative(angles+(k1*(h/2)),omega,matrix);
                k3 = this.prDerivative(angles+(k2*(h/2)),omega,matrix);
                k4 = this.prDerivative(angles+(k3*h),omega,matrix);
                (k1+(k2*2)+(k3*2)+k4)*(h/6)
            };
            increment.do { |x| PTRValidation.finite(x,\Pkuramoto,\phaseAdvancement) };
            unwrapped = angles+increment;
            wraps = unwrapped.collect { |x|
                var cycles = (x/2pi).floor;
                PTRValidation.finite(cycles,\Pkuramoto,\wraps);
                if(cycles.abs > 2147483647) { Error("Pkuramoto: wraps exceed exact Integer range.").throw };
                cycles.asInteger
            };
            angles = unwrapped.collect { |x| x % 2pi };
            next = PTRValidation.finite(time+h,\Pkuramoto,\time);
            if(next <= time) { Error("Pkuramoto: step no longer advances time at this precision.").throw }; time = next;
            magnitude = (angles.cos.mean.squared + angles.sin.mean.squared).sqrt.clip(0.0,1.0);
            if(mode != \wraps or: { wraps.any { |x| x != 0 } }) {
                inval = switch(mode,\phases,{ angles.copy },\order,{ magnitude },{
                    (time: time,phases: angles.copy,wraps: wraps.copy,order: magnitude)
                }).yield;
                silent = 0;
            } {
                silent = silent+1;
                if(silent > 100000) { Error("Pkuramoto: wraps output exceeded 100000 silent integration steps.").throw };
            };
            if(index == 2147483646) { Error("Pkuramoto: integration index range exceeded.").throw }; index = index+1;
        };
        ^inval
    }
}
