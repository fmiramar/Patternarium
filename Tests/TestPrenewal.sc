// SPDX-License-Identifier: GPL-3.0-or-later
TestPrenewal : UnitTest {
    test_deltaTimeAndEvent {
        this.assertEquals(Prenewal(Pseq([1,2,3])).asStream.all, [1,2,3]);
        this.assertEquals(Prenewal(Pseq([1,2,3]), 10, output: \time).asStream.all, [11,13,16]);
        this.assertEquals(Prenewal(Pseq([1,2]), output: \event).asStream.all, [(time: 1, delta: 1),(time: 3, delta: 2)]);
    }
    test_lengthAndZeroConsumption {
        var consumed = 0;
        this.assertEquals(Prenewal(Pfunc { consumed = consumed + 1 }, length: 0).asStream.next, nil);
        this.assertEquals(consumed, 0);
        this.assertEquals(Prenewal(Pseq([1,2,3]), length: 2).asStream.all, [1,2]);
    }
    test_latestInvalAndTermination {
        var s = Routine { |in| Prenewal(Pfuncn({ |x| x }, 2)).embedInStream(in).yield };
        this.assertEquals(s.next(2), 2);
        this.assertEquals(s.next(3), 3);
        this.assertEquals(s.next(9), 9);
    }
    test_independenceAndParameters {
        var p = Prenewal(Pseq([1,2]), Pseq([10]), { 2 }, \time);
        this.assertEquals(p.asStream.all, [11,13]);
        this.assertEquals(p.asStream.all, [11,13]);
        this.assertEquals(p.storeArgs, [p.distribution,p.start,p.length,p.output]);
    }
    test_invalid {
        [0,-1,inf,0.0/0.0].do { |x| this.assertException({ Prenewal(Pseq([x])).asStream.next }, Error) };
        this.assertException({ Prenewal(Pseq([1]), output: \bad).asStream.next }, Error);
        this.assertException({ Prenewal(Pseq([1]), start: inf).asStream.next }, Error);
        this.assertException({ PpointProcess.new }, Error);
    }
    test_seeded {
        var p = Pseed(Pseq([42]), Prenewal(Pexprand(0.01,1), length: 20));
        this.assertEquals(p.asStream.all, p.asStream.all);
    }
}
