// SPDX-License-Identifier: GPL-3.0-or-later
TestPscan : UnitTest {
    test_accumulation {
        this.assertEquals(Pscan(Pseq([1, 2, 3]), 0, _ + _).asStream.all, [1, 3, 6]);
    }
    test_lengthAndInitial {
        this.assertEquals(Pscan(Pseries(), 10, _ + _, 2, true).asStream.all, [10, 10, 11]);
    }
    test_zeroDoesNotConsume {
        var count = 0;
        this.assertEquals(Pscan(Pfunc { count = count + 1 }, 3, _ + _, 0).asStream.all, nil);
        this.assertEquals(count, 0);
        this.assertEquals(Pscan(Pseq([0], 0), 3, _ + _, 0, true).asStream.all, [3]);
    }
    test_nilTerminates {
        this.assertEquals(Pscan(Pseq([1, 2, 3]), 0, { |s, x| if(x < 3) { s + x } }).asStream.all, [1, 3]);
    }
    test_indexAndLatestInval {
        var p = Pscan(Pfunc { |in| in }, 0, { |s, x, i, in| [x, i, in] }, 2).asStream;
        this.assertEquals(p.next(7), [7, 0, 7]);
        this.assertEquals(p.next(9), [9, 1, 9]);
        this.assertEquals(p.next(11), nil);
    }
    test_embedReturnsInval {
        var p = Routine { |in| Pscan(Pseq([1]), 0, _ + _).embedInStream(in).yield };
        this.assertEquals(p.next(3), 1);
        this.assertEquals(p.next(8), 8);
    }
    test_independenceAndRecreation {
        var p = Pscan(Pseq([1, 2]), 0, _ + _), a = p.asStream, b = p.asStream;
        this.assertEquals(a.nextN(2), [1, 3]);
        this.assertEquals(b.nextN(2), [1, 3]);
        this.assertEquals(p.asStream.all, [1, 3]);
    }
    test_functionInitialAndEventState {
        var p = Pscan(Pseq([2]), { |in| (sum: in) }, { |s, x| (sum: s[\sum] + x) }).asStream;
        this.assertEquals(p.next(5), (sum: 7));
    }
    test_storeArgs {
        var p = Pscan(Pseq([1]), 0, _ + _, 1, true);
        this.assertEquals(p.storeArgs, [p.pattern, p.initial, p.function, 1, true]);
    }
    test_onceEvaluatedParameters {
        var calls = 0, p = Pscan(Pseq([1,2,3]), 0, _ + _, { calls = calls + 1; 2 });
        this.assertEquals(p.asStream.all, [1,3]);
        this.assertEquals(calls, 1);
        this.assertEquals(Pscan(Pseq([1,2]), 0, _ + _, Pseq([1])).asStream.all, [1]);
    }
    test_emptySource {
        this.assertEquals(Pscan(Pseq([0], 0), 0, _ + _).asStream.next, nil);
    }
    test_invalidLength {
        [-1, 1.5, nil].do { |n| this.assertException({ Pscan(Pseq([1]), 0, _ + _, n).asStream.next }, Error) };
    }
}
