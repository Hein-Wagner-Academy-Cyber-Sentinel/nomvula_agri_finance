# Phase 1 reflection — Lutho Mathontsi

Program: Cyber sentinel Cohort 3 (Year 2)
Team & Persona: Pair 5 - Nomvula AgriFinance
Phase Window: From 21 August 2026

1. What I did during phase 1, my primary focus was establishing the business context, regulatory framing, and threat analysis for our assigned person, Nomvula AgriFinance:

* Analyzed the operational realities of Nomvula AgriFinance as an agricultural micro-finance cooperative and authored the POPIA Exposure Assessment (`charter/popia_exposure.md`), mapping rural data collection directly to POPIA Condition 7 (Security Safeguards) and Condition 5 (Information Quality).
* Collaborated on structuring the project charter and defining explicit in-scope and out-of-scope boundaries to ensure zero standing cloud spend.
* Developed Threat Model Version 0 (`threat-model/threat-model-v0.md`), grounding our assets, actors, and entry points in Nomvula’s dominant risk theme: connectivity constraints, remote depot desks, and offline loan batch synchronization.
* Collaborated with Michael via GitHub and discussed changes or dublicate information in person or through email.

2. What I found hard

* Grounding the Threat Model: Initially, our threat analysis drifted toward complex agricultural hardware (smart tractors, automated irrigation, IoT sensors). Refocusing strictly on our core persona—a financial cooperative handling loan queues, FICA identity documents, and intermittent connectivity—required disciplined scoping to keep only the top three material risks.
* Separating Assessment Roles: Adapting to the text-native deliverable standard required shifting away from visual representations and ensuring every deliverable was cleanly formatted Markdown accessible to screen readers.
* Getting to know my team mate and gattering our thoughts and focusing on the work infront of us and not going out of scope. 

3. What i would do differently

* Tighter Collaboration on Persona Boundaries: I would establish an upfront agreement on the persona's core operational definition before researching threat vectors to prevent having to cut out-of-scope scenarios later.
* Talk more with my team mate on what we understand we need to do and what each of us are going to be responsible for before research. 

4. What I Now Understand That I Did Not Before

* Technical Controls Require Business and Legal Justification: I now understand that technical controls like disk encryption (AES-256) and TLS mutual authentication are not merely security best practices; POPIA Condition 7 (Section 19) legally requires appropriate, reasonable technical measures, and that you selected AES-256 and mutual TLS as the engineering controls to meet that legal duty.
* Accessible Evidence Standards: I experienced firsthand why text-native evidence (terminal logs, committed configuration files, `.cast` recordings) provides a more verifiable, version-controlled audit trail than screenshots.

