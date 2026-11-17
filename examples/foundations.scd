// SPDX-License-Identifier: GPL-3.0-or-later
// Evaluate blocks separately. Musical blocks use the Guide example instruments.


// Pscan

(
Pscan(Pseq([1, 2, 3]), 0, _ + _).asStream.all; // [1, 3, 6]
)

(
(
Pbind(\instrument, \fmPiano, \degree, Pscan(Pwhite(-2, 2, 32), 0, { |s, x| (s + x).fold(-7, 7) }), \dur, 0.125).play;
)
)

(
Pscan(Pseries(1, 1, 16), { (n: 0, seen: Set[0]) }, { |s, x|
    var n = s[\n] - x;
    if((n < 0) or: { s[\seen].includes(n) }) { n = s[\n] + x };
    (n: n, seen: s[\seen].copy.add(n))
}).collect { |s| s[\n] }.asStream.all;
)

(
Pscan(Pseq([2, 4, 9, 1]), (sum: 0, n: 0), { |s, x|
    (sum: s[\sum] + x, n: s[\n] + 1)
}).collect { |s| s[\sum] / s[\n] }.asStream.all;
)

(
Pscan(Pseq([0.1, 0.7, 0.9, 0.2]), (mean: 0.5), { |s, x|
    (above: x > s[\mean], mean: s[\mean] * 0.8 + (x * 0.2))
}).asStream.all;
)

(
Pscan(Pseq([0, 1, 2, 1, 0]), 0, { |s, x| s + (x * 0.1) }).asStream.all;
)

(
Pscan(Pseq([1, 0, 0, 1, 0]), 0, { |s, x| s * 0.8 + (x * 0.2) }).asStream.all;
)

(
Pscan(Pseq(3.5 ! 16), 0.2, { |s, r| r * s * (1 - s) }).asStream.all;
)

(
Pseed(Pseq([42]), Pscan(Pseq([0], 16), [1, 1], { |s|
    var choice = [0, 1].wchoose(s.normalizeSum), next = s.copy;
    next[choice] = next[choice] + 1;
    next
})).asStream.all;
)


// Pwindow

(
Pwindow(Pseries(0, 1, 6), 3).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano, \degree, Pwindow(Pseries(0, 1, 16), 3, 2).collect(_.mean), \dur, 0.125).play;
)
)

(
Pwindow(Pseries(1, 1, 8), 3).collect(_.mean).asStream.all;
)

(
Pwindow(Pseq([1, 9, 3, 2, 8]), 3).collect { |w| w.sort[1] }.asStream.all;
)

(
Pwindow(Pseries(1, 1, 8), 3).collect { |w| (w - w.mean).squared.mean }.asStream.all;
)

(
Pwindow(Pseq([\a, \a, \b, \a, \c, \c]), 3).collect { |w|
    w.as(Set).asArray.collect { |x|
        var p = w.count { |v| v == x } / w.size;
        p * p.log2.neg
    }.sum
}.asStream.all;
)

(
Pwindow(Pseq([\a, \b, \a, \c, \b]), 2).asStream.all;
)

(
Pwindow(Pseq([0, 2, 5, 4, 7]), 2).collect { |w| w[1] - w[0] }.asStream.all;
)

(
Pwindow(Pseq([1, 0, 0, 1, 0, 0]), 3).collect { |w| (w * [0.25, 0.5, 0.25]).sum }.asStream.all;
)

(
Pwindow(Pseq([0, 2, 4, 0, 2, 4]), 3).collect { |w| w == [0, 2, 4] }.asStream.all;
)

(
Pwindow(Pseq([0, 1, 0, 2, 1]), 3).collect { |w| (w[1] > w[0]) and: { w[1] > w[2] } }.asStream.all;
)

(
Pwindow(Pseq([-1, -0.5, 1, 0.5, -1]), 2).collect { |w| (w[0] * w[1]) < 0 }.asStream.all;
)

(
Pwindow(Pseq([0, 1, 2, 1, 0, 2]), 3).collect { |w| ((w[1] - w[0]) * (w[2] - w[1])) < 0 }.asStream.all;
)

(
Pwindow(Pseq([1, 2, 4, 4, 2]), 3).collect { |w| (w.last - w.minItem) / (w.maxItem - w.minItem).max(0.001) }.asStream.all;
)

(
Pwindow(Pseq([\a, \b, \a, \c, \b, \a]), 3).collect { |w|
    (context: w.copyRange(0, 1), next: w[2])
}.asStream.all;
)


