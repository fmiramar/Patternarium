// SPDX-License-Identifier: GPL-3.0-or-later
TestPnumSeq : UnitTest {
    test_publishedPrefixes {
        // OEIS references and indexing are recorded in docs/algorithm-notes.md.
        var vectors = (
            recaman: [0,1,3,6,2,7,13,20,12,21,11,22],
            vanEck: [0,0,1,0,2,0,2,2,1,6,0,5],
            golomb: [1,2,2,3,3,4,4,4,5,5,5,6],
            kolakoski: [1,2,2,1,1,2,1,2,2,1,2,2,1,1,2],
            paperfolding: [1,1,0,1,1,0,0,1,1,1,0,0,1,0,0],
            rudinShapiro: [1,1,1,-1,1,1,-1,1,1,1,1,-1],
            stern: [0,1,1,2,1,3,2,3,1,4,3,5],
            calkinWilf: [[1,1],[1,2],[2,1],[1,3],[3,2],[2,3],[3,1]],
            lookAndSay: [[1],[1,1],[2,1],[1,2,1,1],[1,1,1,2,2,1],[3,1,2,2,1,1]],
            norgard: [0,1,-1,2,1,0,-2,3,-1,2,0,1,2,-1,-3,4]
        );
        vectors.keysValuesDo { |name, expected|
            this.assertEquals(PnumSeq(name, length: expected.size).asStream.all, expected, name.asString);
        };
    }
    test_independentStreamsAndReset {
        PnumSeq.names.do { |name|
            var p = PnumSeq(name, length: 6), a = p.asStream, b = p.asStream;
            this.assertEquals(a.nextN(6), b.nextN(6), name.asString);
            this.assertEquals(p.asStream.all, p.asStream.all);
        };
    }
    test_terminatesAndReturnsInval {
        PnumSeq.names.do { |name|
            var p = PnumSeq(name, length: 1), s = Routine { |in| p.embedInStream(in).yield };
            s.next;
            this.assertEquals(s.next(9), 9);
            this.assertEquals(PnumSeq(name, length: 0).asStream.next, nil);
        };
    }
    test_customSeedsAndBinary {
        this.assertEquals(PnumSeq(\recaman, 5, 4).asStream.all, [5,4,2,5]);
        this.assertEquals(PnumSeq(\vanEck, [1,2,1], 6).asStream.all, [1,2,1,2,2,1]);
        this.assertEquals(PnumSeq(\lookAndSay, [2,2], 3).asStream.all, [[2,2],[2,2],[2,2]]);
        this.assertEquals(PnumSeq(\rudinShapiro, length: 8, options: (binary: true)).asStream.all, [0,0,0,1,0,0,1,0]);
    }
    test_lookAndSayCopiesAndGuard {
        var seed = [1], s = PnumSeq(\lookAndSay, seed).asStream, first = s.next;
        first[0] = 9;
        this.assertEquals(seed, [1]);
        this.assertEquals(s.next, [1,1]);
        this.assertException({ PnumSeq(\lookAndSay, length: 5, options: (maxTermSize: 2)).asStream.all }, Error);
        this.assertEquals(PnumSeq(\lookAndSay, 1.dup(12), 2).asStream.all, [1.dup(12),[1,2,1]]);
    }
    test_kolakoskiGeneralAlphabet {
        var values = PnumSeq(\kolakoski, length: 50, options: (alphabet: [2,3])).asStream.all;
        var runs = List.new, current = values[0], count = 0;
        values.do { |x|
            if(x != current) { runs.add(count); count = 0; current = x };
            count = count + 1;
        };
        this.assertEquals(values.copyRange(0, runs.size-1), runs.asArray);
    }
    test_invalidAndStoreArgs {
        var p = PnumSeq(\stern, length: 4);
        this.assertEquals(p.storeArgs, [\stern,nil,4,()]);
        this.assertException({ PnumSeq(\unknown).asStream.next }, Error);
        this.assertException({ PnumSeq(\golomb, [1]).asStream.next }, Error);
        this.assertException({ PnumSeq(\recaman, -1).asStream.next }, Error);
        this.assertException({ PnumSeq(\lookAndSay, [12]).asStream.next }, Error);
        this.assertException({ PnumSeq(\vanEck, []).asStream.next }, Error);
        this.assertException({ PnumSeq(\stern, options: (binary: true)).asStream.next }, Error);
    }
    test_recurrenceProperties {
        var stern = PnumSeq(\stern, length: 256).asStream.all;
        var norgard = PnumSeq(\norgard, length: 256).asStream.all;
        var fractions = PnumSeq(\calkinWilf, length: 127).asStream.all;
        (1..127).do { |n|
            this.assertEquals(stern[2*n], stern[n]);
            this.assertEquals(stern[(2*n)+1], stern[n] + stern[n+1]);
            this.assertEquals(norgard[2*n], norgard[n].neg);
            this.assertEquals(norgard[(2*n)+1], norgard[n] + 1);
        };
        this.assertEquals(fractions.as(Set).size, fractions.size);
        this.assert(fractions.every { |pair| pair[0].gcd(pair[1]) == 1 });
    }
    test_parameterSamplingAndIntegerGuard {
        var calls = 0;
        var p = PnumSeq(Pseq([\stern]), length: { calls = calls + 1; 3 });
        this.assertEquals(p.asStream.all, [0,1,1]);
        this.assertEquals(calls, 1);
        this.assertException({ PTRSequenceAlgorithms.checkedInteger(2147483648.0) }, Error);
    }
    test_registryIsNotMutable {
        var names = PnumSeq.names;
        names[0] = \bad;
        this.assertEquals(PnumSeq.names.first, \recaman);
    }
}
