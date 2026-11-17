// SPDX-License-Identifier: GPL-3.0-or-later
Pbranching : Pattern {
    var <seed, <offspring, <valueFunction, <maxDepth, <maxNodes, <traversal, <output;
    *new { |seed, offspring, valueFunction, maxDepth = 8, maxNodes = 10000, traversal = \breadth, output = \node|
        PTRValidation.staticInteger(maxDepth,\Pbranching,\maxDepth,0);
        PTRValidation.staticInteger(maxNodes,\Pbranching,\maxNodes,1);
        PTRValidation.staticInteger(offspring,\Pbranching,\offspring,0);
        if(valueFunction.notNil and: { valueFunction.isKindOf(Function).not }) { Error("Pbranching: valueFunction must be a Function or nil.").throw };
        ^super.newCopyArgs(seed,offspring,valueFunction,maxDepth,maxNodes,traversal,output)
    }
    storeArgs { ^[seed,offspring,valueFunction,maxDepth,maxNodes,traversal,output] }
    embedInStream { |inval|
        var depth = PTRValidation.integer(PTRValidation.once(maxDepth,inval),\Pbranching,\maxDepth,0);
        var limit = PTRValidation.integer(PTRValidation.once(maxNodes,inval),\Pbranching,\maxNodes,1);
        var walk = PTRValidation.once(traversal,inval), mode = PTRValidation.once(output,inval), value = seed.value(inval);
        var queue = List.new, source, node, count, children, created = 1, head = 0;
        if(limit > 1000000) { Error("Pbranching: maxNodes received %; expected at most 1000000.".format(limit)).throw };
        if(value.isNil) { Error("Pbranching: seed cannot be nil.").throw };
        if([\breadth,\depth].includes(walk).not) { Error("Pbranching: traversal must be breadth or depth.").throw };
        if([\node,\value].includes(mode).not) { Error("Pbranching: output must be node or value.").throw };
        if(offspring.isKindOf(Pattern)) { source = offspring.asStream };
        queue.add((value: value,depth: 0,index: 0));
        while { if(walk == \breadth) { head < queue.size } { queue.notEmpty } } {
            node = if(walk == \breadth) { queue[head] } { queue.pop };
            head = head + 1;
            inval = if(mode == \node) { node.copy } { node[\value] }.yield;
            if(node[\depth] < depth) {
                count = if(source.notNil) { source.next(inval) ? 0 } {
                    if(offspring.isKindOf(Function)) { offspring.value(node.copy,inval) } { offspring }
                };
                PTRValidation.integer(count,\Pbranching,\offspring,0);
                if((created.asFloat+count) > limit) { Error("Pbranching: maxNodes % exceeded before allocating % children.".format(limit,count)).throw };
                children = Array.fill(count,{ |i|
                    value = if(valueFunction.isNil) { node[\value] } { valueFunction.value(node.copy,i,inval) };
                    if(value.isNil) { Error("Pbranching: valueFunction returned nil for child %.".format(i)).throw };
                    (value: value,depth: node[\depth]+1,index: created+i,parentIndex: node[\index],childIndex: i)
                });
                created = created + count;
                queue.addAll(if(walk == \breadth) { children } { children.reverse });
            };
        };
        ^inval
    }
}
