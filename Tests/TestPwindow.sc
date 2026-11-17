// SPDX-License-Identifier: GPL-3.0-or-later
TestPwindow : UnitTest {
    test_overlap { this.assertEquals(Pwindow(Pseries(0, 1, 6), 3).asStream.all, [[0,1,2], [1,2,3], [2,3,4], [3,4,5]]) }
    test_clumpsAndPartial { this.assertEquals(Pwindow(Pseries(0, 1, 7), 3, 3, true).asStream.all, [[0,1,2], [3,4,5], [6]]) }
    test_gaps { this.assertEquals(Pwindow(Pseries(0, 1, 9), 2, 4, true).asStream.all, [[0,1], [4,5], [8]]) }
    test_shortSource {
        this.assertEquals(Pwindow(Pseq([1]), 3).asStream.all, nil);
        this.assertEquals(Pwindow(Pseq([1]), 3, 1, true).asStream.all, [[1]]);
    }
    test_noDuplicatePartial {
        this.assertEquals(Pwindow(Pseries(0, 1, 4), 3, 1, true).asStream.all, [[0,1,2], [1,2,3]]);
        this.assertEquals(Pwindow(Pseries(0, 1, 5), 3, 2, true).asStream.all, [[0,1,2], [2,3,4]]);
    }
    test_partialNeedsNewItem { this.assertEquals(Pwindow(Pseries(0, 1, 4), 3, 2, true).asStream.all, [[0,1,2], [2,3]]) }
    test_freshArrays {
        var s = Pwindow(Pseries(0, 1, 4), 2).asStream, a = s.next, b = s.next;
        this.assert(a !== b);
        this.assertEquals(a, [0,1]);
    }
    test_invalAndEvents {
        var s = Pwindow(Pfunc { |in| in }, 2).asStream;
        this.assertEquals(s.next((x: 1)), [(x: 1), (x: 1)]);
        this.assertEquals(s.next((x: 2)), [(x: 1), (x: 2)]);
    }
    test_independentStreams {
        var p = Pwindow(Pseries(0, 1, 4), 2), a = p.asStream, b = p.asStream;
        a.next;
        this.assertEquals(b.next, [0,1]);
        this.assertEquals(a.next, [1,2]);
    }
    test_parametersAndStoreArgs {
        var p = Pwindow(Pseq([1,2,3]), { 2 }, { 1 }, true);
        this.assertEquals(p.asStream.all, [[1,2], [2,3]]);
        this.assertEquals(p.storeArgs, [p.pattern, p.size, p.step, true]);
    }
    test_emptyAndTerminationInval {
        var s = Routine { |in| Pwindow(Pseq([1,2]), 2).embedInStream(in).yield };
        this.assertEquals(Pwindow(Pseq([0], 0), 2, 1, true).asStream.next, nil);
        this.assertEquals(s.next(3), [1,2]);
        this.assertEquals(s.next(9), 9);
    }
    test_parameterPatterns {
        this.assertEquals(Pwindow(Pseq([1,2,3]), Pseq([2]), Pseq([1])).asStream.all, [[1,2],[2,3]]);
    }
    test_invalid {
        [0, -1, 1.5, nil].do { |x|
            this.assertException({ Pwindow(Pseq([1]), x).asStream.next }, Error);
            this.assertException({ Pwindow(Pseq([1]), 1, x).asStream.next }, Error);
        };
    }
    test_boundedReferenceWindows {
        [0,1,2,7,17].do { |length|
            [1,2,3,5,8].do { |width|
                [1,2,3,5,9].do { |stride|
                    [false,true].do { |partial|
                        var expected = List.new, offset = 0, lastEnd = -1, done = false;
                        while { offset < length and: { done.not } } {
                            if((offset+width) <= length) {
                                expected.add(Array.series(width,offset,1));
                                lastEnd = offset+width-1;
                            } {
                                if(partial and: { (length-1) > lastEnd }) {
                                    expected.add(Array.series(length-offset,offset,1));
                                };
                                done = true;
                            };
                            offset = offset+stride;
                        };
                        this.assertEquals(Pwindow(Pseries(0,1,length),width,stride,partial).asStream.all ? [],expected.asArray);
                    };
                };
            };
        };
    }
    test_outputMutationDoesNotChangeBufferedItems {
        var stream = Pwindow(Pseries(0,1,8),3).asStream, first = stream.next;
        first[1] = 99;
        this.assertEquals(stream.next,[1,2,3]);
        this.assertEquals(stream.next,[2,3,4]);
    }
    test_latestInvalDuringGap {
        var seen = List.new;
        var stream = Pwindow(Pfuncn({ |in| seen.add(in); in },5),2,3).asStream;
        this.assertEquals(stream.next(10),[10,10]);
        this.assertEquals(stream.next(20),[20,20]);
        this.assertEquals(seen.asArray,[10,10,20,20,20]);
    }
}
