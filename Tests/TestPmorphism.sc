// SPDX-License-Identifier: GPL-3.0-or-later
TestPmorphism : UnitTest {
    test_parallelAndSeed {
        this.assertEquals(Pmorphism([\a], (a: [\a,\b], b: [\a]), 3, \generations, true).asStream.all,
            [[\a], [\a,\b], [\a,\b,\a], [\a,\b,\a,\a,\b]]);
    }
    test_missingAndSymbols { this.assertEquals(Pmorphism([1,2], Dictionary[1 -> [3,4]], 1).asStream.all, [3,4,2]) }
    test_context {
        this.assertEquals(Pmorphism([1,2,3], Dictionary[2 -> { |s,l,r,g,i| [l,r,g,i] }], 1).asStream.all, [1,1,3,1,1,3]);
        this.assertEquals(Pmorphism([1], Dictionary[1 -> { |s,l,r| [l.isNil,r.isNil] }]).asStream.all, [true,true]);
    }
    test_patternReplacements { this.assertEquals(Pmorphism([1,1], Dictionary[1 -> Pseq([2,3])]).asStream.all, [2,3,2,3]) }
    test_zero {
        this.assertEquals(Pmorphism([1], (), 0).asStream.all, nil);
        this.assertEquals(Pmorphism([1], (), 0, \symbols, true).asStream.all, [1]);
    }
    test_emptyAndDeletion { this.assertEquals(Pmorphism([1], Dictionary[1 -> []], 2, \generations).asStream.all, [[],[]]) }
    test_seedPattern { this.assertEquals(Pmorphism(Pseq([1,2]), (), 1).asStream.all, [1,2]) }
    test_noMutationAndFreshGeneration {
        var seed = [1,2], p = Pmorphism(seed, (), 2, \generations), s = p.asStream, a = s.next, b = s.next;
        this.assert(a !== b);
        a[0] = 9;
        this.assertEquals(seed, [1,2]);
        this.assertEquals(b, [1,2]);
        this.assertEquals(p.asStream.next, [1,2]);
    }
    test_eventAndObjectSymbols {
        var object = Object.new, event = (x: 1);
        this.assertEquals(Pmorphism([object,event], (), 1).asStream.all, [object,event]);
    }
    test_dynamicParameters {
        this.assertEquals(Pmorphism([1], (), Pseq([2]), Pseq([\generations]), false, Pseq([4])).asStream.all, [[1],[1]]);
    }
    test_seededRules {
        var p = Pseed(Pseq([123]), Pmorphism([1,1,1], Dictionary[1 -> { [1,2].choose }], 2));
        this.assertEquals(p.asStream.all, p.asStream.all);
    }
    test_latestInval {
        var s = Pmorphism([1], Dictionary[1 -> { |s,l,r,g,i,in| in }], 2, \symbols, true).asStream;
        this.assertEquals(s.next(2), 1);
        this.assertEquals(s.next(3), 3);
    }
    test_storeArgsAndReturnInval {
        var p = Pmorphism([1], (), 1), stream = Routine { |in| p.embedInStream(in).yield };
        this.assertEquals(p.storeArgs, [[1], p.rules, 1, \symbols, false, nil]);
        this.assertEquals(stream.next(3), 1);
        this.assertEquals(stream.next(8), 8);
    }
    test_exactBound {
        this.assertEquals(Pmorphism([1], Dictionary[1 -> Pseq([2,3])], 1, maxSymbols: 2).asStream.all, [2,3]);
    }
    test_infiniteRequiresExplicitLimit {
        this.assertException({ Pmorphism([1], (), inf).asStream.next }, Error);
        this.assertEquals(Pmorphism([1], (), inf, maxSymbols: 2).asStream.nextN(3), [1,1,1]);
    }
    test_limitsAndInvalid {
        this.assertException({ Pmorphism([1], Dictionary[1 -> Pseries()], 1, maxSymbols: 4).asStream.all }, Error);
        this.assertException({ Pmorphism(Pseries(), (), 1, maxSymbols: 4).asStream.next }, Error);
        this.assertException({ Pmorphism([1,2], (), 1, maxSymbols: 1).asStream.next }, Error);
        this.assertException({ Pmorphism([1], (), -1).asStream.next }, Error);
        this.assertException({ Pmorphism([1], (), 1, \wrong).asStream.next }, Error);
    }
}
