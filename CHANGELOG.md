# Changelog

## Unreleased — 0.1.0 development

- Add the Quark layout, isolated headless test launcher, and Linux CI workflow.
- Implement recurrence (`Pscan`), windows (`Pwindow`), transduction (`Ptransduce`), and bounded parallel rewriting (`Pmorphism`).
- Add deterministic UnitTest suites and native SCDoc examples.
- Local foundation tests pass on SuperCollider 3.14.1 after resolving the restricted-session Qt startup failure, selecting the native macOS Qt platform, and fixing finite Pseed usage.

### Mathematical sequence milestone

- Add bounded FKM De Bruijn cycles, reflected mixed-radix Gray traversal, Halton and additive QMC sampling, mechanical/partition rotation words, and a ten-sequence numerical registry.
- Document indexing, randomized torus shifts, machine-integer limits, sequence growth and reference-vector provenance.
- Add deterministic coverage, adjacency, recurrence, rational-pair, seed and failure tests.
- Parse/render Help and execute numerical examples and musical Event streams without audio in the CI launcher.

### Point-process and graph-systems milestone

- Add abstract PpointProcess, positive-interval Prenewal, and nonnegative exponential-kernel Phawkes with multivariate coupling, stability certification, intensity limits and bounded thinning.
- Add iterative finite Pconstraint search and policy-driven PgraphWalk with local reinforcement and metadata ownership.
- Add reference traces, cross-class integration tests, all required application examples, and finite numerical benchmarks.
- Mark the unreleased development snapshot 0.3.0-dev.

### Experimental-systems milestone

- Add Pvomm with stream-local PPM-C suffix models, exclusion, online learning and an explicit closed-alphabet boundary policy.
- Add Ppetri interleaving, RK4/Euler Pkuramoto integration, bounded breadth/depth Pbranching, and fully stabilized Psandpile avalanches.
- Add probability, analytic integration, token/mass conservation, closed-cycle guards, ownership and seeded tests, plus all required application examples.
- Mark these five APIs experimental in Help/README and advance the unreleased metadata to 0.4.0-dev.

### Added sound companions

- Preserve every existing numerical Help example and append 168 finite sound companions using the four shared instruments.
- Map durations, symbolic identities, chords, graph/net states, filter controls, phase dynamics and avalanche density to audible behavior.
- Append the companions to the standalone example files as well.
- Validate all complete Event streams and OSC scores; render representative examples offline without a live audio device.

### Stabilization cleanup

- Replace Pwindow's shifting List with an indexed ring buffer, releasing dropped references while preserving stream semantics.
- Add 250 finite reference cases, mutation isolation and gap/inval regression coverage, and two window benchmark workloads.
- Record the owner's audio-review acceptance; automated audio checks are not planned.
