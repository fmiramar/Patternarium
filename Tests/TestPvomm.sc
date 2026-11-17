// SPDX-License-Identifier: GPL-3.0-or-later
TestPvomm : UnitTest {
    test_orderZeroAndPpmC {
        var m = PTRVommModel([\a,\b,\a,\c],1), zero = m.distribution([],true), p = m.distribution([\a],true), q = m.distribution([\a],false);
        this.assertFloatEquals(zero[\a],0.5);
        this.assertFloatEquals(zero[\b],0.25);
        this.assertFloatEquals(p[\a],0.5);
        this.assertFloatEquals(p[\b],0.25);
        this.assertFloatEquals(p[\c],0.25);
        this.assertFloatEquals(q[\a],0.25);
        this.assertFloatEquals(q[\b],0.375);
        this.assertFloatEquals(q.values.sum,1);
    }
    test_contextFallbackAndBoundaries {
        var m = PTRVommModel([[\a,\b],[\c,\d]],2);
        this.assertEquals(m.countsFor([\b]),nil);
        this.assertEquals(m.countsFor([\b,\c]),nil);
        this.assertEquals(m.distribution([\unknown,\a],true),m.distribution([\a],true));
        this.assertFloatEquals(m.distribution([\unknown],true)[\a],0.25);
    }
    test_deterministicAndSeeded {
        this.assertEquals(Pvomm([\a,\a,\a],length: 6).asStream.all,\a.dup(6));
        [false,true].do { |learn|
            var p = Pseed(Pseq([42]),Pvomm([0,1,0,2,0,1],length: 24,learning: learn));
            this.assertEquals(p.asStream.all,p.asStream.all);
        };
    }
    test_learningAndIsolation {
        var m = PTRVommModel([\a,\b],1), other = PTRVommModel([\a,\b],1);
        m.observe([\a],\b);
        this.assertEquals(m.countsFor([\a])[\b],2);
        this.assertEquals(other.countsFor([\a])[\b],1);
    }
    test_arbitrarySymbolsAndReturnInval {
        var object = Object.new, p = Pvomm([object],length: 1), s = Routine { |in| p.embedInStream(in).yield };
        this.assert(s.next === object);
        this.assertEquals(s.next(9),9);
        this.assertEquals(Pvomm([object],length: 0).asStream.next,nil);
        this.assertEquals(p.storeArgs,[[object],8,1,nil,false,true]);
    }
    test_publicLearningChangesWeightsWithoutLeaking {
        var corpus = [0,1], frozen = Pseed(Pseq([42]),Pvomm(corpus,0,24)), learned = Pseed(Pseq([42]),Pvomm(corpus,0,24,learning: true));
        var baseline = frozen.asStream.all;
        this.assert(learned.asStream.all != baseline);
        this.assertEquals(frozen.asStream.all,baseline);
        this.assertEquals(corpus,[0,1]);
    }
    test_probabilityNormalization {
        var m = PTRVommModel([[0,1,0,2],[2,1,2,0]],3);
        [true,false].do { |exclude|
            [[],[0],[2,1],[9,9,9],[2,0,1]].do { |context|
                var probabilities = m.distribution(context,exclude);
                this.assertFloatEquals(probabilities.values.sum,1,within: 1e-12);
                this.assert(probabilities.values.every { |x| x >= 0 and: { x <= 1 } });
            };
        };
    }
    test_invalid {
        this.assertException({ Pvomm([]).asStream.next },Error);
        this.assertException({ Pvomm([nil]).asStream.next },Error);
        this.assertException({ Pvomm([1],maxOrder: -1).asStream.next },Error);
    }
}
