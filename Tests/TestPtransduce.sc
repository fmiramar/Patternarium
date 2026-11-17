// SPDX-License-Identifier: GPL-3.0-or-later
TestPtransduce : UnitTest {
    test_cardinality {
        this.assertEquals(Ptransduce(Pseq([0,1,2]), 0, { |s,x| (state: s+1, emit: x.dup(x)) }).asStream.all, [1,2,2]);
    }
    test_nestedArray { this.assertEquals(Ptransduce(Pseq([1]), 0, { (state: 0, emit: [[1,2]]) }).asStream.all, [[1,2]]) }
    test_stopWithoutFlush {
        var flushed = false;
        this.assertEquals(Ptransduce(Pseries(), 0, { (emit: [1,2], stop: true) }, { flushed = true }).asStream.all, [1,2]);
        this.assert(flushed.not);
    }
    test_nilWithoutFlush {
        var flushed = false;
        this.assertEquals(Ptransduce(Pseq([1]), 0, { nil }, { flushed = true }).asStream.all, nil);
        this.assert(flushed.not);
    }
    test_flushOnce {
        var calls = 0;
        this.assertEquals(Ptransduce(Pseq([1,2]), 0, { |s,x| (state: s+x) }, { |s,i| calls = calls+1; (state: s, emit: [s,i]) }).asStream.all, [3,2]);
        this.assertEquals(calls, 1);
    }
    test_emptyFlush { this.assertEquals(Ptransduce(Pseq([0], 0), 8, { nil }, { |s| (state: s, emit: [s]) }).asStream.all, [8]) }
    test_latestInvalAfterEveryEmission {
        var seen, s = Ptransduce(Pseq([1,2]), 0, { |state,x,i,in|
            seen = [i,in]; (state: state, emit: [x,x])
        }).asStream;
        s.next(10); s.next(20); s.next(30);
        this.assertEquals(seen, [1,30]);
    }
    test_independence {
        var p = Ptransduce(Pseq([1,2]), { [] }, { |s,x| s = s.add(x); (state: s, emit: [s.copy]) });
        this.assertEquals(p.asStream.all, [[1],[1,2]]);
        this.assertEquals(p.asStream.all, [[1],[1,2]]);
    }
    test_storeArgsAndReturnInval {
        var p = Ptransduce(Pseq([1]), 0, { |s,x| (state: s, emit: [x]) });
        var stream = Routine { |in| p.embedInStream(in).yield };
        this.assertEquals(p.storeArgs, [p.pattern, 0, p.function, nil]);
        this.assertEquals(stream.next(3), 1);
        this.assertEquals(stream.next(8), 8);
    }
    test_flushReceivesLatestInval {
        var seen, stream = Ptransduce(Pseq([1]), 0, { |s,x| (state: s, emit: [x,x]) }, { |s,i,in|
            seen = [i,in]; (state: s)
        }).asStream;
        stream.next(3); stream.next(4); stream.next(9);
        this.assertEquals(seen, [1,9]);
    }
    test_protocolErrors {
        [42, (emit: []), (state: 0, emit: 2), (state: 0, emit: [nil]), (state: 0, stop: 1)].do { |r|
            this.assertException({ Ptransduce(Pseq([1]), 0, { r }).asStream.next }, Error);
        };
    }
}
