## **Project Description**

**MOReNet** (Modellierung, Optimierung und Regelung von Netzwerken heterogener Energiesysteme mit volatiler erneuerbarer Energieerzeugung) is a German research project supported by the Federal Ministry of Education and Research (BMBF). Project execution organisation is DESY (Hamburg).

The following **partners** work together:

Universitys

 - Prof. Bock, Interdisziplinäres Zentrum für Wissenschaftliches Rechnen (IWR), Ruprecht-Karls-Universität Heidelberg (coordination office)

 - Prof. Kostina, Institut für Angewandte Mathematik (IAM), Ruprecht-Karls-Universität Heidelberg

 - Prof. Kirches und Prof. Stiller, Institut für Mathematische Optimierung, Technische Universität Carolo-Wilhelmina zu Braunschweig

 - Prof. Hagenmeyer, Institut für Automation und Angewandte Informatik (IAI), Karlsruher Institut für Technologie (KIT)

Industry
 - TransnetBW GmbH, Stuttgart

 - Siemens AG, München

 - IAV GmbH, Gifhorn



Industry partners support university partners by providing guidance and use cases of practical relevance. University partners share their findings with industry partners.

Within this framework the cooperation between KIT and TransnetBW focuses on the MOReNet-subtask **distributed Load Flow Calculations (dLFC)**.


## **Problem description of dLFC**
*From the view of TransnetBW*

TransnetBW is a Transmission System Operation (TSO) with strong horizontal connection to other TSOs. It has therefore significant experience with TSO-TSO cooperation in the field of system operation. TSO-TSO cooperation is often based on central solutions, where one entity is hosting one central IT-platform, where all information and data are collected. These central IT-platforms require a corresponding governance. Energy transition and new legislation force TSOs to focus on new vertical cooperation with distribution system operators (DSO) and other partners. For this new type of cooperation, central IT-platforms are not always favorable. They sometimes lack commitment of stakeholders because the hosting party will always be in a very strong position (data owner, process owner, invest, responsibility for security etc.).

On the technical side, central systems are always facing challenges in terms of reliability (back-up procedures, fallback solutions), scalability (new partners require significant changes), flexibility and performance. Distributed solutions are in such cases a valuable alternative since they avoid some of these challenges and offer more flexibility.

KIT and TransnetBW address this problem in the MOReNet-subtask dLFC, which deals with the important use case of load flow simulations on combined TSO-DSO grid models. Such load flow simulations are essential for coordinated system operations and grid planning. At the beginning, the area of Baden-Württemberg is in focus but the vision is to provide a technical solution for a common TSO-DSO grid model (CGM) for whole Germany.

## **Solution**
*From the view of TransnetBW:*

KIT has expertise with distributed and decentralized algorithms specifically for problems from power systems. Especially the ALADIN toolbox is a great starting point for the development of an algorithm that can handle operational CGMs. KIT will improve the existing algorithms to provide a prototype software for a decentralized load flow calculation on realistic CGMs. This solution will be accompanied by a concept that describes how such a research result can become operational in daily TSO-DSO business.


## **Future Work**

The **next target** of the dLFC cooperation between KIT and TransnetBW is the proof of concept. KIT will develop an algorithm that can handle realistic TSO-DSO CGMs and delivers results of same quality as central load flow calculations. TransnetBW will support this research with know-how on grid models and realistic data.
