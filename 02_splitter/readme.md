# Morenet -- Case file splitter

The case file generator takes as an input several case files and generates a merged transmission/distribution system.

## Modeling assumptions

| Assumption | File | Priority | Effect on code |
| --- | --- | --- | --- |
| The numbering of the overall system goes from `1 to N`, where `N` is the number of buses in the combined system.|
| The voltage limits for the auxiliary nodes are chosen as $\operatorname{max}(v_{\text{min},i}, v_{\text{min}, j}) \leq v \leq \operatorname{min}(v_{\text{max},i}, v_{\text{max}, j})$. | | | 
| The `baseKV` value for the auxiliary node is equal to the `baseKV` value from the to-side. | | |
| When splitting a line, the transformer is always added to the line that connects the from bus with the aux bus. | | |
| The auxiliary bus is initiated with the mean of the voltage magnitudes and the voltage angles from the from- and to-buses. | | |
| We create the bus admittance matrix of region $i$ by first creating a split case file for region $i$, and then calling `makeYbus()` (built-in `matpower` function). | | |