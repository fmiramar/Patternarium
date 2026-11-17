// SPDX-License-Identifier: GPL-3.0-or-later
TestPgraphWalk : UnitTest {
    setUp { thisThread.randSeed = 42 }
    test_normalizedEdges {
        var graph = (a: [[\b,0.5]], b: [(to: \c, weight: 2, data: (interval: 7))], c: []);
        var steps = PgraphWalk(graph,\a,3,output: \step).asStream.all;
        this.assertEquals(steps.collect { |s| s[\node] }, [\a,\b,\c]);
        this.assertEquals(steps[1][\weight], 0.5);
        this.assertEquals(steps[2][\data], (interval: 7));
        this.assertEquals(steps[0][\kind], \start);
    }
    test_zeroWeightsAndUniform {
        var graph = (a: [[\b,0],[\c,1]], b: [], c: []);
        this.assertEquals(PgraphWalk(graph,\a,2).asStream.all, [\a,\c]);
        this.assert(Pseed(Pseq([42]),PgraphWalk(graph,\a,2,\uniform)).asStream.all.size == 2);
    }
    test_nonBacktrackingAndMemory {
        var graph = (a: [\b], b: [\a,\c], c: []);
        this.assertEquals(PgraphWalk(graph,\a,3,\nonBacktracking).asStream.all, [\a,\b,\c]);
        this.assertEquals(PgraphWalk(graph,\a,3,memory: 2).asStream.all, [\a,\b,\c]);
        this.assertEquals(PgraphWalk((a: [\b], b: [\a]),\a,4,\nonBacktracking).asStream.all, [\a,\b,\a,\b]);
    }
    test_selfAvoidingAndDeadEnds {
        var graph = (a: [\b], b: [\a]);
        this.assertEquals(PgraphWalk(graph,\a,10,\selfAvoiding).asStream.all, [\a,\b]);
        this.assertEquals(PgraphWalk((a: [\b],b: []),\a,4,deadEnd: \stay).asStream.all, [\a,\b,\b,\b]);
        this.assertEquals(PgraphWalk((a: [\b],b: []),\a,5,deadEnd: \restart).asStream.all, [\a,\b,\a,\b,\a]);
    }
    test_reinforcementIsLocal {
        var graph = (a: [[\a,1]]), p = PgraphWalk(graph,\a,3,\reinforced,reinforcement: 0.5,output: \step,includeStart: false);
        var expected = [1,1.5,2];
        this.assertEquals(p.asStream.all.collect { |s| s[\weight] }, expected);
        this.assertEquals(p.asStream.all.collect { |s| s[\weight] }, expected);
        this.assertEquals(graph[\a], [[\a,1]]);
    }
    test_tabooAndLatestInval {
        var s = PgraphWalk((a: [\b,\c],b: [],c: []),\a,2,taboo: { |node,from,index,in| node == in }).asStream;
        this.assertEquals(s.next, \a);
        this.assertEquals(s.next(\b), \c);
        this.assertEquals(PgraphWalk((a: []),\a,1,taboo: [\a]).asStream.next, nil);
    }
    test_seededValidityAndIndependence {
        var graph = (a: [\b,\c],b: [\a,\c],c: [\a,\b]);
        [\uniform,\weighted,\reinforced].do { |strategy|
            var p = Pseed(Pseq([42]),PgraphWalk(graph,\a,20,strategy,reinforcement: 0.2)), values = p.asStream.all;
            this.assertEquals(values, p.asStream.all);
            values.doAdjacentPairs { |a,b| this.assert(graph[a].includes(b)) };
        };
    }
    test_zeroInvalAndStoreArgs {
        var p = PgraphWalk((a: []),\a,1), s = Routine { |in| p.embedInStream(in).yield };
        this.assertEquals(PgraphWalk((a: []),\a,0).asStream.next, nil);
        s.next; this.assertEquals(s.next(9), 9);
        this.assertEquals(p.storeArgs, [p.graph,\a,1,\weighted,0,0,nil,\stop,\node,true]);
    }
    test_fixedSeedTraces {
        var graph = (a: [[\b,1],[\c,3]],b: [[\a,2],[\c,1]],c: [[\a,1],[\b,2]]);
        this.assertEquals(Pseed(Pseq([42]),PgraphWalk(graph,\a,10,\uniform)).asStream.all, [\a,\b,\c,\a,\c,\b,\c,\b,\c,\a]);
        this.assertEquals(Pseed(Pseq([42]),PgraphWalk(graph,\a,10,\weighted)).asStream.all, [\a,\c,\b,\a,\c,\b,\c,\b,\c,\a]);
    }
    test_edgeMetadataOwnership {
        var p = PgraphWalk((a: [(to: \a, data: (x: 1))]),\a,2,output: \step,includeStart: false), s = p.asStream;
        s.next[\data][\x] = 99;
        this.assertEquals(s.next[\data][\x], 1);
        this.assertEquals(p.asStream.next[\data][\x], 1);
    }
    test_invalid {
        this.assertException({ PgraphWalk((a: []),\missing).asStream.next }, Error);
        this.assertException({ PgraphWalk((a: [[\b,-1]]),\a).asStream.next }, Error);
        this.assertException({ PgraphWalk((a: []),\a,strategy: \bad).asStream.next }, Error);
    }
}
