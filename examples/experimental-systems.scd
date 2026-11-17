// SPDX-License-Identifier: GPL-3.0-or-later
// Experimental systems. Evaluate blocks separately; music uses the Guide instruments.

// Pvomm

(
Pseed(Pseq([42]), Pvomm([0, 2, 0, 4, 0, 2], length: 16)).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano,
    \degree, Pseed(Pseq([42]), Pvomm([0, 2, 4, 2, 0, 7, 4, 2], 3, 32)),
    \dur, 0.125).play;
)
)

(
Pseed(Pseq([42]), Pvomm([\a, \b, \x, \a, \c, \y, \a, \b, \x], 2, 16, [\a, \b])).asStream.all;
)

(
Pseed(Pseq([42]), Pvomm([\a, \b, \a, \c], 4, 12, [\unknown, \a])).asStream.all;
)

(
Pseed(Pseq([42]), Pvomm([\a, \b, \c, \a, \b, \c, \a, \b, \c], 3, 18)).asStream.all;
)

(
[false, true].collect { |learn|
    Pseed(Pseq([42]), Pvomm([0, 1, 0, 2], 2, 24, learning: learn)).asStream.all
};
)

(
[
    Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a], c: [\a]), \a, 16)).asStream.all,
    Pseed(Pseq([42]), Pvomm([\a, \b, \a, \c, \a, \b, \a], 3, 16, \a)).asStream.all
];
)

(
// Internal diagnostic: no b->c transition is learned at the boundary.
PTRVommModel([[\a, \b], [\c, \d]], 2).countsFor([\b]);
Pseed(Pseq([42]), Pvomm([[\a, \b], [\c, \d]], 2, 16)).asStream.all;
)

(
// Internal diagnostic: a -> 0.5, b -> 0.25, c -> 0.25.
PTRVommModel([\a, \b, \a, \c], 1).distribution([\a], true);
)

// Ppetri

(
Ppetri((ready: 1), (start: (consume: (ready: 1), produce: (playing: 1)))).asStream.all;
)

(
(
Pbind(\instrument, \mallet,
    \fire, Pseed(Pseq([42]), Ppetri((fuel: 16), (
        low: (consume: (fuel: 1), value: 0, delta: 0.125),
        high: (consume: (fuel: 1), weight: 2, value: 7, delta: 0.125)), 16)),
    \degree, Pfunc { |e| e[\fire][\value] },
    \dur, Pfunc { |e| e[\fire][\delta] }).play;
)
)

(
Ppetri((a: 1, b: 1), (
    moveA: (consume: (a: 1), produce: (doneA: 1)),
    moveB: (consume: (b: 1), produce: (doneB: 1))
)).do { |event| event[\marking].postln };
)

(
Ppetri((ready: 1, cue: 1), (join: (consume: (ready: 1, cue: 1), produce: (playing: 1)))).asStream.all;
)

(
Pseed(Pseq([42]), Ppetri((free: 2), (
    allocate: (consume: (free: 1), produce: (busy: 1)),
    release: (consume: (busy: 1), produce: (free: 1))), 12)).asStream.all;
)

(
Ppetri((a: 1), (
    processA: (consume: (a: 1), produce: (finishedA: 1)),
    processB: (consume: (finishedA: 1), produce: (finishedB: 1))
)).asStream.all;
)

(
Pseed(Pseq([42]), Ppetri((idleVoices: 3), (
    play: (consume: (idleVoices: 1), produce: (playingVoices: 1)),
    stop: (consume: (playingVoices: 1), produce: (idleVoices: 1))), 12)).asStream.all;
)

(
Pseed(Pseq([42]), Ppetri((buffer: 1, channel: 1), (
    acquire: (consume: (buffer: 1, channel: 1), produce: (busy: 1)),
    return: (consume: (busy: 1), produce: (buffer: 1, channel: 1))), 8)).asStream.all;
)

(
Ppetri((energy: 3), (spend: (consume: (energy: 1), produce: (heat: 1)))).asStream.all;
)

