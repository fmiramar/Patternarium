// SPDX-License-Identifier: GPL-3.0-or-later
TestPgrayCode : UnitTest {
    test_binaryVector { this.assertEquals(PgrayCode([2,2]).asStream.all, [[0,0],[0,1],[1,1],[1,0]]) }
    test_mixedVector { this.assertEquals(PgrayCode([2,3]).asStream.all, [[0,0],[0,1],[0,2],[1,2],[1,1],[1,0]]) }
    test_uniquenessAndAdjacency {
        [[2], [2,3], [3,3,2], [4,2,3]].do { |radices|
            var states = PgrayCode(radices).asStream.all;
            this.assertEquals(states.size, radices.product);
            this.assertEquals(states.as(Set).size, states.size);
            states.doAdjacentPairs { |a,b| this.assertEquals((a-b).abs.sum, 1) };
        };
    }
    test_repetitionAndFreshArrays {
        var a = PgrayCode([2], 2).asStream.all;
        this.assertEquals(a, [[0],[1],[0],[1]]);
        this.assert(a[0] !== a[2]);
        this.assertEquals(PgrayCode([2], 0).asStream.next, nil);
    }
    test_streamsAndInval {
        var p = PgrayCode([2]), a = p.asStream, b = p.asStream;
        var stream = Routine { |in| p.embedInStream(in).yield };
        a.nextN(2);
        this.assertEquals(b.next, [0]);
        stream.next; stream.next;
        this.assertEquals(stream.next(9), 9);
        this.assertEquals(p.storeArgs, [[2],1]);
    }
    test_invalid {
        [[], [1], [0,2], [2.5], [nil]].do { |r| this.assertException({ PgrayCode(r).asStream.next }, Error) };
    }
}
