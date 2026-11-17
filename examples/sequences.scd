// SPDX-License-Identifier: GPL-3.0-or-later
// Evaluate blocks separately; musical examples use Guide instruments.

// PdeBruijn

(
PdeBruijn([0, 1], 3).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, PdeBruijn([0, 2, 4, 7], 2), \dur, 0.125).play;
)
)

(
PdeBruijn([\legato, \staccato, \accent], 2).asStream.all;
)

(
PdeBruijn([0.125, 0.25, 0.5], 3).asStream.all;
)

(
PdeBruijn([[800, 0.1], [2000, 0.3], [4000, 0.6]], 2).collect { |p|
    (cutoff: p[0], rq: p[1])
}.asStream.all;
)

(
PdeBruijn((0..4), 2).asStream.all.clump(5);
)

(
PdeBruijn([\quiet, \medium, \loud], 3).asStream.all;
)

(
Pwindow(PdeBruijn([0, 1, 2, 3], 2, 2), 2).asStream.nextN(16);
)

// PgrayCode

(
PgrayCode([2, 3]).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, PgrayCode([3, 4]).collect { |p| p[0] + (p[1] * 2) }, \dur, 0.125).play;
)
)

(
PgrayCode([3, 2]).collect { |p|
    (cutoff: [500, 1500, 4000][p[0]], rq: [0.1, 0.5][p[1]])
}.asStream.all;
)

(
PgrayCode([2, 3]).collect { |p|
    (instrument: [\saw, \farfisa][p[0]], octave: [3, 4, 5][p[1]])
}.asStream.all;
)

(
PgrayCode([3, 2, 2]).collect { |p| [0, 2, 4] + p }.asStream.all;
)

(
Pwindow(PgrayCode([2, 3, 2]), 2).collect { |w| (w[1] - w[0]).abs.indexOf(1) }.asStream.all;
)

(
PgrayCode([2, 2, 2]).collect { |p|
    (bright: p[0], vibrato: p[1], tremolo: p[2])
}.asStream.all;
)

(
PgrayCode([2, 2, 2, 2]).asStream.all; // one channel-enable bit changes per step
)

// Pqmc

(
Pqmc(2, length: 8).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, Pqmc(2, length: 32).collect { |p| p[0] * 14 + (p[1] * 0.25) }, \dur, 0.125).play;
)
)

(
Pqmc(3, length: 8, skip: 1).collect { |p|
    (cutoff: p[0].linexp(0, 1, 200, 8000), rq: p[1].linlin(0, 1, 0.1, 0.8), amp: p[2] * 0.1)
}.asStream.all;
)

(
Pqmc(3, length: 8).collect { |p| p * 2 - 1 }.asStream.all;
)

(
Pqmc(2, length: 8).collect { |p| [p[0], (1-p[0])*p[1], (1-p[0])*(1-p[1])] }.asStream.all;
)

(
Pqmc(2, length: 12, skip: 3, leap: 2).collect { |p|
    (frequency: p[0].linexp(0, 1, 100, 5000), duration: p[1].linlin(0, 1, 0.05, 1))
}.asStream.all;
)

(
(
var q = Pqmc(1, length: 16).asStream.all.flat;
var r = Pseed(Pseq([42]), Pwhite(0.0, 1.0, 16)).asStream.all;
[q, r].collect { |values| (0..3).collect { |i| values.count { |x| (x * 4).floor == i } } }.postln;
)
)

(
Pqmc(1, \additive, 16, skip: 1).collect { |p| (p[0] * 14).floor }.asStream.all;
)

// ProtationWord

(
ProtationWord((5.sqrt - 1) / 2, length: 16).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, ProtationWord((5.sqrt - 1) / 2, length: 32).collect { |x| [0, 7][x] }, \dur, 0.125).play;
)
)

(
ProtationWord((5.sqrt - 1) / 2, length: 24).collect { |x| [Rest(0.125), 0.125][x] }.asStream.all;
)

(
ProtationWord(2.sqrt - 1, length: 16).collect { |x| [x, 1-x] }.asStream.all;
)

(
ProtationWord(2.sqrt - 1, length: 24).collect { |x| [0, 4][x] }.asStream.all;
)

(
ProtationWord(3/8, length: 24).asStream.all.clump(8);
)

(
ProtationWord(2.sqrt - 1, length: 16, cuts: [0.25, 0.7]).asStream.all;
)

(
ProtationWord((5.sqrt - 1) / 2, length: 24).collect { |x| [1, 2][x] }.asStream.all; // two tile lengths, a conceptual musical mapping
)

