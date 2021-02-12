### 2-12-2021

- GSK definition

  - GSK parameter d2scribes the percent of generation shifted from transmission system(s) to distribution system


- principle of selecting connection bus

  - transmission system

    - NOT slack bus

    - NOT gen-bus with high real power

      - normally, distribution systems do not connect to a generator directly

  - distribution system

    - NOT gen-bus with high real power

      - Otherwise might lead to *infeasibility*

- 53-bus system

  - in transmission region, slack bus cannot be selected as connection point

  - multiple connections between regions are possible

  - connection between 2 distribution is possible

  - max gsk of both case (53-I and 53-II) can reach 1

    - all generation in distributions are shifted to transmission

    - there is no significant different result between 2 test cases (computing time, iteration)

- 418-bus system

  - 5 test cases with 1, 3, 5, 8, 10 connections
