// SPDX-License-Identifier: GPL-3.0-or-later
TestPconstraint : UnitTest {
    test_solutionAndValues {
        var rule = { |h,x| h.includes(x).not };
        this.assertEquals(Pconstraint([0,1,2], rule, 3, 2).asStream.all, [[0,1,2],[0,2,1]]);
        this.assertEquals(Pconstraint([0,1], rule, 2, output: \values).asStream.all, [0,1]);
    }
    test_impossibleAndFailure {
        this.assertEquals(Pconstraint([0], { false }, 2).asStream.next, nil);
        this.assertException({ Pconstraint([0], { false }, 2, failure: \error).asStream.next }, Error);
        this.assertException({ Pconstraint([0,1], { false }, 2, maxBacktracks: 0).asStream.next }, Error);
    }
    test_functionsAndMultipleRules {
        var p = Pconstraint({ |i,h,in| [i+in, i+in+1] }, [{ |h,x| x >= 10 }, { |h,x| h.isEmpty or: { x > h.last } }], 3);
        this.assertEquals(p.asStream.next(10), [10,11,12]);
    }
    test_patternDomainSampledOncePerPosition {
        var count = 0, p = Pconstraint(Pfuncn({ count = count+1; [0,1] },2), { |h,x| h.includes(x).not }, 2, 2);
        this.assertEquals(p.asStream.all, [[0,1],[1,0]]);
        this.assertEquals(count, 2);
    }
    test_ownershipAndRandomSeed {
        var domain = [0,1,2], p = Pseed(Pseq([42]),Pconstraint(domain,{true},3,3,true));
        this.assertEquals(p.asStream.all, p.asStream.all);
        this.assertEquals(domain, [0,1,2]);
    }
    test_noPartialYieldAndIsolation {
        var p = Pconstraint([0,1], { |h,x,i| i < 2 }, 3);
        var q = Pconstraint([0,1], { true }, 2, 2), s = q.asStream, first = s.next;
        this.assertEquals(p.asStream.next, nil);
        first[0] = 9;
        this.assertEquals(s.next, [0,1]);
        this.assertEquals(q.asStream.next, [0,0]);
    }
    test_zeroAndLatestInval {
        var s = Routine { |in| Pconstraint([1],{true},1).embedInStream(in).yield };
        this.assertEquals(Pconstraint([1],{true},0).asStream.next, []);
        this.assertEquals(Pconstraint([1],{true},1,0).asStream.next, nil);
        s.next; this.assertEquals(s.next(9), 9);
    }
    test_invalid {
        this.assertException({ Pconstraint([nil],{true},1).asStream.next }, Error);
        this.assertException({ Pconstraint([1],42,1).asStream.next }, Error);
        this.assertException({ Pconstraint([1],{true},-1).asStream.next }, Error);
        this.assertException({ Pconstraint(Pseq([[1]]),{true},2).asStream.next }, Error);
    }
}
