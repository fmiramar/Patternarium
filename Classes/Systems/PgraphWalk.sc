// SPDX-License-Identifier: GPL-3.0-or-later
PgraphWalk : Pattern {
    var <graph, <start, <length, <strategy, <memory, <reinforcement, <taboo, <deadEnd, <output, <includeStart;
    *new { |graph, start, length = inf, strategy = \weighted, memory = 0, reinforcement = 0, taboo, deadEnd = \stop, output = \node, includeStart = true|
        PTRValidation.staticInteger(length,\PgraphWalk,\length,0,true);
        PTRValidation.staticInteger(memory,\PgraphWalk,\memory,0);
        ^super.newCopyArgs(graph,start,length,strategy,memory,reinforcement,taboo,deadEnd,output,includeStart)
    }
    storeArgs { ^[graph,start,length,strategy,memory,reinforcement,taboo,deadEnd,output,includeStart] }
    prForbidden { |node, from, index, inval|
        if(taboo.isNil) { ^false };
        if(taboo.isKindOf(Function)) { ^PTRValidation.boolean(taboo.value(node,from,index,inval),\PgraphWalk,\tabooResult) };
        ^taboo.includes(node)
    }
    prStep { |edge, mode, kind|
        ^if(mode == \node) { edge[\to] } {
            edge.copy.put(\node,edge[\to]).put(\kind,kind).put(\data,edge[\data].deepCopy)
        }
    }
    embedInStream { |inval|
        var network = PTRGraph.normalize(graph), origin = PTRValidation.once(start,inval), current, previous;
        var count = PTRValidation.integer(PTRValidation.once(length,inval),\PgraphWalk,\length,0,true);
        var policy = PTRValidation.once(strategy,inval), end = PTRValidation.once(deadEnd,inval), mode = PTRValidation.once(output,inval);
        var first = PTRValidation.boolean(PTRValidation.once(includeStart,inval),\PgraphWalk,\includeStart);
        var recall = PTRValidation.integer(PTRValidation.once(memory,inval),\PgraphWalk,\memory,0);
        var increment = PTRValidation.finite(PTRValidation.once(reinforcement,inval),\PgraphWalk,\reinforcement,0);
        var visited, recent = List.new, candidates, filtered, edge, kind, weights, index = 0;
        if(network.includesKey(origin).not) { Error("PgraphWalk: start % is not a known graph node.".format(origin)).throw };
        if([\uniform,\weighted,\nonBacktracking,\selfAvoiding,\reinforced].includes(policy).not) { Error("PgraphWalk: unknown strategy %.".format(policy)).throw };
        if([\stop,\stay,\restart].includes(end).not) { Error("PgraphWalk: deadEnd must be stop, stay or restart.").throw };
        if([\node,\step].includes(mode).not) { Error("PgraphWalk: output must be node or step.").throw };
        if(taboo.notNil and: { taboo.isKindOf(Function).not and: { taboo.isKindOf(Collection).not } }) { Error("PgraphWalk: taboo must be a Collection, Function or nil.").throw };
        if(count == 0 or: { this.prForbidden(origin,nil,0,inval) }) { ^inval };
        current = origin;
        if(policy == \selfAvoiding) { visited = Set[origin] };
        if(recall > 0) { recent.add(origin) };
        if(first) {
            inval = this.prStep((to: origin,weight: 0.0),mode,\start).yield; index = index + 1;
        };
        while { index < count } {
            candidates = network[current].reject { |item| this.prForbidden(item[\to],current,index,inval) };
            if(policy != \uniform) { candidates = candidates.select { |item| item[\weight] > 0 } };
            if(policy == \selfAvoiding) { candidates = candidates.reject { |item| visited.includes(item[\to]) } };
            if(policy == \nonBacktracking and: { previous.notNil }) {
                filtered = candidates.reject { |item| item[\to] == previous };
                if(filtered.notEmpty) { candidates = filtered };
            };
            if(recall > 0) {
                filtered = candidates.reject { |item| recent.includes(item[\to]) };
                if(filtered.notEmpty) { candidates = filtered };
            };
            kind = \edge;
            if(candidates.isEmpty) {
                if(end == \stop) { ^inval };
                if(end == \restart) {
                    if(this.prForbidden(origin,current,index,inval)) { ^inval };
                    edge = (from: current,to: origin,weight: 0.0); kind = \restart;
                    previous = nil; recent.clear;
                    if(visited.notNil) { visited.clear.add(origin) };
                } {
                    if(this.prForbidden(current,current,index,inval)) { ^inval };
                    edge = (from: current,to: current,weight: 0.0); kind = \stay;
                };
            } {
                if(policy == \uniform) { edge = candidates.choose } {
                    weights = candidates.collect { |item| item[\weight] };
                    PTRValidation.finite(weights.sum,\PgraphWalk,\totalWeight,0,true);
                    edge = candidates[weights.normalizeSum.windex];
                };
                previous = current;
            };
            current = edge[\to];
            if(visited.notNil) { visited.add(current) };
            if(recall > 0) { recent.add(current); if(recent.size > recall) { recent.removeAt(0) } };
            // Copy before updating effective weights so step output reports the weight used.
            filtered = this.prStep(edge,mode,kind);
            if(policy == \reinforced and: { kind == \edge }) {
                edge[\weight] = PTRValidation.finite(edge[\weight]+increment,\PgraphWalk,\reinforcedWeight,0);
            };
            inval = filtered.yield;
            if(index == 2147483646) { Error("PgraphWalk: exact output index range exceeded.").throw };
            index = index + 1;
        };
        ^inval
    }
}
