// SPDX-License-Identifier: GPL-3.0-or-later
// Evaluate blocks separately. Musical blocks use the Guide instruments.

// Pconstraint

(
Pconstraint([0, 1, 2], { |h, x| h.includes(x).not }, 3, 2).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano,
    \degree, Pconstraint((0..7), { |h, x| h.isEmpty or: { (x - h.last).abs <= 2 } }, 16, output: \values),
    \dur, 0.125).play;
)
)

(
Pconstraint([0, 2, 4, 5], { |h, x| h.isEmpty or: { (x-h.last).abs <= 2 } }, 6).asStream.all;
)

(
Pconstraint({ |i| [4, 5, 7] + [0, 2, 4, 2][i] },
    { |h, x, i| [3, 4, 7].includes((x - [0, 2, 4, 2][i]) % 12) }, 4).asStream.all;
)

(
Pconstraint((0..3), { |h, x|
    h.includes(x).not and: {
        h.isEmpty or: { h.differentiate.drop(1).abs.includes((x-h.last).abs).not }
    }
}, 4).asStream.all;
)

(
Pconstraint([48, 52, 55, 60, 64, 67], { |h, x|
    h.isEmpty or: { (x-h.last) >= 3 and: { (x-h.last) <= 12 } }
}, 3).asStream.all;
)

(
Pconstraint([0.25, 0.5, 1], { |h, x, i|
    if(i == 3) { (h.sum+x) == 2 } { (h.sum+x) < 2 }
}, 4).asStream.all;
)

(
Pconstraint({ |i| [[48, 50], [60, 62], [72, 74]][i] }, { |h, x| h.isEmpty or: { x > h.last } }, 3).asStream.all;
)

(
Pconstraint([\saw, \mallet, \farfisa], { |h, x|
    h.isEmpty or: { x != h.last }
}, 5).asStream.all;
)

(
Pconstraint([[0, 0], [1, 0], [1, 1], [0, 1]], { |h, x|
    (x != [1, 1]) and: { h.isEmpty or: { (x-h.last).abs.sum == 1 } }
}, 5).asStream.all;
)

(
Pconstraint([0, 1, 2], { |h, x| h.count { |v| v == x } < 2 }, 5).asStream.all;
)

(
Pconstraint([[400, 0.2], [1200, 0.4], [4000, 0.8]], { |h, x|
    (x[0] * x[1]) < 2000 and: { h.isEmpty or: { (x[0]-h.last[0]).abs <= 1000 } }
}, 4).asStream.all;
)

// PgraphWalk

(
PgraphWalk((a: [\b], b: [\c], c: []), \a).asStream.all;
)

(
(
Pbind(\instrument, \saw,
    \degree, Pseed(Pseq([42]), PgraphWalk(Dictionary[0 -> [2,4], 2 -> [0,5], 4 -> [0,7], 5 -> [2], 7 -> [0]], 0, 32)),
    \dur, 0.25).play;
)
)

(
Pseed(Pseq([42]), PgraphWalk((tonic: [\subdominant, \dominant], subdominant: [\dominant], dominant: [\tonic]), \tonic, 16)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((dark: [\warm], warm: [\dark, \bright], bright: [\warm]), \dark, 16)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk(Dictionary[0 -> [1,3], 1 -> [0,2], 2 -> [1,3], 3 -> [0,2]], 0, 16)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((kick: [\hat, \snare], hat: [\kick], snare: [\hat]), \kick, 16)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((intro: [\verse], verse: [\chorus, \bridge], chorus: [\verse, \outro], bridge: [\chorus], outro: []), \intro, 12)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a, \c], c: [\a, \b]), \a, 12, \nonBacktracking)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a], c: [\a]),
    \a, 16, \reinforced, reinforcement: 0.5, output: \step)).asStream.all;
)

(
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a, \c], c: [\a, \b]), \a, 12, \selfAvoiding)).asStream.all;
)

// Added sound companions. Load the Guide instruments first.