(
Pseed(Pseq([42]), Ppetri((fuel: 12), (rare: (consume: (fuel: 1), weight: 1), common: (consume: (fuel: 1), weight: 4)), 12)).asStream.all;
)

// Pkuramoto

(
Pkuramoto([1, 2], 0, [0, 0], 0.1, 4).asStream.all;
)

(
(
Pbind(\instrument, \saw, \degree, 0,
    \network, Pkuramoto([6.1, 6.3, 6.5], 2, [0, 2, 4], 0.05, 64),
    \cutoff, Pfunc { |e| e[\network][\order].linexp(0, 1, 400, 6000) },
    \dur, 0.05).play;
)
)

(
Pkuramoto(2pi * [1, 1.5], 0, [0, 0], 0.05, 40, output: \wraps).asStream.all;
)

(
[0, 1, 4].collect { |k|
    Pkuramoto([1, 1.1, 0.9], k, [0, 2, 4], 0.05, 100, output: \order).asStream.all.last
};
)

(
Pkuramoto([1, 3, 6], 0.1, [0, 0, 0], 0.05, 50, output: \order).asStream.all;
)

(
Pkuramoto([1, 1, 1, 1], [[4,4,0,0], [4,4,0,0], [0,0,4,4], [0,0,4,4]],
    [0, 0.1, pi, pi+0.1], 0.05, 32, output: \phases).asStream.all;
)

(
(
Pbind(\instrument, \mallet,
    \network, Pkuramoto(2pi * [2, 3], 0.2, [0, 0], 0.05, 80),
    \type, Pfunc { |e| if(e[\network][\wraps].any { |x| x != 0 }) { \note } { \rest } },
    \degree, Pfunc { |e| if(e[\network][\wraps][0] > 0) { 0 } { 7 } },
    \dur, 0.05).play;
)
)

(
Pkuramoto([6.1, 6.3, 6.5], 2, [0, 2, 4], 0.05, 32, output: \order).collect { |r| (cutoff: r.linexp(0, 1, 400, 6000)) }.asStream.all;
)

// Pbranching

(
Pbranching(0, 2, { |p, i| p[\value] + i + 1 }, 2, output: \value).asStream.all;
)

(
(
Pbind(\instrument, \fmPiano,
    \degree, Pbranching(0, 2, { |p, i| p[\value] + [-1, 1][i] }, 3, output: \value),
    \dur, 0.125).play;
)
)

(
Pbranching(0, 2, { |p, i| p[\value] + [-1, 1][i] }, 3, output: \value).asStream.all;
)

(
Pbranching("a", 2, { |p, i| p[\value] ++ ["b", "c"][i] }, 2, traversal: \depth).asStream.all;
)

(
(
var nodes = Pbranching(1, 2, maxDepth: 4, traversal: \breadth).asStream.all;
(0..4).collect { |depth| nodes.count { |n| n[\depth] == depth } };
)
)

(
Pbranching(1, { |n| if(n[\depth] == 0) { 2 } { 0 } }).asStream.all;
)

(
Pbranching(0, { |n| if(n[\depth] < 2) { 3 } { 1 } }, maxDepth: 3).collect { |n|
    (degree: n[\value], dur: 0.25 / (n[\depth] + 1))
}.asStream.all;
)

(
Pbranching([0.0, 0.0], 2, { |p, i| p[\value] + [[-0.2, 0.1], [0.2, 0.1]][i] }, 3, output: \value).asStream.all;
)

(
Pseed(Pseq([42]), Pbranching(1, Pwrand([0, 1, 2], [0.4, 0.3, 0.3], inf), maxDepth: 6, maxNodes: 1000)).asStream.all;
)

// Psandpile

(
Psandpile([3], drive: Pseq([1], 8), threshold: 2, output: \size).asStream.all;
)

(
(
Pbind(\instrument, \mallet, \degree, 0,
    \size, Psandpile([4,4], drive: { [1,1] }, length: 64, output: \size),
    \amp, Pfunc { |e| if(e[\size] > 0) { 0.1 } { 0 } },
    \dur, 0.125).play;
)
)

