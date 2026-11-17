// SPDX-License-Identifier: GPL-3.0-or-later
TestPdeBruijn : UnitTest {
    test_binaryVector { this.assertEquals(PdeBruijn([0,1], 3).asStream.all, [0,0,0,1,0,1,1,1]) }
    test_cyclicCoverage {
        [[2,1], [2,4], [3,2], [3,3]].do { |spec|
            var k = spec[0], n = spec[1], cycle = PdeBruijn((0..(k-1)), n).asStream.all;
            var words = Array.fill(cycle.size, { |i| Array.fill(n, { |j| cycle.wrapAt(i+j) }) });
            this.assertEquals(cycle.size, k.pow(n).asInteger);
            this.assertEquals(words.as(Set).size, cycle.size);
        };
    }
    test_rotationAndRepetition {
        this.assertEquals(PdeBruijn([0,1], 2, 2, 1).asStream.all, [0,1,1,0,0,1,1,0]);
        this.assertEquals(PdeBruijn([0,1], 2, rotation: -1).asStream.all, [1,0,0,1]);
        this.assertEquals(PdeBruijn([1], 3, 0).asStream.next, nil);
    }
    test_objectsAndInval {
        var obj = Object.new, p = PdeBruijn([obj], 100), stream = Routine { |in| p.embedInStream(in).yield };
        this.assert(stream.next(1) === obj);
        this.assertEquals(stream.next(9), 9);
    }
    test_parametersAndIndependence {
        var p = PdeBruijn([0,1], Pseq([2])), a = p.asStream, b = p.asStream;
        a.next;
        this.assertEquals(b.nextN(4), [0,0,1,1]);
        this.assertEquals(p.storeArgs, [p.alphabet, p.order, 1, 0]);
    }
    test_invalid {
        [[], [1,1], [nil]].do { |a| this.assertException({ PdeBruijn(a, 2).asStream.next }, Error) };
        [0, -1, 1.5].do { |n| this.assertException({ PdeBruijn([0,1], n).asStream.next }, Error) };
        this.assertException({ PdeBruijn([0,1], 30).asStream.next }, Error);
    }
}
