// SPDX-License-Identifier: GPL-3.0-or-later
PTRPointProcess {
    *advance { |time, delta, owner|
        var next = time + delta;
        PTRValidation.finite(next, owner, \time);
        if(next <= time) { Error("%: time failed to advance from % with delta %; precision exhausted.".format(owner, time, delta)).throw };
        ^next
    }
    *exponential { |rate|
        var u = 1.0.rand;
        while { u <= 0 } { u = 1.0.rand };
        ^u.log.neg / rate
    }
    *vector { |value, size, owner, argument, positive = false|
        var result = if(value.isKindOf(SequenceableCollection)) { value.asArray.copy } { value.dup(size) };
        if(result.size != size) { Error("%: % received %; expected % values.".format(owner, argument, value, size)).throw };
        result.do { |x| PTRValidation.finite(x, owner, argument, 0, positive) };
        ^result
    }
    *stabilityBound { |matrix, decay|
        // For K >= 0, a positive x solving (I-K)x=1 certifies rho(K)<1.
        // Collatz-Wielandt then supplies the upper bound max((Kx)/x).
        var n = matrix.size, kernel, rows, pivot, scale, temp, x, bound;
        kernel = matrix.collect { |row,i| row / decay[i] };
        bound = kernel.collect(_.sum).maxItem;
        if(bound < 1) { ^bound };
        rows = Array.fill(n, { |i| Array.fill(n, { |j| if(i == j) { 1.0 } { 0.0 } - kernel[i][j] }) ++ [1.0] });
        n.do { |column|
            pivot = column;
            n.do { |i| if(i >= column and: { rows[i][column].abs > rows[pivot][column].abs }) { pivot = i } };
            if(rows[pivot][column].abs < 1e-12) { ^inf };
            temp = rows[column]; rows[column] = rows[pivot]; rows[pivot] = temp;
            scale = rows[column][column]; rows[column] = rows[column] / scale;
            n.do { |i|
                if(i != column) { scale = rows[i][column]; rows[i] = rows[i] - (rows[column] * scale) };
            };
        };
        x = rows.collect(_.last);
        if(x.any { |v| v <= 0 or: { v.isNaN or: { v.abs == inf } } }) { ^inf };
        ^kernel.collect { |row,i| (row * x).sum / x[i] }.maxItem
    }
}
