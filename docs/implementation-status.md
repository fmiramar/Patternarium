# Implementation status

Updated 2026-11-17. The specification remains the source of the full project scope. The repository is an unreleased 0.4.0-dev snapshot; no release is tagged or published.

## Completed implementation milestones

- **Milestone 0:** Quark metadata/layout, GPL-3.0-or-later license, isolated test loading, Linux CI, class-name audit, README and shared example instruments. Author credit and repository URL are supplied by Fellipe Miranda Martins.
- **Milestone 1:** Pscan, Pwindow, Ptransduce and Pmorphism, with deterministic tests and all 37 required application examples. Mutable state is stream-local; caller-owned nested objects retain the documented ownership rules.
- **Milestone 2:** PdeBruijn, PgrayCode, Pqmc, ProtationWord and PnumSeq, including all ten registry entries. QMC scrambling is documented as a random torus shift; optional Sobol/Hammersley engines are not advertised. Bounds, indexing, exact-integer limits and source provenance are documented.
- **Milestone 3:** Abstract PpointProcess, Prenewal, nonnegative exponential-kernel Phawkes, finite Pconstraint and PgraphWalk. These include common timing/output conversion, multivariate stability certification, bounded thinning/intensity, iterative bounded search, all graph policies and local reinforcement. All required application examples are present. Self-correcting timing is explicitly deferred; the frozen time-varying-rate example is marked as an approximation.

- **Milestone 4:** Experimental Pvomm, Ppetri, Pkuramoto, Pbranching and Psandpile. This completes implementation of all 19 specified public classes, including the abstract point-process base. Each experimental class has its full required application examples. PPM-C uses documented closed-alphabet escape handling, Petri firing is interleaved, Kuramoto frequencies are angular, branching has hard tree budgets, and closed sandpile stabilization is guarded even below nominal capacity.

Every implemented public class has its own file, tests and SCDoc. PTRValidation, PTRSequenceAlgorithms, PTRPointProcess, PTRGraph and PTRVommModel are the currently used private helpers. No new runtime dependencies, server plugins or global SynthDefs were added.

## Current validation

- `scripts/test.sh`: passes on local SuperCollider 3.14.1, with **173 test methods and 1520 passing assertions**, zero failures and exit status 0.
- Standard `UnitTest.runAll` also completes successfully in the isolated class configuration.
- `scripts/test.sh "$PWD/Tests/check-help.scd"`: **25 Help files render and 347 code blocks evaluate without audio**, with no parser/render warnings. Musical examples generate finite Event streams; the four SynthDefs build without being sent. Actual playback/listening is not asserted by this check.
- The 32-arrival Hawkes reference trace was independently calculated by full-history kernel summation using seed-42 sclang uniforms. It includes three rejected proposals and passes at tolerance 1e-10. Tests also cover zero-excitation equality with renewal timing, analytic multivariate stability cases, caps, positive deltas and strictly increasing times.
- Graph tests cover normalization, fixed uniform/weighted traces, valid edges, memory, non-backtracking, hard taboo, dead-end policies, metadata copying and local reinforcement. Constraint tests cover whole-solution output, finite domains, multiple solutions/constraints, failure policy, randomization, backtrack limits and ownership.
- Cross-class tests combine recurrence/renewal timing, constraints and graph walks inside Pbind, and Hawkes times with sliding windows.
- Experimental-system tests independently check PPM-C probabilities and sequence-boundary isolation, public learning isolation, Petri token conservation, analytic two-oscillator dynamics, an independent RK4 reference step, signed multi-cycle wraps, tree traversal/ownership, sandpile mass/stability and drive-order invariance, and a below-capacity closed-grid cycle. Cross-class tests compose experimental models with existing Patterns.
- Finite benchmarks, now including all five experimental systems, run without a server; see `docs/benchmarks.md`. Shell syntax checks pass.
- Normal-runtime pre-install collision audit passes for all 19 provisional public names and all five planned helper names. Current source/repository comparisons and their limits are in `class-name-audit.md`.

## Resolved environment issue

The first restricted-session sclang launch aborted in Qt's NEON feature probe before class compilation. After full execution access was enabled, `sysctl hw.optional.neon` returned 1 and the same binary started normally. The launcher was also corrected to use the offscreen Qt platform only on Linux; the installed macOS build supplies cocoa. Finite Pseed uses were corrected to supply one-item seed Patterns, because a scalar seed repeats forever in core Pseed.

## Next work and release gates

Implementation milestones 0–4 are locally validated. Milestone 5 stabilization remains. It requires independent algorithm/API review, broader resource/performance audits, target-version Linux/Windows/develop validation and final metadata/provenance review. The first hosted Linux CI run passed both the complete test suite and server-free Help checks: https://github.com/fmiramar/Patternarium/actions/runs/44145465053 (implementation commit ad1cc83). Independent second-provider review and the complete Windows/develop compatibility matrix remain pending.

## Added sound-example pass

All original Help prose and code remain byte-for-byte intact after removing only the inserted additions. Added 168 sound companions beside numerical examples and appended matching auditions to the standalone example files. These reuse the four shared Guide instruments and bound playback to 64 items. Mappings include rhythmic spacing, symbolic pitch identities, chord voices, instrumentation, stereo position, filter brightness, token-state controls and avalanche-driven density.

The Help checker now renders 25 files and evaluates 347 code blocks. An additional complete-stream check evaluated the whole finite auditions; an OSC-score check exercised event-to-synth conversion. Eight representative companions were also rendered to a temporary WAV through non-realtime scsynth, with nonzero, unclipped output and no server error messages. This is an audio-generation check, not a human listening assessment. No library classes or original numerical examples were changed by this pass.

## Pwindow cleanup and owner audio review

Pwindow now uses an indexed ring buffer. It copies each output in logical source order, clears dropped references and preserves overlap/gap/partial behavior without shifting retained items. Added 250 independent finite reference cases plus output-mutation and latest-inval gap regressions. The expanded suite passed both before and after the replacement. Added overlapping and wide-step finite benchmark workloads.

The owner has completed the audio review and accepted it for now. No automated audio rendering/playback checks will be added; existing language and server-free documentation checks remain separate. Metadata credits Fellipe Miranda Martins and points to https://github.com/fmiramar/Patternarium. No model change was needed for this cleanup.

## GitHub publication

The public development repository is https://github.com/fmiramar/Patternarium, on branch main. The supplied banner.png is displayed at the top of the README, and GitHub installation instructions are included. This publishes the development source; version 0.4.0-dev remains untagged and no stable release is claimed.
