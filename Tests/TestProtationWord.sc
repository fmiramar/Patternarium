// SPDX-License-Identifier: GPL-3.0-or-later
TestProtationWord : UnitTest {
    test_mechanicalFormula {
        var alpha = (5.sqrt - 1) / 2, phase = 0.2;
        var expected = Array.fill(50, { |n| (((n+1)*alpha+phase).floor - (n*alpha+phase).floor).asInteger });
        this.assertEquals(ProtationWord(alpha, phase, 50).asStream.all, expected);
    }
    test_rationalAndNormalization {
        this.assertEquals(ProtationWord(0.25, length: 8).asStream.all, [0,0,0,1,0,0,0,1]);
        this.assertEquals(ProtationWord(1.25, -1, 8).asStream.all, ProtationWord(0.25, 0, 8).asStream.all);
    }
    test_decimalRationalBoundary {
        this.assertEquals(ProtationWord(0.1, length: 10).asStream.all, [0,0,0,0,0,0,0,0,0,1]);
    }
    test_partitions {
        this.assertEquals(ProtationWord(0.25, length: 8, cuts: [0.25,0.75]).asStream.all, [0,1,1,2,0,1,1,2]);
    }
    test_balancedCounts {
        var values = ProtationWord((5.sqrt-1)/2, length: 200).asStream.all;
        (1..20).do { |n|
            var sums = (0..(values.size-n)).collect { |i| values.copyRange(i,i+n-1).sum };
            this.assert((sums.maxItem-sums.minItem) <= 1);
        };
    }
    test_stateAndInval {
        var p = ProtationWord(0.5, length: 1), a = p.asStream, b = p.asStream;
        var s = Routine { |in| p.embedInStream(in).yield };
        a.next;
        this.assertEquals(b.next, 0);
        this.assertEquals(p.storeArgs, [0.5,0,1,nil]);
        s.next; this.assertEquals(s.next(7), 7);
        this.assertEquals(ProtationWord(0.5, length: 0).asStream.next, nil);
    }
    test_invalid {
        [[0], [1], [0.5,0.4], [0.5,0.5]].do { |c| this.assertException({ ProtationWord(0.5, cuts: c).asStream.next }, Error) };
        this.assertException({ ProtationWord(inf).asStream.next }, Error);
    }
}
