# Morenet -- Case file generator

The case file generator takes as an input several case files and generates a merged transmission/distribution system.

## Modeling assumptions

| Assumption | File | Priority | Effect on code |
| --- | --- | --- | --- |
| The slack bus of the overall combined system is the original slack bus from the transmission system. |  | Low | Marginal |
| We connect each distribution system via a *generator* to a unique *generator* in the transmission system via a transformer.|  [replace_slack_and_generators.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/master/fun/mergefuns/replace_slack_and_generators.m)| High | Fair |
|- In the distribution system we replace the generation bus by a `PQ` bus with zero generation and original demand.<br>- If the connecting generation bus in the distribution system is the slack, then this slack in the distribution system is replaced by a `PQ` bus with zero generation/demand.<br>- On the other hand, if the connecting generation bs in the distribution system is a `PV` bus, then this `PV` bus is replaced by a `PQ` bus, and the slack bus in the distribution system is replaced by a `PV` bus.| [replace_slack_and_generators.m](https://iai-vcs.iai.kit.edu/advancedcontrol/code/morenet/blob/master/fun/mergefuns/replace_slack_and_generators.m)| High | Fair |
|If the transmission system has `N_{TS}` nodes, and if each distribiution system `i` has `N_{DS, i}` nodes for `i = 1, \dots, d`, then the overall system is going to have `N_{TS} + N_{DS_1} + \dots + N_{DS, d}` nodes|
| If the transmission system has `M_{TS}` branches, and if each distribution system `i` has `M_{DS, i}` branches for `i = 1, \dots, d`, then the overall system is going to have `M_{TS} + M_{DS, 1} + \dots + M_{DS, d} + d` branches.|
|Do not consider the generated active/reactive power in the fields `mpc.gen()`|
|The transmission system is the first region, and the `i`-th distribution system is the `i+1`-st region.|
|The numbering of the overall system goes from `1 to N`, where `N` is the number of buses in the combined system.|
|All case files have the same `baseMVA`.| | Low | Marginal |
|The voltage magnitude settings in `mpc.gen` must be equivalent.| | Low | Marginal |
| When there are several generators at a single bus, their voltage magnitude must be the same. | check-voltage_magnitudes.m | low | marginal |
| Cost functions must either linear or quadratic | | low |

## Case file splitter