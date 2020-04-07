## Installation

- Install [`Matlab`](https://www.mathworks.com).
- Add [`Matpower`](https://matpower.org/) to your `Matlab` installation
- Add [`Aladin`](https://github.com/alexe15/ALADIN.m) to your `Matlab` installation.
    - Make sure to switch to the [`abstractify` branch](https://github.com/alexe15/ALADIN.m/tree/abstractify) if you want to use Aladin without [Casadi](https://web.casadi.org/docs/).

!!! warning "Branch [`abstractify`](https://github.com/alexe15/ALADIN.m/tree/abstractify)"
    The branch [`abstractify`](https://github.com/alexe15/ALADIN.m/tree/abstractify) is actively being developed.
    Be prepared to see breaking changes and unintended behavior.

!!! note "Use of `matpower`"
    The code relies heavily on `Matpower`, especially on the idea of a `matpower case file` (or `mpc`).
    This bulky name is nothing but a standardized `Matlab` struct, with the advantage that it has become a *de facto* standard for Matlab-based power systems research.
    Also, `mpc` can be converted within `matpower` to/from IEEE CDF or PSS/E RAW, see the `Matpower` docs for details.