(
Psandpile([4,4], drive: { [1,1] }, length: 32, output: \size).collect { |size|
    (density: 4 + (size * 2), grainInterval: 1 / (4 + (size * 2)))
}.asStream.all;
)

(
(
Pbind(\instrument, \mallet,
    \degree, Psandpile([4,4], drive: { [1,1] }, length: 48, output: \size).collect { |n| if(n > 0) { 0 } { Rest(0) } },
    \dur, 0.125).play;
)
)

(
Psandpile([3,3], [[3,3,3],[3,3,3],[3,3,3]], { [1,1] }, length: 6).collect { |e| e[\toppledSites] }.asStream.all;
)

(
Pwindow(Psandpile([4,4], drive: { [1,1] }, length: 64, output: \size), 8, 8).collect(_.mean).asStream.all;
)

(
Psandpile([1,1], [[3]], { 0 }, length: 1).asStream.next; // four grains lost
)

(
Psandpile([4,4], drive: { [1,1] }, length: 32).collect { |e|
    [e[\state].flat.sum, e[\avalancheSize], e[\lostGrains]]
}.asStream.all;
)

// Added sound companions. Load the Guide instruments first.

(
// Sound companion: Pvomm / Value stream
var values = {
Pseed(Pseq([42]), Pvomm([0, 2, 0, 4, 0, 2], length: 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Informative long contexts
var values = {
Pseed(Pseq([42]), Pvomm([\a, \b, \x, \a, \c, \y, \a, \b, \x], 2, 16, [\a, \b])).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Sparse context fallback
var values = {
Pseed(Pseq([42]), Pvomm([\a, \b, \a, \c], 4, 12, [\unknown, \a])).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Learning recurring phrases from a corpus
var values = {
Pseed(Pseq([42]), Pvomm([\a, \b, \c, \a, \b, \c, \a, \b, \c], 3, 18)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Online learning from generated output
var values = {
[false, true].collect { |learn|
    Pseed(Pseq([42]), Pvomm([0, 1, 0, 2], 2, 24, learning: learn)).asStream.all
};
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Repetition and variation versus a fixed-order graph
var values = {
[
    Pseed(Pseq([42]), PgraphWalk((a: [\b, \c], b: [\a], c: [\a]), \a, 16)).asStream.all,
    Pseed(Pseq([42]), Pvomm([\a, \b, \a, \c, \a, \b, \a], 3, 16, \a)).asStream.all
];
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
values = values.flatten(1);
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Pvomm / Separate training sequences
var values = {
// Internal diagnostic: no b->c transition is learned at the boundary.
PTRVommModel([[\a, \b], [\c, \d]], 2).countsFor([\b]);
Pseed(Pseq([42]), Pvomm([[\a, \b], [\c, \d]], 2, 16)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Value stream
var values = {
Ppetri((ready: 1), (start: (consume: (ready: 1), produce: (playing: 1)))).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Synchronizing prerequisites
var values = {
Ppetri((ready: 1, cue: 1), (join: (consume: (ready: 1, cue: 1), produce: (playing: 1)))).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Resource constraints
var values = {
Pseed(Pseq([42]), Ppetri((free: 2), (
    allocate: (consume: (free: 1), produce: (busy: 1)),
    release: (consume: (busy: 1), produce: (free: 1))), 12)).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / One process waiting for another
var values = {
Ppetri((a: 1), (
    processA: (consume: (a: 1), produce: (finishedA: 1)),
    processB: (consume: (finishedA: 1), produce: (finishedB: 1))
)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Performer or voice tokens
var values = {
Pseed(Pseq([42]), Ppetri((idleVoices: 3), (
    play: (consume: (idleVoices: 1), produce: (playingVoices: 1)),
    stop: (consume: (playingVoices: 1), produce: (idleVoices: 1))), 12)).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Abstract buffers or channels
var values = {
Pseed(Pseq([42]), Ppetri((buffer: 1, channel: 1), (
    acquire: (consume: (buffer: 1, channel: 1), produce: (busy: 1)),
    return: (consume: (busy: 1), produce: (buffer: 1, channel: 1))), 8)).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Abstract energy capacity
var values = {
Ppetri((energy: 3), (spend: (consume: (energy: 1), produce: (heat: 1)))).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Ppetri / Competing enabled transitions
var values = {
Pseed(Pseq([42]), Ppetri((fuel: 12), (rare: (consume: (fuel: 1), weight: 1), common: (consume: (fuel: 1), weight: 4)), 12)).asStream.all;
}.value;
var labels;
values = if(values.isArray) { values } { [values] };
labels = values.collect { |e| e[\transition] }.as(Set).asArray.sort;
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x[\value].isNumber) { x[\value] } { [0,2,4,7].wrapAt(labels.indexOf(x[\transition])) }, cutoff: 500+(x[\marking].values.sum*400), dur: x[\delta].min(0.3).max(0.05), amp: 0.08)
}.play;
)

(
// Sound companion: Pkuramoto / Value stream
var values = {
Pkuramoto([1, 2], 0, [0, 0], 0.1, 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)

(
// Sound companion: Pkuramoto / Independent polyrhythms
var values = {
Pkuramoto(2pi * [1, 1.5], 0, [0, 0], 0.05, 40, output: \wraps).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)

(
// Sound companion: Pkuramoto / Synchronization as coupling increases
var values = {
[0, 1, 4].collect { |k|
    Pkuramoto([1, 1.1, 0.9], k, [0, 2, 4], 0.05, 100, output: \order).asStream.all.last
};
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)

(
// Sound companion: Pkuramoto / Divergent frequencies
var values = {
Pkuramoto([1, 3, 6], 0.1, [0, 0, 0], 0.05, 50, output: \order).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)

(
// Sound companion: Pkuramoto / Phase clusters with a matrix
var values = {
Pkuramoto([1, 1, 1, 1], [[4,4,0,0], [4,4,0,0], [0,0,4,4], [0,0,4,4]],
    [0, 0.1, pi, pi+0.1], 0.05, 32, output: \phases).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)

(
// Sound companion: Pkuramoto / Order parameter as a synthesis control
var values = {
Pkuramoto([6.1, 6.3, 6.5], 2, [0, 2, 4], 0.05, 32, output: \order).collect { |r| (cutoff: r.linexp(0, 1, 400, 6000)) }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    x.copy.putAll((instrument: \saw, degree: 0, dur: 0.1, amp: 0.07))
}.play;
)

(
// Sound companion: Pbranching / Value stream
var values = {
Pbranching(0, 2, { |p, i| p[\value] + i + 1 }, 2, output: \value).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Ornament proliferation
var values = {
Pbranching(0, 2, { |p, i| p[\value] + [-1, 1][i] }, 3, output: \value).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Phrase genealogies in depth order
var values = {
Pbranching("a", 2, { |p, i| p[\value] ++ ["b", "c"][i] }, 2, traversal: \depth).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Population growth in breadth order
var values = {

var nodes = Pbranching(1, 2, maxDepth: 4, traversal: \breadth).asStream.all;
(0..4).collect { |depth| nodes.count { |n| n[\depth] == depth } };

}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Population extinction
var values = {
Pbranching(1, { |n| if(n[\depth] == 0) { 2 } { 0 } }).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Hierarchical event density
var values = {
Pbranching(0, { |n| if(n[\depth] < 2) { 3 } { 1 } }, maxDepth: 3).collect { |n|
    (degree: n[\value], dur: 0.25 / (n[\depth] + 1))
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Recursive spatial diffusion
var values = {
Pbranching([0.0, 0.0], 2, { |p, i| p[\value] + [[-0.2, 0.1], [0.2, 0.1]][i] }, 3, output: \value).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Pbranching / Avalanche-like branching
var values = {
Pseed(Pseq([42]), Pbranching(1, Pwrand([0, 1, 2], [0.4, 0.3, 0.3], inf), maxDepth: 6, maxNodes: 1000)).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Psandpile / Value stream
var values = {
Psandpile([3], drive: Pseq([1], 8), threshold: 2, output: \size).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x % 7, dur: (0.25/(x+1)).max(0.03), amp: (0.04+(x*0.008)).min(0.12))
}.play;
)

(
// Sound companion: Psandpile / Grain-cloud density control
var values = {
Psandpile([4,4], drive: { [1,1] }, length: 32, output: \size).collect { |size|
    (density: 4 + (size * 2), grainInterval: 1 / (4 + (size * 2)))
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: 0, dur: x[\grainInterval], amp: 0.07)
}.play;
)

(
// Sound companion: Psandpile / Spatial spreading through toppled sites
var values = {
Psandpile([3,3], [[3,3,3],[3,3,3],[3,3,3]], { [1,1] }, length: 6).collect { |e| e[\toppledSites] }.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, type: if(x.isEmpty) { \rest } { \note }, degree: if(x.isEmpty) { 0 } { x.keep(8).collect { |p| p[0]+(p[1]*3) } }, pan: if(x.isEmpty) { 0 } { x.collect { |p| p[0]-1 }.mean }, dur: 0.25, amp: 0.035)
}.play;
)

(
// Sound companion: Psandpile / Form-level density from local statistics
var values = {
Pwindow(Psandpile([4,4], drive: { [1,1] }, length: 64, output: \size), 8, 8).collect(_.mean).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x % 7, dur: (0.25/(x+1)).max(0.03), amp: (0.04+(x*0.008)).min(0.12))
}.play;
)

(
// Sound companion: Psandpile / Boundary dissipation
var values = {
Psandpile([1,1], [[3]], { 0 }, length: 1).asStream.next; // four grains lost
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \mallet, degree: x[\lostGrains], dur: 0.25, amp: 0.1)
}.play;
)

(
// Sound companion: Psandpile / Repeated buildup and release
var values = {
Psandpile([4,4], drive: { [1,1] }, length: 32).collect { |e|
    [e[\state].flat.sum, e[\avalancheSize], e[\lostGrains]]
}.asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: x[0] % 7, cutoff: 500+(x[1]*300), dur: 0.2, amp: 0.06)
}.play;
)

(
// Sound companion: Patternarium-Systems / Value stream
var values = {
Pseed(Pseq([42]), Pvomm([0, 2, 0, 4], length: 8)).asStream.all;
}.value;
var tones = (a: 0, b: 2, c: 4, d: 7, x: 9, y: 11, tonic: [0,2,4], subdominant: [3,5,7], dominant: [4,6,8], dark: 0, warm: 2, bright: 7, kick: -7, snare: 0, hat: 14, intro: 0, verse: 2, chorus: 4, bridge: 7, outro: 0, quiet: 0, medium: 2, loud: 4), labels;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { tones[x[\node]] ? 0 } { if(x.isNumber) { x } { tones[x] ? 0 } }, dur: 0.2, amp: 0.08)
}.play;
)

(
// Sound companion: Patternarium-Systems / Value stream
var values = {
Pbranching(0, 2, maxDepth: 2).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \fmPiano, degree: if(x.isKindOf(Dictionary)) { x[\degree] ? if(x[\value].isNumber) { x[\value] } { (x[\depth] ? 0)*3+(x[\childIndex] ? 0)*2 } } { if(x.isNumber) { x } { if(x.isArray) { x[1]*14 } { x.size*2 } } }, pan: if(x.isArray) { x[0].clip(-1,1) } { 0 }, dur: if(x.isKindOf(Dictionary)) { x[\dur] ? (0.3/((x[\depth] ? 0)+1)) } { 0.18 }, amp: 0.08)
}.play;
)

(
// Sound companion: Patternarium-Systems / Value stream
var values = {
Pkuramoto([1, 1.1], phases: [0, 1], length: 4).asStream.all;
}.value;
values = if(values.isArray) { values } { [values] };
Pseq(values, 4).keep(64).collect { |x|
    (instrument: \saw, degree: if(x.isKindOf(Dictionary)) { (x[\phases]/2pi*7).round } { if(x.isArray) { (x/2pi*7).round } { 0 } }, cutoff: if(x.isNumber) { x.linexp(0,1,300,6000) } { 1800 }, dur: 0.1, amp: 0.045)
}.play;
)
