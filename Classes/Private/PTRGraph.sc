// SPDX-License-Identifier: GPL-3.0-or-later
PTRGraph {
    *normalize { |graph|
        var result = Dictionary.new, targets = Set.new, edge, to, weight, data;
        if(graph.isKindOf(Dictionary).not) { Error("PgraphWalk: graph received %; expected a Dictionary or Event.".format(graph)).throw };
        graph.keysValuesDo { |from,adjacency|
            if(adjacency.isKindOf(Collection).not or: { adjacency.isKindOf(Dictionary) }) { Error("PgraphWalk: adjacency for % must be a finite collection of edges.".format(from)).throw };
            result[from] = adjacency.asArray.collect { |entry|
                weight = 1.0; data = nil;
                if(entry.isKindOf(Dictionary)) {
                    to = entry[\to]; weight = entry[\weight] ? 1.0; data = entry[\data].deepCopy;
                } {
                    if(entry.isKindOf(SequenceableCollection) and: { entry.isKindOf(String).not }) {
                        if(entry.size != 2) { Error("PgraphWalk: edge array % must be [destination, weight].".format(entry)).throw };
                        to = entry[0]; weight = entry[1];
                    } { to = entry };
                };
                if(to.isNil) { Error("PgraphWalk: edge destination cannot be nil.").throw };
                PTRValidation.finite(weight,\PgraphWalk,\weight,0);
                targets.add(to);
                edge = (from: from, to: to, weight: weight.asFloat, data: data);
                edge
            };
        };
        targets.do { |node| if(result.includesKey(node).not) { result[node] = [] } };
        ^result
    }
}
