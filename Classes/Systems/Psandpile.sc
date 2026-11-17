// SPDX-License-Identifier: GPL-3.0-or-later
Psandpile : Pattern {
    var <size, <initial, <drive, <threshold, <boundary, <length, <output, <maxTopplings;
    *new { |size = #[8,8], initial, drive, threshold = 4, boundary = \open, length = inf, output = \avalanche, maxTopplings = 1000000|
        PTRValidation.staticInteger(threshold,\Psandpile,\threshold,1);
        PTRValidation.staticInteger(length,\Psandpile,\length,0,true);
        PTRValidation.staticInteger(maxTopplings,\Psandpile,\maxTopplings,0);
        ^super.newCopyArgs(size,initial,drive,threshold,boundary,length,output,maxTopplings)
    }
    storeArgs { ^[size,initial,drive,threshold,boundary,length,output,maxTopplings] }
    prCoordinate { |index, dimensions|
        ^if(dimensions.size == 1) { [index] } { [index % dimensions[0],index.div(dimensions[0])] }
    }
    prGrid { |flat, dimensions|
        ^if(dimensions.size == 1) { flat.copy } { flat.clump(dimensions[0]) }
    }
    embedInStream { |inval|
        var dimensions = PTRValidation.once(size,inval), level = PTRValidation.integer(PTRValidation.once(threshold,inval),\Psandpile,\threshold,1);
        var count = PTRValidation.integer(PTRValidation.once(length,inval),\Psandpile,\length,0,true);
        var limit = PTRValidation.integer(PTRValidation.once(maxTopplings,inval),\Psandpile,\maxTopplings,0);
        var policy = PTRValidation.once(boundary,inval), mode = PTRValidation.once(output,inval);
        var n, degree, flat, source, site, coordinate, queue, queued, enqueue, head, active, topplings, lost, mass, current, neighbor, x, y, offsets, position, index = 0;
        dimensions = if(dimensions.isKindOf(Integer)) { [dimensions] } { dimensions };
        if(dimensions.isKindOf(SequenceableCollection).not or: { [1,2].includes(dimensions.size).not }) { Error("Psandpile: size must be an Integer or a one/two-element collection.").throw };
        dimensions = dimensions.asArray.copy;
        dimensions.do { |d| PTRValidation.integer(d,\Psandpile,\size,1) };
        n = dimensions.collect(_.asFloat).product;
        if(n > 65536) { Error("Psandpile: size exceeds 65536 sites.").throw }; n = n.asInteger;
        degree = dimensions.size*2;
        if(level < degree) { Error("Psandpile: threshold % must be at least % for this dimension.".format(level,degree)).throw };
        if(limit > 1000000) { Error("Psandpile: maxTopplings must be at most 1000000.").throw };
        if([\open,\closed].includes(policy).not) { Error("Psandpile: boundary must be open or closed.").throw };
        if([\avalanche,\size].includes(mode).not) { Error("Psandpile: output must be avalanche or size.").throw };
        if(initial.isNil) { flat = Array.fill(n,0) } {
            if(initial.isKindOf(SequenceableCollection).not) { Error("Psandpile: initial must match the grid shape.").throw };
            if(dimensions.size == 1) {
                if(initial.size != n) { Error("Psandpile: initial must match the 1D size.").throw };
                flat = initial.asArray.copy;
            } {
                if(initial.size != dimensions[1] or: { initial.every { |row| row.isKindOf(SequenceableCollection) and: { row.size == dimensions[0] } }.not }) { Error("Psandpile: initial rows/columns must match size [width,height].").throw };
                flat = initial.collect(_.asArray).flatten(1).copy;
            };
            flat.do { |height| PTRValidation.integer(height,\Psandpile,\initial,0) };
        };
        if(drive.isKindOf(Pattern)) { source = drive.asStream };
        offsets = if(dimensions.size == 1) { [[-1],[1]] } { [[-1,0],[1,0],[0,-1],[0,1]] };
        while { index < count } {
            site = if(drive.isNil) { n.rand } {
                if(source.notNil) { source.next(inval) } {
                    if(drive.isKindOf(Function)) { drive.value(this.prGrid(flat,dimensions),index,inval) } { drive }
                }
            };
            if(site.isNil) { ^inval };
            if(site.isKindOf(SequenceableCollection)) {
                if(site.size != dimensions.size) { Error("Psandpile: drive coordinate must match dimensions.").throw };
                site.do { |v,i| PTRValidation.integer(v,\Psandpile,\drive,0); if(v >= dimensions[i]) { Error("Psandpile: drive coordinate % is outside grid.".format(site)).throw } };
                position = site[0] + if(dimensions.size == 2) { site[1]*dimensions[0] } { 0 };
            } {
                PTRValidation.integer(site,\Psandpile,\drive,0);
                if(site >= n) { Error("Psandpile: drive index % is outside grid.".format(site)).throw }; position = site;
            };
            coordinate = this.prCoordinate(position,dimensions);
            mass = flat.collect(_.asFloat).sum + 1;
            if(mass > 2147483646) { Error("Psandpile: total grain count exceeds exact Integer range.").throw };
            if(policy == \closed and: { level == degree and: { mass > (n.asFloat*(level-1)) } }) { Error("Psandpile: closed conservative grid cannot stabilize above its stable capacity.").throw };
            flat[position] = flat[position]+1;
            queue = List.new; queued = Array.fill(n,false); head = 0; active = Set.new; topplings = 0; lost = 0;
            enqueue = { |cell| if(flat[cell] >= level and: { queued[cell].not }) { queue.add(cell); queued[cell] = true } };
            n.do { |i| enqueue.value(i) };
            while { head < queue.size } {
                current = queue[head]; head = head+1; queued[current] = false;
                if(flat[current] >= level) {
                    if(topplings >= limit) { Error("Psandpile: maxTopplings % exceeded before stabilization.".format(limit)).throw };
                    topplings = topplings+1; active.add(current); flat[current] = flat[current]-level; lost = lost+(level-degree);
                    x = current % dimensions[0]; y = current.div(dimensions[0]);
                    offsets.do { |offset|
                        var nx = x+offset[0], ny = y + if(dimensions.size == 2) { offset[1] } { 0 };
                        if(nx >= 0 and: { nx < dimensions[0] and: { ny >= 0 and: { if(dimensions.size == 1) { ny == 0 } { ny < dimensions[1] } } } }) {
                            neighbor = nx+(ny*dimensions[0]); flat[neighbor] = flat[neighbor]+1; enqueue.value(neighbor);
                        } {
                            if(policy == \open) { lost = lost+1 } { flat[current] = flat[current]+1 };
                        };
                    };
                    enqueue.value(current);
                };
            };
            inval = if(mode == \size) { topplings } {
                (drive: coordinate,avalancheSize: topplings,activeSites: active.size,lostGrains: lost,
                    toppledSites: active.asArray.sort.collect { |i| this.prCoordinate(i,dimensions) },state: this.prGrid(flat,dimensions))
            }.yield;
            if(index == 2147483646) { Error("Psandpile: output index range exceeded.").throw }; index = index+1;
        };
        ^inval
    }
}