// PnumSeq

(
PnumSeq(\recaman, length: 16).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, PnumSeq(\norgard, length: 32).collect { |x| x.fold(-7, 7) }, \dur, 0.125).play;
)
)

(
PnumSeq(\recaman, length: 16).asStream.all;
)

(
PnumSeq(\vanEck, length: 16).asStream.all;
)

(
PnumSeq(\golomb, length: 16).asStream.all;
)

(
PnumSeq(\kolakoski, length: 16).asStream.all;
)

(
PnumSeq(\paperfolding, length: 16).asStream.all;
)

(
PnumSeq(\rudinShapiro, length: 16).asStream.all;
)

(
PnumSeq(\stern, length: 16).asStream.all;
)

(
PnumSeq(\calkinWilf, length: 8).asStream.all;
)

(
PnumSeq(\lookAndSay, length: 6).asStream.all;
)

(
PnumSeq(\norgard, length: 16).asStream.all;
)

(
PnumSeq(\recaman, length: 16).collect { |x| (x % 7) - 3 }.asStream.all;
PnumSeq(\vanEck, length: 16).collect { |x| (x % 5) * 2 }.asStream.all;
PnumSeq(\golomb, length: 16).collect { |x| 0.125 * x }.asStream.all;
PnumSeq(\kolakoski, length: 16).collect { |x| [0, 7][x-1] }.asStream.all;
PnumSeq(\paperfolding, length: 16).collect { |x| [Rest(0.125), 0.125][x] }.asStream.all;
PnumSeq(\rudinShapiro, length: 16).collect { |x| x * 0.75 }.asStream.all; // pan positions
PnumSeq(\stern, length: 16).collect { |x| (x + 1).reciprocal }.asStream.all;
PnumSeq(\calkinWilf, length: 8).collect { |pair| pair[0] / pair[1] }.asStream.all; // frequency ratios
PnumSeq(\lookAndSay, length: 6).collect { |digits| digits.sum / digits.size }.asStream.all;
PnumSeq(\norgard, length: 16).collect { |x| x.fold(-7, 7) }.asStream.all;
)

// Added sound companions. Load the Guide instruments first.

(
// Sound companion: PdeBruijn / Value stream
var values = {
PdeBruijn([0, 1], 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x.fold(-7,14) } { 0 }, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PdeBruijn / Articulation transitions
var values = {
PdeBruijn([\legato, \staccato, \accent], 2).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: 0, dur: 0.2, legato: if(x == \staccato) { 0.2 } { 0.9 }, amp: if(x == \accent) { 0.13 } { 0.06 })
}.play;
)

(
// Sound companion: PdeBruijn / Short rhythmic cells
var values = {
PdeBruijn([0.125, 0.25, 0.5], 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x, amp: 0.1)
}.play;
)

(
// Sound companion: PdeBruijn / Discrete synthesis combinations
var values = {
PdeBruijn([[800, 0.1], [2000, 0.3], [4000, 0.6]], 2).collect { |p|
    (cutoff: p[0], rq: p[1])
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((instrument: \saw, degree: 0, dur: 0.2, amp: 0.07))
}.play;
)

(
// Sound companion: PdeBruijn / Balanced local musical words
var values = {
PdeBruijn((0..4), 2).asStream.all.clump(5);
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isNumber) { x.fold(-7,14) } { 0 }, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PdeBruijn / Perceptual-test contexts
var values = {
PdeBruijn([\quiet, \medium, \loud], 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, amp: (quiet: 0.025, medium: 0.065, loud: 0.14)[x], dur: 0.25)
}.play;
)

(
// Sound companion: PdeBruijn / Speaker transition test
var values = {
Pwindow(PdeBruijn([0, 1, 2, 3], 2, 2), 2).asStream.nextN(16);
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x[1]*2, pan: x[1].linlin(0,3,-1,1), dur: 0.2, amp: 0.09)
}.play;
)

(
// Sound companion: PgrayCode / Value stream
var values = {
PgrayCode([2, 3]).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x, cutoff: 500*(x[0]+1), dur: 0.25, amp: 0.035)
}.play;
)