// Ptransduce

(
Ptransduce(Pseq([1, 2, 3]), 0, { |s, x| (state: s + x, emit: [s + x]) }).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano, \degree, Ptransduce(Pseq([0, 2, 4, 5]), 0, { |s, x| (state: x, emit: [x, x + 1, x]) }), \dur, 0.125).play;
)
)

(
Ptransduce(Pseq([0, 1, 0, 1, 1, 0, 0]), (last: -1, n: 0), { |s, x|
    var n = if(x == s[\last]) { s[\n] + 1 } { 1 };
    (state: (last: x, n: n), emit: if(n == 2) { [x] } { [] })
}).asStream.all;
)

(
Ptransduce(Pseq([0.2, 0.6, 0.9, 0.5, 0.1]), 0, { |s, x|
    var next = if(x > 0.8) { 1 } { if(x < 0.3) { 0 } { s } };
    (state: next, emit: [next])
}).asStream.all;
)

(
Ptransduce(Pseq([\a, \b, \space, \c, \space]), [], { |s, x|
    if(x == \space) { (state: [], emit: [s]) } { (state: s.add(x), emit: []) }
}).asStream.all;
)

(
Ptransduce(Pseq([0, 2, 4]), 0, { |s, x| (state: x, emit: [x, x + 1, x]) }).asStream.all;
)

(
Ptransduce(Pseq([0.25, 1, 0.5]), 0, { |s, x| (state: s, emit: if(x >= 1) { [0.5, 0.5] } { [x] }) }).asStream.all;
)

(
Ptransduce(Pseq([(on: true, pitch: 60, time: 0), (on: false, pitch: 60, time: 1)]), { Dictionary.new }, { |s, x|
    var start;
    if(x[\on]) {
        s[x[\pitch]] = x[\time]; (state: s, emit: [])
    } {
        start = s.removeAt(x[\pitch]);
        (state: s, emit: if(start.notNil) { [(midinote: x[\pitch], dur: x[\time] - start)] } { [] })
    }
}).asStream.all;
)

(
Ptransduce(Pseq([0, 2, -99, 4, 5]), [], { |s, x|
    if(x == -99) { (state: [], emit: [s]) } { (state: s.add(x)) }
}, { |s| (state: s, emit: if(s.isEmpty) { [] } { [s] }) }).asStream.all;
)

(
Ptransduce(Pseq([0.21, 0.24, 0.31, 0.22]), 0, { |s, x|
    var corrected = x + s, q = corrected.round(0.25);
    (state: corrected - q, emit: [q])
}).asStream.all;
)

(
Ptransduce(Pseq([1, 1, 0, 0, 0, 1]), (last: nil, n: 0), { |s, x|
    var same = s[\last] == x;
    (state: (last: x, n: if(same) { s[\n] + 1 } { 1 }),
        emit: if(same or: { s[\n] == 0 }) { [] } { [[s[\last], s[\n]]] })
}, { |s| (state: s, emit: [[s[\last], s[\n]]]) }).asStream.all;
)

(
Ptransduce(Pseq([[1, 2], [0, 3], [1, 1]]), 0, { |s, x| (state: s, emit: x[0].dup(x[1])) }).asStream.all;
)

(
Ptransduce(Pseq([\open, 1, 2, \close, 3]), false, { |s, x|
    case
    { x == \open } { (state: true) }
    { x == \close } { (state: false) }
    { true } { (state: s, emit: if(s) { [x] } { [] }) }
}).asStream.all;
)


// Pmorphism

(
Pmorphism([\a], (a: [\a, \b], b: [\a]), 4, \generations, true).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano, \degree, Pmorphism([0], Dictionary[0 -> [0, 2], 2 -> [3, 0]], 5), \dur, 0.125).play;
)
)

(
Pmorphism([\a], (a: [\a, \b], b: [\a]), 5, \generations, true).asStream.all;
)

(
Pmorphism([0], Dictionary[0 -> [0, 1, 0], 1 -> [1, 2]], 3).asStream.all;
)

(
Pmorphism([1], Dictionary[1 -> [1, 0.5, 0.5], 0.5 -> [0.25, 0.25]], 3).asStream.all;
)

(
Pmorphism([0, 2, 0], Dictionary[2 -> { |symbol, left, right|
    if(left == right) { [symbol, symbol + 1] } { symbol }
}], 2, \generations, true).asStream.all;
)

