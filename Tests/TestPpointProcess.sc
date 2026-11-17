// SPDX-License-Identifier: GPL-3.0-or-later
TestPpointProcess : UnitTest {
    test_abstractConstructor { this.assertException({ PpointProcess.new }, Error) }
    test_sharedSubclassContract {
        [Prenewal(Pseq([1])), Phawkes(length: 1)].do { |pattern|
            this.assert(pattern.isKindOf(PpointProcess));
        };
    }
}