(
// Sound companion: PgrayCode / Discrete synthesis parameter space
var values = {
PgrayCode([3, 2]).collect { |p|
    (cutoff: [500, 1500, 4000][p[0]], rq: [0.1, 0.5][p[1]])
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((instrument: \saw, degree: 0, dur: 0.3, amp: 0.07))
}.play;
)

(
// Sound companion: PgrayCode / One orchestration property at a time
var values = {
PgrayCode([2, 3]).collect { |p|
    (instrument: [\saw, \farfisa][p[0]], octave: [3, 4, 5][p[1]])
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((degree: 0, dur: 0.3, amp: 0.07))
}.play;
)

(
// Sound companion: PgrayCode / Controlled mutation
var values = {
PgrayCode([3, 2, 2]).collect { |p| [0, 2, 4] + p }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x, cutoff: 500*(x[0]+1), dur: 0.25, amp: 0.035)
}.play;
)

(
// Sound companion: PgrayCode / Inspecting which coordinate changed
var values = {
Pwindow(PgrayCode([2, 3, 2]), 2).collect { |w| (w[1] - w[0]).abs.indexOf(1) }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, pan: x-1, dur: 0.25, amp: 0.1)
}.play;
)

(
// Sound companion: PgrayCode / Reducing simultaneous control switches
var values = {
PgrayCode([2, 2, 2]).collect { |p|
    (bright: p[0], vibrato: p[1], tremolo: p[2])
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x[\vibrato]*7, cutoff: [600,4000][x[\bright]], amp: [0.04,0.1][x[\tremolo]], dur: 0.3)
}.play;
)

(
// Sound companion: PgrayCode / Channel configuration tests
var values = {
PgrayCode([2, 2, 2, 2]).asStream.all; // one channel-enable bit changes per step
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: [0,2,4,7], amp: x*0.06, dur: 0.25)
}.play;
)

(
// Sound companion: Pqmc / Value stream
var values = {
Pqmc(2, length: 8).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x[0]*14 } { x }, pan: if(x.isArray) { x[1]*2-1 } { 0 }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pqmc / Multidimensional timbre exploration
var values = {
Pqmc(3, length: 8, skip: 1).collect { |p|
    (cutoff: p[0].linexp(0, 1, 200, 8000), rq: p[1].linlin(0, 1, 0.1, 0.8), amp: p[2] * 0.1)
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((instrument: \saw, degree: 0, dur: 0.3))
}.play;
)

(
// Sound companion: Pqmc / Spatial coordinates
var values = {
Pqmc(3, length: 8).collect { |p| p * 2 - 1 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: (x[1]+1)*7, pan: x[0], dur: 0.25, amp: 0.08)
}.play;
)

(
// Sound companion: Pqmc / Preset interpolation
var values = {
Pqmc(2, length: 8).collect { |p| [p[0], (1-p[0])*p[1], (1-p[0])*(1-p[1])] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x[0]*14, pan: x[1]-x[2], cutoff: 300+(x[0]*5000), dur: 0.25, amp: 0.07)
}.play;
)

(
// Sound companion: Pqmc / Experimental design
var values = {
Pqmc(2, length: 12, skip: 3, leap: 2).collect { |p|
    (frequency: p[0].linexp(0, 1, 100, 5000), duration: p[1].linlin(0, 1, 0.05, 1))
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, freq: x[\frequency], dur: x[\duration], amp: 0.07)
}.play;
)

(
// Sound companion: Pqmc / Coverage compared with Pwhite
var values = {

var q = Pqmc(1, length: 16).asStream.all.flat;
var r = Pseed(Pseq([42]), Pwhite(0.0, 1.0, 16)).asStream.all;
[q, r].collect { |values| (0..3).collect { |i| values.count { |x| (x * 4).floor == i } } }.postln;

}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x*2, dur: 0.25, amp: 0.08)
}.play;
)

(
// Sound companion: Pqmc / Irregular evenly spread degrees
var values = {
Pqmc(1, \additive, 16, skip: 1).collect { |p| (p[0] * 14).floor }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x[0]*14 } { x }, pan: if(x.isArray) { x[1]*2-1 } { 0 }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: ProtationWord / Value stream
var values = {
ProtationWord((5.sqrt - 1) / 2, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x*7 } { x*7 }, dur: 0.18, amp: 0.07)
}.play;
)

(
// Sound companion: ProtationWord / Balanced binary rhythm
var values = {
ProtationWord((5.sqrt - 1) / 2, length: 24).collect { |x| [Rest(0.125), 0.125][x] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x, amp: 0.1)
}.play;
)

(
// Sound companion: ProtationWord / Complementary streams
var values = {
ProtationWord(2.sqrt - 1, length: 16).collect { |x| [x, 1-x] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: [0,7], amp: x*0.09, dur: 0.2)
}.play;
)

