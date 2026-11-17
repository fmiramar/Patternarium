// SPDX-License-Identifier: GPL-3.0-or-later
Phawkes : PpointProcess {
    var <baseRate, <excitation, <decay, <dimensions, <interactionMatrix, <allowUnstable, <maxIntensity;
    *new { |baseRate = 1, excitation = 0.5, decay = 1, dimensions = 1, interactionMatrix, start = 0, length = inf, output = \event, allowUnstable = false, maxIntensity = 100000|
        PTRValidation.staticInteger(length, \Phawkes, \length, 0, true);
        ^super.newCopyArgs(start,length,output,baseRate,excitation,decay,dimensions,interactionMatrix,allowUnstable,maxIntensity)
    }
    storeArgs { ^[baseRate,excitation,decay,dimensions,interactionMatrix,start,length,output,allowUnstable,maxIntensity] }
    embedInStream { |inval|
        var parameters = this.prParameters(inval), time = parameters[0], count = parameters[1], mode = parameters[2];
        var matrix = interactionMatrix.copy, d, rates, betas, jump, unstable, cap, h, upper, wait, intensities, total, accepted, dimension, last, proposals, index = 0;
        unstable = PTRValidation.boolean(PTRValidation.once(allowUnstable,inval), \Phawkes, \allowUnstable);
        cap = PTRValidation.finite(PTRValidation.once(maxIntensity,inval), \Phawkes, \maxIntensity, 0, true);
        d = if(matrix.isNil) { PTRValidation.integer(PTRValidation.once(dimensions,inval), \Phawkes, \dimensions, 1) } {
            if(matrix.isKindOf(SequenceableCollection).not or: { matrix.isEmpty }) { Error("Phawkes: interactionMatrix must be a nonempty square matrix.").throw };
            matrix.size
        };
        if(d > 64) { Error("Phawkes: dimensions received %; expected at most 64.".format(d)).throw };
        rates = PTRPointProcess.vector(PTRValidation.once(baseRate,inval),d,\Phawkes,\baseRate);
        betas = PTRPointProcess.vector(PTRValidation.once(decay,inval),d,\Phawkes,\decay,true);
        if(matrix.isNil) {
            jump = PTRValidation.finite(PTRValidation.once(excitation,inval),\Phawkes,\excitation,0);
            matrix = Array.fill(d, { |i| Array.fill(d, { |j| if(i == j) { jump } { 0.0 } }) });
        } {
            matrix = matrix.collect { |row|
                if(row.isKindOf(SequenceableCollection).not) { Error("Phawkes: interactionMatrix rows must be collections.").throw };
                PTRPointProcess.vector(row,d,\Phawkes,\interactionMatrix)
            };
        };
        if(unstable.not and: { PTRPointProcess.stabilityBound(matrix,betas) >= (1 - 1e-10) }) {
            Error("Phawkes: interactionMatrix/excitation failed the stationary spectral-radius bound < 1; use allowUnstable explicitly to override.").throw;
        };
        if(rates.sum > cap) { Error("Phawkes: baseRate total % exceeds maxIntensity %.".format(rates.sum,cap)).throw };
        if(count == 0 or: { rates.sum == 0 }) { ^inval };
        h = Array.fill(d,0.0); last = time;
        while { index < count } {
            accepted = false; proposals = 0;
            while { accepted.not } {
                proposals = proposals + 1;
                if(proposals > 100000) { Error("Phawkes: thinning proposal limit 100000 exceeded before next event.").throw };
                upper = rates.sum + h.sum;
                wait = PTRPointProcess.exponential(upper);
                time = PTRPointProcess.advance(time,wait,\Phawkes);
                h = h * (betas * wait.neg).exp;
                intensities = rates + h; total = intensities.sum;
                accepted = (total >= upper) or: { (1.0.rand * upper) < total };
            };
            dimension = if(d == 1) { 0 } { intensities.normalizeSum.windex };
            h = h + matrix.collect { |row| row[dimension] };
            if((rates.sum + h.sum) > cap) { Error("Phawkes: post-event total intensity % exceeds maxIntensity %.".format(rates.sum+h.sum,cap)).throw };
            inval = this.prOutput(time,time-last,mode,(dimension: dimension, intensity: intensities[dimension], totalIntensity: total)).yield;
            if(index == 2147483646) { Error("Phawkes: exact arrival index range exceeded.").throw };
            last = time; index = index + 1;
        };
        ^inval
    }
}