(
Pmorphism([\saw], (saw: [\saw, \mallet], mallet: [\fmPiano], fmPiano: [\farfisa]), 3, \generations, true).asStream.all;
)

(
Pmorphism([\soft], (soft: Pseq([\soft, \bright]), bright: [\soft]), 4).collect { |symbol|
    if(symbol == \soft) { (cutoff: 800, amp: 0.08) } { (cutoff: 4000, amp: 0.12) }
}.asStream.all;
)

// Added sound companions. Load the Guide instruments first.

(
// Sound companion: Pscan / Value stream
var values = {
Pscan(Pseq([1, 2, 3]), 0, _ + _).asStream.all; // [1, 3, 6]
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x.fold(-7,14) } { 0 }, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: Pscan / Recaman-type recurrence
var values = {
Pscan(Pseries(1, 1, 16), { (n: 0, seen: Set[0]) }, { |s, x|
    var n = s[\n] - x;
    if((n < 0) or: { s[\seen].includes(n) }) { n = s[\n] + x };
    (n: n, seen: s[\seen].copy.add(n))
}).collect { |s| s[\n] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x.fold(-7,14) } { 0 }, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: Pscan / Running average
var values = {
Pscan(Pseq([2, 4, 9, 1]), (sum: 0, n: 0), { |s, x|
    (sum: s[\sum] + x, n: s[\n] + 1)
}).collect { |s| s[\sum] / s[\n] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x.fold(-7,14) } { 0 }, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: Pscan / Adaptive threshold
var values = {
Pscan(Pseq([0.1, 0.7, 0.9, 0.2]), (mean: 0.5), { |s, x|
    (above: x > s[\mean], mean: s[\mean] * 0.8 + (x * 0.2))
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, cutoff: x[\mean].linexp(0,1,300,5000), amp: if(x[\above]) { 0.12 } { 0.035 }, dur: 0.25)
}.play;
)

(
// Sound companion: Pscan / Numerical integration
var values = {
Pscan(Pseq([0, 1, 2, 1, 0]), 0, { |s, x| s + (x * 0.1) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, cutoff: x.clip(0,1).linexp(0,1,250,6000), dur: 0.25, amp: 0.07)
}.play;
)

(
// Sound companion: Pscan / Leaky integration
var values = {
Pscan(Pseq([1, 0, 0, 1, 0]), 0, { |s, x| s * 0.8 + (x * 0.2) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, cutoff: x.clip(0,1).linexp(0,1,250,6000), dur: 0.25, amp: 0.07)
}.play;
)

(
// Sound companion: Pscan / Population recurrence
var values = {
Pscan(Pseq(3.5 ! 16), 0.2, { |s, r| r * s * (1 - s) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, cutoff: x.clip(0,1).linexp(0,1,250,6000), dur: 0.25, amp: 0.07)
}.play;
)

(
// Sound companion: Pscan / Reinforcement
var values = {
Pseed(Pseq([42]), Pscan(Pseq([0], 16), [1, 1], { |s|
    var choice = [0, 1].wchoose(s.normalizeSum), next = s.copy;
    next[choice] = next[choice] + 1;
    next
})).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x[0]/x.sum*14).round, pan: (x[1]-x[0])/x.sum, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: Pwindow / Value stream
var values = {
Pwindow(Pseries(0, 1, 6), 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Moving mean
var values = {
Pwindow(Pseries(1, 1, 8), 3).collect(_.mean).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Moving median
var values = {
Pwindow(Pseq([1, 9, 3, 2, 8]), 3).collect { |w| w.sort[1] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Moving variance
var values = {
Pwindow(Pseries(1, 1, 8), 3).collect { |w| (w - w.mean).squared.mean }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Moving symbolic entropy
var values = {
Pwindow(Pseq([\a, \a, \b, \a, \c, \c]), 3).collect { |w|
    w.as(Set).asArray.collect { |x|
        var p = w.count { |v| v == x } / w.size;
        p * p.log2.neg
    }.sum
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / N-grams
var values = {
Pwindow(Pseq([\a, \b, \a, \c, \b]), 2).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x.collect { |s| tones[s] ? 0 }, dur: 0.25, amp: 0.05)
}.play;
)

(
// Sound companion: Pwindow / Melodic intervals
var values = {
Pwindow(Pseq([0, 2, 5, 4, 7]), 2).collect { |w| w[1] - w[0] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Weighted convolution
var values = {
Pwindow(Pseq([1, 0, 0, 1, 0, 0]), 3).collect { |w| (w * [0.25, 0.5, 0.25]).sum }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Pwindow / Motif detection
var values = {
Pwindow(Pseq([0, 2, 4, 0, 2, 4]), 3).collect { |w| w == [0, 2, 4] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 7, type: if(x) { \note } { \rest }, dur: 0.2, amp: 0.1)
}.play;
)

(
// Sound companion: Pwindow / Peak detection
var values = {
Pwindow(Pseq([0, 1, 0, 2, 1]), 3).collect { |w| (w[1] > w[0]) and: { w[1] > w[2] } }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 7, type: if(x) { \note } { \rest }, dur: 0.2, amp: 0.1)
}.play;
)

(
// Sound companion: Pwindow / Zero crossings
var values = {
Pwindow(Pseq([-1, -0.5, 1, 0.5, -1]), 2).collect { |w| (w[0] * w[1]) < 0 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 7, type: if(x) { \note } { \rest }, dur: 0.2, amp: 0.1)
}.play;
)

(
// Sound companion: Pwindow / Direction changes
var values = {
Pwindow(Pseq([0, 1, 2, 1, 0, 2]), 3).collect { |w| ((w[1] - w[0]) * (w[2] - w[1])) < 0 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 7, type: if(x) { \note } { \rest }, dur: 0.2, amp: 0.1)
}.play;
)

(
// Sound companion: Pwindow / Local normalization
var values = {
Pwindow(Pseq([1, 2, 4, 4, 2]), 3).collect { |w| (w.last - w.minItem) / (w.maxItem - w.minItem).max(0.001) }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, cutoff: x.linexp(0,1,300,6000), dur: 0.2, amp: 0.07)
}.play;
)

(
// Sound companion: Pwindow / Training contexts
var values = {
Pwindow(Pseq([\a, \b, \a, \c, \b, \a]), 3).collect { |w|
    (context: w.copyRange(0, 1), next: w[2])
}.asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x[\context] ++ [x[\next]]).collect { |s| tones[s] ? 0 }, dur: 0.3, amp: 0.045)
}.play;
)

(
// Sound companion: Ptransduce / Value stream
var values = {
Ptransduce(Pseq([1, 2, 3]), 0, { |s, x| (state: s + x, emit: [s + x]) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Ptransduce / Debouncing
var values = {
Ptransduce(Pseq([0, 1, 0, 1, 1, 0, 0]), (last: -1, n: 0), { |s, x|
    var n = if(x == s[\last]) { s[\n] + 1 } { 1 };
    (state: (last: x, n: n), emit: if(n == 2) { [x] } { [] })
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Ptransduce / Hysteresis
var values = {
Ptransduce(Pseq([0.2, 0.6, 0.9, 0.5, 0.1]), 0, { |s, x|
    var next = if(x > 0.8) { 1 } { if(x < 0.3) { 0 } { s } };
    (state: next, emit: [next])
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Ptransduce / Symbolic token parsing
var values = {
Ptransduce(Pseq([\a, \b, \space, \c, \space]), [], { |s, x|
    if(x == \space) { (state: [], emit: [s]) } { (state: s.add(x), emit: []) }
}).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x.collect { |v| if(v.isNumber) { v } { tones[v] ? 0 } }, dur: 0.35, amp: 0.05)
}.play;
)

(
// Sound companion: Ptransduce / Ornament insertion
var values = {
Ptransduce(Pseq([0, 2, 4]), 0, { |s, x| (state: x, emit: [x, x + 1, x]) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Ptransduce / Conditional rhythmic rewriting
var values = {
Ptransduce(Pseq([0.25, 1, 0.5]), 0, { |s, x| (state: s, emit: if(x >= 1) { [0.5, 0.5] } { [x] }) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x.max(0.04), amp: 0.1)
}.play;
)

(
// Sound companion: Ptransduce / Pairing note messages
var values = {
Ptransduce(Pseq([(on: true, pitch: 60, time: 0), (on: false, pitch: 60, time: 1)]), { Dictionary.new }, { |s, x|
    var start;
    if(x[\on]) {
        s[x[\pitch]] = x[\time]; (state: s, emit: [])
    } {
        start = s.removeAt(x[\pitch]);
        (state: s, emit: if(start.notNil) { [(midinote: x[\pitch], dur: x[\time] - start)] } { [] })
    }
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, midinote: x[\midinote], dur: x[\dur], amp: 0.1)
}.play;
)

(
// Sound companion: Ptransduce / Phrase segmentation
var values = {
Ptransduce(Pseq([0, 2, -99, 4, 5]), [], { |s, x|
    if(x == -99) { (state: [], emit: [s]) } { (state: s.add(x)) }
}, { |s| (state: s, emit: if(s.isEmpty) { [] } { [s] }) }).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x.collect { |v| if(v.isNumber) { v } { tones[v] ? 0 } }, dur: 0.35, amp: 0.05)
}.play;
)

(
// Sound companion: Ptransduce / Stateful quantization
var values = {
Ptransduce(Pseq([0.21, 0.24, 0.31, 0.22]), 0, { |s, x|
    var corrected = x + s, q = corrected.round(0.25);
    (state: corrected - q, emit: [q])
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x.max(0.04), amp: 0.1)
}.play;
)

(
// Sound companion: Ptransduce / Run-length encoding
var values = {
Ptransduce(Pseq([1, 1, 0, 0, 0, 1]), (last: nil, n: 0), { |s, x|
    var same = s[\last] == x;
    (state: (last: x, n: if(same) { s[\n] + 1 } { 1 }),
        emit: if(same or: { s[\n] == 0 }) { [] } { [[s[\last], s[\n]]] })
}, { |s| (state: s, emit: [[s[\last], s[\n]]]) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x[0]*7, dur: x[1]*0.15, amp: 0.1)
}.play;
)

(
// Sound companion: Ptransduce / Run-length decoding
var values = {
Ptransduce(Pseq([[1, 2], [0, 3], [1, 1]]), 0, { |s, x| (state: s, emit: x[0].dup(x[1])) }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Ptransduce / Protocol state machine
var values = {
Ptransduce(Pseq([\open, 1, 2, \close, 3]), false, { |s, x|
    case
    { x == \open } { (state: true) }
    { x == \close } { (state: false) }
    { true } { (state: s, emit: if(s) { [x] } { [] }) }
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)

(
// Sound companion: Pmorphism / Value stream
var values = {
Pmorphism([\a], (a: [\a, \b], b: [\a]), 4, \generations, true).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x } { tones[x] ? 0 }, dur: 0.15, amp: 0.08)
}.play;
)

(
// Sound companion: Pmorphism / Formal growth
var values = {
Pmorphism([\a], (a: [\a, \b], b: [\a]), 5, \generations, true).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x } { tones[x] ? 0 }, dur: 0.15, amp: 0.08)
}.play;
)

(
// Sound companion: Pmorphism / Ornament proliferation
var values = {
Pmorphism([0], Dictionary[0 -> [0, 1, 0], 1 -> [1, 2]], 3).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x } { tones[x] ? 0 }, dur: 0.15, amp: 0.08)
}.play;
)

(
// Sound companion: Pmorphism / Self-similar rhythm
var values = {
Pmorphism([1], Dictionary[1 -> [1, 0.5, 0.5], 0.5 -> [0.25, 0.25]], 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x*0.25, amp: 0.1)
}.play;
)

(
// Sound companion: Pmorphism / Context-sensitive phrase mutation
var values = {
Pmorphism([0, 2, 0], Dictionary[2 -> { |symbol, left, right|
    if(left == right) { [symbol, symbol + 1] } { symbol }
}], 2, \generations, true).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x } { tones[x] ? 0 }, dur: 0.15, amp: 0.08)
}.play;
)

(
// Sound companion: Pmorphism / Evolving orchestration
var values = {
Pmorphism([\saw], (saw: [\saw, \mallet], mallet: [\fmPiano], fmPiano: [\farfisa]), 3, \generations, true).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: x, degree: 0, dur: 0.2, amp: 0.07)
}.play;
)

(
// Sound companion: Pmorphism / Symbolic synthesis controls and Pattern replacement
var values = {
Pmorphism([\soft], (soft: Pseq([\soft, \bright]), bright: [\soft]), 4).collect { |symbol|
    if(symbol == \soft) { (cutoff: 800, amp: 0.08) } { (cutoff: 4000, amp: 0.12) }
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((instrument: \saw, degree: 0, dur: 0.2))
}.play;
)

(
// Sound companion: Patternarium-Foundations / Value stream
var values = {
Pscan(Pwindow(Pseries(1, 1, 6), 2).collect(_.sum), 0, _ + _).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Patternarium-Protocols / Transducer step
var values = {
Ptransduce(Pseq([1, 2, 3]), 0, { |s, x|
    (state: s + x, emit: if(x.odd) { [x, x + 12] } { [] })
}).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*3, dur: 0.16, amp: 0.09)
}.play;
)
