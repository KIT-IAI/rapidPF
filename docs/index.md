# RapidPF -- Rapid prototyping for distributed power flow problems

The power flow problem is *the* cornerstone problem in power systems analysis: find all (complex) quantities in an AC electrical network in steady state.
Mathematically, the power flow problem is a system of nonlinear equations

$$g(x) = 0$$

that can be solved by the Newton method, for instance.
However, the power flow problem can also be solved in a distributed fashion,

$$
\begin{align}
g_{i}(x_i) &= 0, \\\
\sum_{i = 1}^{n} A_i x_i &= 0,
\end{align}
$$
where $i \in \{ 1, \dots, n\}$ corresponds to the $i$-th subproblem.
In plain words, the distributed power flow problem means

> to solve a power flow problem within each region $i$ whilst ensuring that the neighboring power flows satisfy the overall power flow equations.

There are several advantages of distributed approaches:

- distribute computational effort,
- preserves privacy,
- increases reliability,
- and adds flexibility.

## What to expect
The code allows to *formulate* distributed power flow problems easily.
Specifically, the features of the code include:

- Starting from several individual case files, generate a merged case file for given connections.
- Formulate distributed power flow problems in terms of function handles.
- Solve distributed power flow problems using the [Aladin toolbox.](https://github.com/alexe15/ALADIN.m)
- Fully compliant with `matpower` case files, hence allowing to use all of the built-in `matpower` functions.
- Insightful post-processing features.

## What *not *to expect

- An introduction to the power flow problem as such. There are excellent references for this, for example [this one](https://www.tandfonline.com/doi/full/10.1080/0740817X.2016.1189626?casa_token=PcNIfyUVkpEAAAAA%3Auyjxp1a-UdKfMpngiDeV6V5zfxy-H1j8ZNc60XAujhsq4lO7w_O-qst2Idu3nnf0PasCrvMx9Ae00ic)
- *Optimal* power flow problems.
- A collection of numerical routines to *solve* distributed power flow problems.
- A visualizer of `matpower` case files; use [STAC](https://immersive.erc.monash.edu/STAC/) for this.

## Installation

[See here.](installation.md)

!!! note "Use of `matpower`"
    The code relies heavily on `Matpower`, especially on the idea of a `matpower case file` (or `mpc`).
    This bulky name is nothing but a standardized `Matlab` struct, with the advantage that it has become a *de facto* standard for Matlab-based power systems research.
    Also, `mpc` can be converted within `matpower` to/from IEEE CDF or PSS/E RAW, see the `Matpower` docs for details.