(
// Sound companion: ProtationWord / Aperiodic degree selection
var values = {
ProtationWord(2.sqrt - 1, length: 24).collect { |x| [0, 4][x] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x*7 } { x*7 }, dur: 0.18, amp: 0.07)
}.play;
)

(
// Sound companion: ProtationWord / Rational periodic contrast
var values = {
ProtationWord(3/8, length: 24).asStream.all.clump(8);
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x*7 } { x*7 }, dur: 0.18, amp: 0.07)
}.play;
)

(
// Sound companion: ProtationWord / Multiple interval symbols
var values = {
ProtationWord(2.sqrt - 1, length: 16, cuts: [0.25, 0.7]).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x*7 } { x*7 }, dur: 0.18, amp: 0.07)
}.play;
)

(
// Sound companion: ProtationWord / Quasicrystal-like ordering
var values = {
ProtationWord((5.sqrt - 1) / 2, length: 24).collect { |x| [1, 2][x] }.asStream.all; // two tile lengths, a conceptual musical mapping
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x*0.15, amp: 0.1)
}.play;
)

(
// Sound companion: PnumSeq / Value stream
var values = {
PnumSeq(\recaman, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Recaman
var values = {
PnumSeq(\recaman, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Van Eck
var values = {
PnumSeq(\vanEck, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Golomb
var values = {
PnumSeq(\golomb, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x*0.125, amp: 0.1)
}.play;
)

(
// Sound companion: PnumSeq / Kolakoski
var values = {
PnumSeq(\kolakoski, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Paperfolding
var values = {
PnumSeq(\paperfolding, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 7, type: if(x == 1) { \note } { \rest }, dur: 0.15, amp: 0.09)
}.play;
)

(
// Sound companion: PnumSeq / Rudin-Shapiro
var values = {
PnumSeq(\rudinShapiro, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, pan: x.clip(-1,1), dur: 0.18, amp: 0.09)
}.play;
)

(
// Sound companion: PnumSeq / Stern diatomic
var values = {
PnumSeq(\stern, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Calkin-Wilf rationals
var values = {
PnumSeq(\calkinWilf, length: 8).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, freq: 220*x[0]/x[1], dur: 0.3, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Look-and-say
var values = {
PnumSeq(\lookAndSay, length: 6).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x.keep(8).collect { |d| [0,2,4,5,7,9,11].wrapAt(d) }, dur: 0.4, amp: 0.06/x.size.sqrt)
}.play;
)

(
// Sound companion: PnumSeq / Norgard infinity series
var values = {
PnumSeq(\norgard, length: 16).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\recaman, length: 16).collect { |x| (x % 7) - 3 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\vanEck, length: 16).collect { |x| (x % 5) * 2 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\golomb, length: 16).collect { |x| 0.125 * x }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x, amp: 0.1)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\kolakoski, length: 16).collect { |x| [0, 7][x-1] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\paperfolding, length: 16).collect { |x| [Rest(0.125), 0.125][x] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x, amp: 0.1)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\rudinShapiro, length: 16).collect { |x| x * 0.75 }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, pan: x.clip(-1,1), dur: 0.18, amp: 0.09)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\stern, length: 16).collect { |x| (x + 1).reciprocal }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\calkinWilf, length: 8).collect { |pair| pair[0] / pair[1] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, freq: 220*x, dur: 0.3, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\lookAndSay, length: 6).collect { |digits| digits.sum / digits.size }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: PnumSeq / Mapping to compositional parameters
var values = {
PnumSeq(\norgard, length: 16).collect { |x| x.fold(-7, 7) }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: (x % 14)-3, dur: 0.18, amp: 0.08)
}.play;
)

(
// Sound companion: Patternarium-Sequences / Value stream
var values = {
Pwindow(PdeBruijn([0, 1], 3, 2), 3).asStream.nextN(8);
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isArray) { x } { x*2 }, dur: 0.22, amp: 0.06)
}.play;
)

(
// Sound companion: Patternarium-Sequences / Value stream
var values = {
Pwindow(PgrayCode([2, 3]), 2).collect { |w| w[1] - w[0] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x, cutoff: 500*(x[0]+1), dur: 0.25, amp: 0.035)
}.play;
)

(
// Sound companion: Patternarium-Sequences / Value stream
var values = {
Pqmc(2, length: 8).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x.isArray) { x[0]*14 } { x }, pan: if(x.isArray) { x[1]*2-1 } { 0 }, dur: 0.2, amp: 0.08)
}.play;
)