(
// Sound companion: Pconstraint / Value stream
var values = {
Pconstraint([0, 1, 2], { |h, x| h.includes(x).not }, 3, 2).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / Voice leading with bounded leaps
var values = {
Pconstraint([0, 2, 4, 5], { |h, x| h.isEmpty or: { (x-h.last).abs <= 2 } }, 6).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / Simple counterpoint-like restrictions
var values = {
Pconstraint({ |i| [4, 5, 7] + [0, 2, 4, 2][i] },
    { |h, x, i| [3, 4, 7].includes((x - [0, 2, 4, 2][i]) % 12) }, 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / All-interval row in a small space
var values = {
Pconstraint((0..3), { |h, x|
    h.includes(x).not and: {
        h.isEmpty or: { h.differentiate.drop(1).abs.includes((x-h.last).abs).not }
    }
}, 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / Chord voicing and spacing
var values = {
Pconstraint([48, 52, 55, 60, 64, 67], { |h, x|
    h.isEmpty or: { (x-h.last) >= 3 and: { (x-h.last) <= 12 } }
}, 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, midinote: x, dur: 0.35, amp: 0.05)
}.play;
)

(
// Sound companion: Pconstraint / Duration combinations
var values = {
Pconstraint([0.25, 0.5, 1], { |h, x, i|
    if(i == 3) { (h.sum+x) == 2 } { (h.sum+x) < 2 }
}, 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x, amp: 0.1)
}.play;
)

(
// Sound companion: Pconstraint / Register allocation
var values = {
Pconstraint({ |i| [[48, 50], [60, 62], [72, 74]][i] }, { |h, x| h.isEmpty or: { x > h.last } }, 3).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, midinote: x, dur: 0.35, amp: 0.05)
}.play;
)

(
// Sound companion: Pconstraint / Instrument assignment
var values = {
Pconstraint([\saw, \mallet, \farfisa], { |h, x|
    h.isEmpty or: { x != h.last }
}, 5).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: x, degree: 0, dur: 0.25, amp: 0.07)
}.play;
)

(
// Sound companion: Pconstraint / Avoiding forbidden spatial positions
var values = {
Pconstraint([[0, 0], [1, 0], [1, 1], [0, 1]], { |h, x|
    (x != [1, 1]) and: { h.isEmpty or: { (x-h.last).abs.sum == 1 } }
}, 5).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x[1]*7, pan: x[0]*2-1, dur: 0.25, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / Bounded repetition
var values = {
Pconstraint([0, 1, 2], { |h, x| h.count { |v| v == x } < 2 }, 5).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: x, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pconstraint / Valid multidimensional synthesis states
var values = {
Pconstraint([[400, 0.2], [1200, 0.4], [4000, 0.8]], { |h, x|
    (x[0] * x[1]) < 2000 and: { h.isEmpty or: { (x[0]-h.last[0]).abs <= 1000 } }
}, 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, cutoff: x[0], rq: x[1], degree: 0, dur: 0.3, amp: 0.07)
}.play;
)

(
// Sound companion: PgraphWalk / Value stream
var values = {
PgraphWalk((a: [\b], b: [\c], c: []), \a).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Harmonic transitions
var values = {
Pseed(Pseq([42]), PgraphWalk((tonic: [\subdominant, \dominant], subdominant: [\dominant], dominant: [\tonic]), \tonic, 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Timbral states
var values = {
Pseed(Pseq([42]), PgraphWalk((dark: [\warm], warm: [\dark, \bright], bright: [\warm]), \dark, 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Spatial routing
var values = {
Pseed(Pseq([42]), PgraphWalk(Dictionary[0 -> [1,3], 1 -> [0,2], 2 -> [1,3], 3 -> [0,2]], 0, 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Symbolic sample transitions
var values = {
Pseed(Pseq([42]), PgraphWalk((kick: [\hat, \snare], hat: [\kick], snare: [\hat]), \kick, 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Nonlinear form
var values = {
Pseed(Pseq([42]), PgraphWalk((intro: [\verse], verse: [\chorus, \bridge], chorus: [\verse, \outro], bridge: [\chorus], outro: []), \intro, 12)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Non-backtracking exploration
var values = {
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a, \c], c: [\a, \b]), \a, 12, \nonBacktracking)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Reinforced paths
var values = {
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a], c: [\a]),
    \a, 16, \reinforced, reinforcement: 0.5, output: \step)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: PgraphWalk / Self-avoiding traversal
var values = {
Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a, \c], c: [\a, \b]), \a, 12, \selfAvoiding)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)
