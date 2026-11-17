// SPDX-License-Identifier: GPL-3.0-or-later
TestPqmc : UnitTest {
    test_haltonPublishedVector {
        // SciPy Halton(scramble=False), indexed from zero.
        var actual = Pqmc(2, length: 5).asStream.all;
        [[0,0], [0.5,1/3], [0.25,2/3], [0.75,1/9], [0.125,4/9]].do { |v,i|
            this.assertArrayFloatEquals(actual[i], v, within: 1e-12);
        };
    }
    test_skipAndLeap {
        var all = Pqmc(3, length: 12).asStream.all;
        this.assertEquals(Pqmc(3, length: 4, skip: 2, leap: 3).asStream.all, [all[2],all[5],all[8],all[11]]);
    }
    test_rangeDimensionsAndPrimeGeneration {
        [\halton, \additive].do { |engine|
            var values = Pqmc(32, engine, 40).asStream.all;
            this.assert(values.every { |p| (p.size == 32) and: { p.every { |x| x.isKindOf(Float) and: { x >= 0 and: { x < 1 } } } } });
        };
        this.assertFloatEquals(Pqmc(32, length: 1, skip: 1).asStream.next.last, 1/131, within: 1e-12);
    }
    test_additiveDefinition {
        var points = Pqmc(2, \additive, 3).asStream.all;
        this.assertArrayFloatEquals(points[0], [0,0]);
        this.assertArrayFloatEquals(points[1], [2.sqrt % 1,3.sqrt % 1]);
        this.assertArrayFloatEquals(points[2], [(2 * (2.sqrt % 1)) % 1,(2 * (3.sqrt % 1)) % 1]);
    }
    test_scrambleReproducibility {
        var p = Pseed(Pseq([123]), Pqmc(3, length: 8, scramble: true));
        this.assertEquals(p.asStream.all, p.asStream.all);
        this.assert(p.asStream.next != Pqmc(3, length: 1).asStream.next);
    }
    test_zeroInvalAndStoreArgs {
        var p = Pqmc(length: 1), stream = Routine { |in| p.embedInStream(in).yield };
        this.assertEquals(Pqmc(length: 0).asStream.next, nil);
        stream.next;
        this.assertEquals(stream.next(9), 9);
        this.assertEquals(p.storeArgs, [1,\halton,1,false,0,1]);
    }
    test_onceParametersAndControlledStreams {
        var p = Pqmc(Pseq([2]), Pseq([\additive]), Pseq([3]), false, { 1 }, { 2 });
        this.assertEquals(p.asStream.all, Pqmc(2, \additive, 3, skip: 1, leap: 2).asStream.all);
        this.assertEquals(p.asStream.all, p.asStream.all);
        this.assertException({ Pqmc(4097).asStream.next }, Error);
        this.assertException({ Pqmc(skip: 2147483647).asStream.next }, Error);
    }
    test_invalid {
        this.assertException({ Pqmc(0).asStream.next }, Error);
        this.assertException({ Pqmc(engine: \sobol).asStream.next }, Error);
        this.assertException({ Pqmc(skip: -1).asStream.next }, Error);
        this.assertException({ Pqmc(leap: 0).asStream.next }, Error);
        this.assertException({ Pqmc(length: -1).asStream.next }, Error);
    }
}
