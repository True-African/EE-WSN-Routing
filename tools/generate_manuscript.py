from datetime import datetime
from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches


ROOT = Path(__file__).resolve().parents[1]
OUT_PATH = ROOT / "manuscript" / "AWARE-UC-research-draft.docx"

FINAL_DIR = ROOT / "results" / "confirmatory"
SINK_ANALYSIS_DIR = ROOT / "results" / "sink-sweep"
OLD_MEDIA_DIR = ROOT / "manuscript" / "assets" / "old-thesis-media"
REFS_APA = ROOT / "manuscript" / "AWARE_UC_references_apa.txt"
FLOWCHART_PATH = ROOT / "manuscript" / "aware_uc_flowchart.png"


def add_title(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run(text)
    run.bold = True
    run.font.size = None


def add_heading(doc, text, level=1):
    doc.add_heading(text, level=level)


def add_body(doc, text):
    doc.add_paragraph(text)


def add_equation(doc, text):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = p.add_run(text)
    run.italic = True


def add_bullets(doc, items):
    for item in items:
        doc.add_paragraph(f"- {item}")


def add_numbered(doc, items):
    for idx, item in enumerate(items, 1):
        doc.add_paragraph(f"{idx}. {item}")


def add_table(doc, headers, rows):
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    for i, h in enumerate(headers):
        table.rows[0].cells[i].text = h
    for row in rows:
        cells = table.add_row().cells
        for i, value in enumerate(row):
            cells[i].text = str(value)
    doc.add_paragraph()


def add_figure(doc, image_path, caption):
    if image_path.exists():
        doc.add_picture(str(image_path), width=Inches(6.3))
        p = doc.add_paragraph(caption)
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    else:
        add_body(doc, f"[Missing figure: {image_path}]")


def build_document():
    doc = Document()

    add_title(doc, "AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering for Improving Data Availability in Wireless Sensor Networks")
    add_body(doc, "Standalone research draft based on the 2026 AERT-UC simulation study.")
    add_body(doc, "This document is a new research manuscript. It uses the earlier thesis only as background motivation and builds the main contribution around the AWARE-UC model, implementation, calibration, simulation sweeps, and confirmatory experiments. In the MATLAB project, the implementation file remains protocol_aert_uc.m for traceability because the protocol was first developed under the working name AERT-UC. In the research writing, the clearer protocol name AWARE-UC is used.")

    add_heading(doc, "Abstract", 1)
    add_body(doc, "Wireless sensor networks (WSNs) are widely used for environmental monitoring, security, agriculture, industrial sensing, and Internet of Things applications. Their usefulness is limited by the finite battery energy of sensor nodes, especially when cluster heads consume energy rapidly while receiving, aggregating, and forwarding data to a base station. The earlier thesis work investigated threshold-based data availability through EDD-LEACH and reported improved packet delivery compared with LEACH. This research develops a new protocol named AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering. AWARE-UC combines adaptive energy thresholding, multi-factor cluster-head scoring, uneven cluster-head competition, energy-cost member assignment, and relay-assisted forwarding. A clean MATLAB simulation platform was developed from the ground up to compare LEACH, EDD-LEACH, and AWARE-UC under the same radio model, deployment assumptions, and evaluation metrics. The model was calibrated, tested across field shapes and sink placements, compared with a dynamic base-station case, and finally confirmed using 30 Monte Carlo runs. In the final confirmatory experiment, AWARE-UC improved packet delivery by 92.10% over LEACH and 95.44% over EDD-LEACH. It also improved first node death by 223.93% over LEACH and all node death by 209.80%. Across 168 sink-placement scenarios, AWARE-UC delivered more packets than both baselines in every scenario. These results show that AWARE-UC is a robust energy-aware clustering and routing model for improving data availability and network lifetime in WSNs.")

    add_heading(doc, "Chapter One: Introduction", 1)
    add_heading(doc, "Background", 2)
    add_body(doc, "Wireless sensor networks consist of spatially distributed sensor nodes that sense environmental or physical events, process the sensed data, and forward useful information to a base station. A typical WSN node contains a sensing unit, processing unit, wireless communication unit, and power supply. The network may be deployed randomly or according to an application-specific topology. Once deployed, sensor nodes are expected to operate for long periods with limited battery energy. This makes energy management one of the most important design concerns in WSN research.")
    add_body(doc, "WSNs remain important in smart agriculture, environmental observation, health monitoring, traffic surveillance, industrial monitoring, military surveillance, fire detection, security systems, and Internet of Things applications. In many of these cases, the deployed nodes are difficult to recharge or replace. When nodes deplete energy early, the network loses sensing coverage and data availability. A routing protocol must therefore preserve energy while still delivering enough packets to the BS.")
    add_body(doc, "Communication is usually the most energy-consuming operation in a WSN. A node consumes energy when transmitting data, receiving packets, listening to the channel, aggregating data, or forwarding packets for other nodes. Long-distance communication is especially expensive because radio-amplifier energy increases with distance. This is why clustering is widely used: normal nodes forward data to nearby cluster heads, and the CHs aggregate and forward data to the BS.")
    add_body(doc, "Figure 1 introduces the basic communication structure used throughout this research: ordinary sensor nodes send sensed data to CHs, and CHs aggregate and forward packets toward the BS. This structure is retained in AWARE-UC, but the method changes how CHs are selected and how forwarding decisions are made.")
    add_figure(doc, OLD_MEDIA_DIR / "image3.png", "Figure 1. Basic clustered communication model between sensor nodes, cluster heads, and the base station.")
    add_body(doc, "Cluster-based routing reduces energy consumption by grouping nodes and appointing CHs that aggregate data before forwarding it to the BS. However, classical LEACH-style approaches depend heavily on randomized CH selection and may select nodes with low residual energy, poor location, or high forwarding burden. Recent LEACH-based reviews show that modern protocols improve performance by adding residual-energy awareness, distance awareness, load balancing, optimization, and adaptive clustering (Siamantas et al., 2025).")
    add_body(doc, "Figure 2 supports the clustering assumption by showing the local relationship between one CH and its member nodes. In AWARE-UC, this relationship is not formed randomly only; each member selects a CH using a communication-energy and load-aware cost function.")
    add_figure(doc, OLD_MEDIA_DIR / "image5.png", "Figure 2. Example of cluster-head communication where normal nodes forward sensed data to a selected CH.")
    add_body(doc, "A second challenge is the hotspot problem. CHs or relay nodes near the BS may consume energy faster because they forward more data. Equal cluster sizes can therefore be inefficient. Uneven clustering addresses this by allowing cluster size or CH competition radius to vary according to topology, distance, and energy conditions. Recent reviews identify uneven clustering as a promising approach for balancing energy consumption and extending lifetime (Sharma et al., 2024).")
    add_body(doc, "Sink placement also affects WSN performance. A centered BS normally reduces average communication distance, while an edge, corner, or outside BS may increase forwarding cost. Mobile sinks can sometimes reduce hotspot effects, but recent mobile-sink research shows that mobility must be planned carefully. Simple movement does not automatically improve performance; it must consider traffic distribution, energy status, and topology (Li et al., 2024).")
    add_body(doc, "Figure 3 illustrates a larger clustered WSN architecture. It is used here to motivate the relay component of AWARE-UC, where CHs may forward through another better-positioned CH when the relay path saves energy.")
    add_figure(doc, OLD_MEDIA_DIR / "image4.png", "Figure 3. Example of clustered WSN architecture showing CHs, super-clusters, and the BS.")
    add_body(doc, "The previous thesis work proposed EDD-LEACH, a threshold-aware protocol intended to improve data delivery when nodes approach low energy. That work provided the conceptual foundation for this new research. However, the new AWARE-UC study was designed as an independent research contribution with a clean simulator, updated 2020-2026 sources, broader scenario testing, and confirmatory Monte Carlo experiments.")
    add_heading(doc, "Protocol Naming", 2)
    add_body(doc, "The protocol was initially developed under the working name AERT-UC, meaning Availability-aware Energy-Residual Threshold Uneven Clustering. For readability, the research manuscript uses the clearer name AWARE-UC: Availability and Weighted-energy Adaptive Routing with Uneven Clustering. The name highlights the protocol's core idea: it is aware of node availability, uses weighted energy and topology criteria, adapts routing decisions, and applies uneven clustering. The MATLAB file protocol_aert_uc.m is retained as the implementation name for reproducibility.")

    add_heading(doc, "Problem Statement", 2)
    add_body(doc, "Energy depletion in WSNs reduces data availability and shortens network lifetime. Random or weakly constrained CH selection can overload poorly located or low-energy nodes. Fixed thresholds alone may prevent some energy waste but do not fully address CH selection quality, uneven cluster distribution, sink placement, or relay routing cost. There is therefore a need for a protocol that jointly considers residual energy, BS distance, local density, availability threshold, load balance, and routing cost.")

    add_heading(doc, "Research Objective", 2)
    add_body(doc, "The main objective of this research is to design, implement, calibrate, and evaluate AWARE-UC as a new WSN clustering and routing protocol for improving data availability and extending network lifetime.")
    add_bullets(doc, [
        "Develop a clean MATLAB simulation platform for fair protocol comparison.",
        "Implement LEACH, SEP, EDD-LEACH, and AWARE-UC under one shared energy model.",
        "Design a multi-factor CH selection model based on residual energy, BS distance, local density, fairness, and availability.",
        "Introduce uneven clustering and energy-cost routing decisions.",
        "Evaluate AWARE-UC through calibration, shape sweeps, sink-placement sweeps, dynamic BS exploration, and confirmatory Monte Carlo simulations.",
    ])

    add_heading(doc, "Chapter Two: Updated Literature Review", 1)
    add_body(doc, "Recent WSN literature from 2020 to 2026 continues to show that energy-aware clustering is a major strategy for extending WSN lifetime. LEACH remains a reference baseline, but LEACH descendants commonly add residual energy, distance, node density, optimization, fuzzy logic, machine learning, and routing-cost considerations (Siamantas et al., 2025).")
    add_body(doc, "AI-driven cluster-based routing surveys report that fuzzy heuristics, metaheuristics, machine learning, and hybrid methods are increasingly used to solve CH selection and routing problems in WSNs. These approaches are motivated by the fact that clustering and routing are multi-factor problems rather than single-probability decisions (Shokouhifar et al., 2024).")
    add_body(doc, "Uneven clustering is another important research direction. Equal clustering can create hotspot problems, especially near the BS, because nodes or CHs close to the BS may forward more traffic. A comprehensive review by Sharma, Ahmed, and Saini (2024) shows that uneven clustering can improve load balancing, scalability, stability, and lifetime by varying cluster sizes according to energy and topology.")
    add_body(doc, "Recent mobile-sink studies show that BS mobility can reduce hotspot effects, but the benefit depends on movement path, rendezvous selection, and network data distribution. Li et al. (2024) show that mobile sink data collection remains constrained by topology and nonuniform data generation. Therefore, simple mobility is not necessarily better than a carefully designed static or routing-aware approach.")
    add_body(doc, "Recent optimization-based protocols also use multiple objectives such as node location, residual energy, BS distance, intra-cluster compactness, inter-cluster separation, and relay selection. For example, Yang et al. (2024) used a multi-strategy fusion snake optimizer and minimum spanning tree routing to improve lifetime and throughput. These recent studies motivate AWARE-UC's decision to combine energy, distance, density, fairness, availability, and relay cost in one lightweight protocol.")

    add_heading(doc, "Recent Protocol Comparison", 2)
    add_table(doc, ["Study direction", "Typical design idea", "Strength", "Limitation addressed by AWARE-UC"], [
        ["LEACH-based energy-aware routing", "Randomized CH rotation improved with residual energy and distance terms", "Simple, reproducible, and widely accepted baseline", "AWARE-UC replaces single-probability CH election with weighted scoring and availability checks"],
        ["SEP-type heterogeneous routing", "Higher CH probability for advanced-energy nodes", "Useful when some nodes start with more energy", "AWARE-UC also works under homogeneous assumptions and adds density, load, and relay-cost awareness"],
        ["Uneven clustering protocols", "Variable cluster radius according to BS distance or energy", "Reduces hotspot pressure near the BS", "AWARE-UC combines uneven clustering with threshold availability and member energy-cost assignment"],
        ["Metaheuristic CH selection", "Optimization algorithms search for CH sets or routes", "Can produce strong routing choices", "AWARE-UC keeps the model transparent and lightweight for MATLAB reproducibility"],
        ["Mobile-sink protocols", "Move BS or collection point to reduce long transmission distances", "Can reduce hotspot effects when movement is planned", "AWARE-UC first establishes a strong static-sink model and treats mobility as exploratory evidence"],
        ["Machine-learning/fuzzy protocols", "Use learned or fuzzy rules for CH choice and routing", "Can adapt to nonlinear design tradeoffs", "AWARE-UC uses explicit mathematical terms that are easier to audit and reproduce"],
    ])

    add_heading(doc, "Research Gap", 2)
    add_body(doc, "The literature shows strong progress in energy-aware and intelligent WSN routing, but many protocols are either highly optimization-heavy, focused on a single deployment condition, or do not explicitly separate threshold-based availability from clustering and routing decisions. AWARE-UC addresses this gap by proposing a transparent and simulation-reproducible model that integrates adaptive thresholding, uneven clustering, scoring-based CH selection, energy-cost member assignment, and relay-assisted forwarding.")

    add_heading(doc, "Chapter Three: Methodology", 1)
    add_heading(doc, "Research Design", 2)
    add_body(doc, "The research followed a simulation-based design. The old thesis code and plots were reviewed to identify the previous contribution and limitations. A new MATLAB project named AERT_UC_Project was then created to avoid dependency on mixed reference scripts. The project contains shared parameters, radio energy functions, deployment functions, protocol implementations, calibration routines, scenario sweep scripts, dynamic BS tests, analysis tools, and publication plot generators.")
    add_heading(doc, "Platform Setup", 2)
    add_body(doc, "The simulation platform was implemented in MATLAB. The project was organized into separate files so that each protocol and workflow component could be tested independently. The baseline LEACH protocol is implemented in protocol_leach.m. The thesis-inspired EDD-LEACH baseline is implemented in protocol_edd_leach.m. The proposed AWARE-UC protocol is treated as one standalone protocol module in protocol_aert_uc.m. This file contains the proposed adaptive thresholding, CH scoring, uneven CH competition, member assignment, relay logic, and CH-to-BS routing. The file name preserves the original working acronym AERT-UC, while the manuscript uses the clearer name AWARE-UC.")
    add_body(doc, "Other supporting files include default_params.m for shared parameters, init_network.m for node deployment, radio_tx_energy.m and radio_rx_energy.m for the radio model, run_aert_calibration.m for calibration, run_scenario_sweep.m and run_sink_sweep.m for scenario testing, run_dynamic_bs_case.m for the mobile-BS exploratory experiment, analyze_sink_sweep.m for publication-ready analysis tables and figures, plot_publication_curves.m for line plots, and run_high_confidence.m for the final 30-run confirmatory experiment. Each experiment writes output to a timestamped subfolder under results, preserving raw data, plots, and summary tables.")
    add_heading(doc, "Simulation Model", 2)
    add_body(doc, "The default network contains 100 homogeneous sensor nodes deployed in a 100 m by 100 m field, with initial energy E0 = 0.5 J and packet size k = 4000 bits. The first-order radio energy model was used because it is the standard model adopted in LEACH-style WSN simulations. The model was introduced in the classical LEACH work by Heinzelman, Chandrakasan, and Balakrishnan (2000) and remains widely discussed in recent LEACH-based WSN reviews (Siamantas et al., 2025). Transmission energy follows the free-space model for short distances and the multipath model for long distances. Reception and data aggregation costs are included for CH operations.")
    add_body(doc, "Figure 4 is included to make the radio model concrete. It shows that a transmitter consumes electronics and amplifier energy, while a receiver consumes electronics energy. This is why the simulator separates transmission, reception, and aggregation costs instead of treating communication as one constant cost.")
    add_figure(doc, OLD_MEDIA_DIR / "image7.png", "Figure 4. First-order radio energy model used to estimate transmission, reception, amplification, and aggregation cost.")
    add_heading(doc, "Symbol Table", 2)
    add_table(doc, ["Symbol", "Meaning"], [
        ["N", "Number of deployed sensor nodes"],
        ["r", "Simulation round index"],
        ["E_i(r)", "Residual energy of node i at round r"],
        ["E_0", "Initial node energy"],
        ["E_th(r)", "Adaptive availability threshold at round r"],
        ["k", "Packet size in bits"],
        ["d", "Communication distance"],
        ["d_0", "Free-space/multipath threshold distance"],
        ["E_elec", "Electronics energy per transmitted or received bit"],
        ["E_fs", "Free-space amplifier coefficient"],
        ["E_mp", "Multipath amplifier coefficient"],
        ["E_DA", "Data aggregation energy per bit"],
        ["CH", "Cluster head"],
        ["BS", "Base station"],
        ["R_i, B_i, L_i, F_i, A_i", "Normalized residual-energy, BS-distance, local-density, fairness, and availability terms"],
        ["w_E, w_D, w_L, w_F, w_A", "Weights assigned to the AWARE-UC CH scoring terms"],
    ])
    add_body(doc, "The simulator supports square, circular, triangular, and mixed deployments. The mixed deployment combines 45% rectangular distribution, 30% circular distribution, and 25% triangular distribution inside the same field. Sink placements include center, edge-top, edge-bottom, edge-left, edge-right, corner, and outside-top.")
    add_body(doc, "The flow diagram inherited from the original thesis is useful as a conceptual illustration of sensor-node activity and threshold-based decision making. However, it is not sufficient as the final AWARE-UC flow chart because the revised protocol adds weighted CH scoring, uneven CH competition, energy-cost member assignment, and relay-assisted CH forwarding. Therefore, the original diagram is retained as background context, while Figure 6 presents the updated AWARE-UC process.")
    add_figure(doc, OLD_MEDIA_DIR / "image6.png", "Figure 5. Original thesis routing/activity diagram retained as conceptual background for threshold-aware WSN communication.")
    add_body(doc, "Figure 6 summarizes the complete AWARE-UC round-level workflow. The figure should be read together with Algorithm 1: each round begins with threshold computation, then available nodes are scored, CHs are selected using uneven competition, member nodes are assigned by energy cost, CH data are forwarded directly or by relay, and performance metrics are recorded.")
    add_figure(doc, FLOWCHART_PATH, "Figure 6. Proposed AWARE-UC round-level decision flow.")
    add_heading(doc, "AWARE-UC Model", 2)
    add_body(doc, "Let the WSN contain N sensor nodes deployed in a field of dimensions Xm by Ym. The set of sensor nodes is written as:")
    add_equation(doc, r"S = {s_1, s_2, ..., s_N}")
    add_body(doc, "At round r, node si has position (xi, yi) and residual energy Ei(r). The BS position may be fixed or dynamic, and is represented as (xBS(r), yBS(r)). The Euclidean distance between two sensor nodes and the distance between a sensor node and the BS are:")
    add_equation(doc, r"d_ij = sqrt((x_i - x_j)^2 + (y_i - y_j)^2)")
    add_equation(doc, r"d_i,BS(r) = sqrt((x_i - x_BS(r))^2 + (y_i - y_BS(r))^2)")
    add_body(doc, "For a k-bit packet transmitted over distance d, the first-order radio model is written in LaTeX-style notation as:")
    add_equation(doc, r"E_TX(k,d) = { kE_elec + kE_fs d^2, d <= d_0 ; kE_elec + kE_mp d^4, d > d_0 }")
    add_equation(doc, r"d_0 = sqrt(E_fs / E_mp)")
    add_equation(doc, r"E_RX(k) = kE_elec")
    add_equation(doc, r"E_RXA(k) = kE_elec + kE_DA")
    add_body(doc, "AWARE-UC uses an adaptive energy threshold Eth(r) to decide whether a node remains available for communication. The threshold depends on estimated packet operation cost, mean residual energy pressure, and round pressure:")
    add_equation(doc, r"E_th(r) = max(E_floor, lambda E_pkt(1 + alpha P_E(r) + beta P_R(r)))")
    add_equation(doc, r"P_E(r) = 1 - E_bar(r)/E_0,     P_R(r) = r/R_max")
    add_equation(doc, r"E_bar(r) = (1 / |S_a(r)|) sum_{s_i in S_a(r)} E_i(r)")
    add_equation(doc, r"E_pkt = E_TX(k,d_exp) + E_RXA(k),     d_exp = 0.25 sqrt(X_m^2 + Y_m^2)")
    add_body(doc, "In the calibrated model, alpha = 0.6, beta = 0.4, lambda = 1.8, Efloor = 10^-4 E0, and the threshold is bounded above by 0.18E0. A node is considered available only when:")
    add_equation(doc, r"E_i(r) > E_th(r)")
    add_body(doc, "For each available node, AWARE-UC computes a CH score. The score is a weighted combination of residual energy, BS-distance advantage, local density, fairness since last CH role, and availability margin:")
    add_equation(doc, r"Score_i(r) = w_E R_i(r) + w_D B_i(r) + w_L L_i(r) + w_F F_i(r) + w_A A_i(r)")
    add_equation(doc, r"w_E = 0.32,  w_D = 0.22,  w_L = 0.18,  w_F = 0.10,  w_A = 0.18")
    add_equation(doc, r"B_i(r) = 1 - norm(d_i,BS(r))")
    add_equation(doc, r"L_i(r) = norm(sum_{j=1,j!=i}^{N} I(d_ij <= R_c))")
    add_equation(doc, r"F_i(r) = norm(r - r_i^lastCH)")
    add_equation(doc, r"A_i(r) = norm(max(0, E_i(r) - E_th(r)))")
    add_body(doc, "Uneven clustering is implemented using a distance-aware CH competition radius. Candidate CHs far from the BS are given a larger competition radius, while candidates near the BS can form smaller clusters. This helps reduce hotspot effects and balances the CH burden.")
    add_equation(doc, r"R_i^comp = R_min + (R_max - R_min)(d_i,BS(r) / d_max,BS(r))")
    add_equation(doc, r"K(r) = max(1, round(p_CH |S_alive(r)|)),     p_CH = 0.09")
    add_body(doc, "Member nodes select CHs using an energy-cost function that includes member-to-CH transmission cost, CH-to-BS forwarding cost, and an estimated load penalty.")
    add_equation(doc, r"Cost(i,c) = E_TX(k,d_ic) + gamma E_TX(k,d_c,BS) + mu Load_c E_RXA(k)")
    add_equation(doc, r"c* = arg min_{c in C(r)} Cost(i,c)")
    add_equation(doc, r"gamma = 0.20,     mu = 0.40")
    add_body(doc, "If direct transmission is risky, AWARE-UC considers relay-assisted forwarding only when the relay path saves energy and all participating nodes remain above threshold.")
    add_equation(doc, r"Cost_relay(i,j,c) = E_TX(k,d_ij) + E_RX(k) + E_TX(k,d_jc)")
    add_equation(doc, r"Cost_relay(i,j,c) < (1 - delta)E_TX(k,d_ic),     delta = 0.04")
    add_heading(doc, "Algorithm 1: AWARE-UC Pseudocode", 2)
    add_body(doc, "Input: N sensor nodes, field size Xm by Ym, initial energy E0, maximum rounds Rmax, packet size k, radio parameters, calibrated AWARE-UC weights, and sink-placement setting.")
    add_body(doc, "Output: alive nodes per round, dead nodes per round, packets delivered to BS, residual energy, FND, HND, and AND.")
    add_numbered(doc, [
        "Deploy N sensor nodes using the selected field shape and initialize each node with energy E0.",
        "Set the BS position. If a dynamic BS case is selected, define its movement path.",
        "For each simulation round r, update the BS position when dynamic movement is enabled.",
        "Compute the adaptive availability threshold Eth(r).",
        "Mark node si as available only if Ei(r) is greater than Eth(r).",
        "For each available node, compute residual-energy, BS-distance, local-density, fairness, and availability terms.",
        "Compute Score_i(r) for each available node and sort candidates by descending score.",
        "Select CHs using the uneven competition radius until the target number of CHs is reached.",
        "For each non-CH available node, compute the energy-cost to each selected CH and assign the node to the minimum-cost CH.",
        "Allow direct member-to-CH transmission only when the member and CH remain above Eth(r) after the operation.",
        "If direct member transmission is risky, search for a relay node and use the relay only when it saves energy and preserves the energy threshold.",
        "For each CH, compare direct CH-to-BS transmission with relay-assisted CH forwarding through a closer CH.",
        "Transmit aggregated CH data directly or through the selected relay route, update node energies, and count delivered packets.",
        "Record alive nodes, dead nodes, packets to CH, packets to BS, residual energy, FND, HND, and AND.",
        "Repeat until Rmax is reached or no available node remains."
    ])
    add_heading(doc, "Computational Complexity", 2)
    add_body(doc, "For each round, availability screening and score calculation require O(N) operations. The local-density and CH competition steps depend on pairwise distance checks; in the direct MATLAB implementation they require O(N^2) operations. Member-to-CH assignment requires O(NC), where C is the number of selected CHs. Relay evaluation among CHs is O(C^2). Since C is much smaller than N under the target CH fraction, the dominant cost is O(N^2) per round. The memory requirement is O(N + C), excluding stored history arrays used for plotting. This complexity is acceptable for thesis-scale simulations and keeps the algorithm transparent for reproducibility.")
    add_heading(doc, "Calibration and Experiment Workflow", 2)
    add_numbered(doc, [
        "Initial smoke tests were run to confirm that all protocols produced valid alive-node and packet outputs.",
        "A calibration grid was created for AERT-UC profiles, including balanced, throughput-oriented, lifetime-oriented, dense-CH, and sink-aware profiles.",
        "The dense_ch profile was selected because it nearly doubled packet delivery while preserving strong lifetime gains.",
        "The tuned profile was set as the default AERT-UC model.",
        "A core sweep tested square, circular, triangular, and mixed fields under centered BS placement.",
        "A sink-placement sweep tested 168 scenarios across field sizes, node counts, shapes, and BS placements.",
        "A dynamic BS case compared a centered static BS with a circular mobile BS trajectory.",
        "A final high-confidence experiment used 30 Monte Carlo runs to confirm the main findings."
    ])
    add_heading(doc, "Evaluation Metrics", 2)
    add_bullets(doc, [
        "First Node Dead (FND): first round in which a node becomes unavailable.",
        "Half Nodes Dead (HND): round in which half of the network becomes unavailable.",
        "All Nodes Dead (AND): round in which all nodes become unavailable.",
        "Packets delivered to the BS.",
        "Final alive nodes.",
        "Residual network energy."
    ])

    add_heading(doc, "Chapter Four: Results and Discussion", 1)
    add_heading(doc, "Test Results and Calibration", 2)
    add_body(doc, "The first tests were short smoke tests used only to confirm that the platform was functioning. These tests showed valid outputs for LEACH, EDD-LEACH, and AERT-UC, but they were not treated as final research results. Calibration then showed that the dense_ch profile gave the strongest balance of packet delivery and lifetime. This profile increased the target CH fraction, reduced conservative routing penalties, and retained threshold-based availability protection.")
    add_heading(doc, "Confirmatory High-Confidence Results", 2)
    add_table(doc, ["Protocol", "FND mean +/- CI95", "HND mean +/- CI95", "AND mean +/- CI95", "Packets mean +/- CI95"], [
        ["LEACH", "348.47 +/- 4.28", "1048.60 +/- 13.78", "1411.03 +/- 9.79", "5276.13 +/- 54.34"],
        ["SEP", "932.57 +/- 19.01", "1068.90 +/- 6.07", "1093.20 +/- 5.86", "5266.70 +/- 29.09"],
        ["EDD-LEACH", "348.97 +/- 4.22", "1046.50 +/- 11.82", "1406.90 +/- 12.71", "5219.70 +/- 38.70"],
        ["AWARE-UC", "1129.90 +/- 6.62", "2371.40 +/- 52.54", "4384.40 +/- 60.82", "10137.60 +/- 14.07"],
    ])
    add_body(doc, "AWARE-UC improved FND by 224.25%, HND by 126.14%, AND by 210.73%, and packet delivery by 92.14% compared with LEACH. Compared with EDD-LEACH, AWARE-UC improved FND by 223.79%, HND by 126.61%, AND by 211.63%, and packet delivery by 94.22%. SEP delayed FND because its heterogeneous-election rule favors advanced nodes, but it did not sustain HND, AND, or packet delivery under the homogeneous-energy assumptions used for the main experiment. AWARE-UC therefore remained the strongest overall protocol.")
    add_body(doc, "Figure 7 shows cumulative packet delivery. The AWARE-UC curve rises faster and reaches a higher final value, confirming that the proposed threshold and routing decisions improve data availability rather than only delaying node death.")
    add_figure(doc, FINAL_DIR / "pub_packets_to_bs_curve.png", "Figure 7. Cumulative packets delivered to the BS in the 30-run high-confidence experiment.")
    add_body(doc, "Figure 8 shows the number of alive nodes over time. The delayed decline of the AWARE-UC curve explains the higher FND, HND, and AND values reported in the confirmatory table.")
    add_figure(doc, FINAL_DIR / "pub_alive_nodes_curve.png", "Figure 8. Alive nodes over simulation rounds in the high-confidence experiment.")
    add_body(doc, "Figure 9 presents the same lifetime behavior from the dead-node perspective. AWARE-UC accumulates dead nodes more slowly, which is consistent with the adaptive threshold preventing weak nodes from being overused.")
    add_figure(doc, FINAL_DIR / "pub_dead_nodes_curve.png", "Figure 9. Dead nodes over simulation rounds in the high-confidence experiment.")
    add_body(doc, "Figure 10 shows residual network energy. The smoother energy decline for AWARE-UC supports the claim that the protocol distributes communication burden more evenly among nodes and CHs.")
    add_figure(doc, FINAL_DIR / "pub_residual_energy_curve.png", "Figure 10. Residual network energy in the high-confidence experiment.")

    add_heading(doc, "Core Field-Shape Sweep", 2)
    add_body(doc, "The core sweep showed that AWARE-UC outperformed both baselines in square, circular, triangular, and mixed deployments. In 100 m by 100 m fields, packet delivery improved by approximately 84% to 91% compared with LEACH. In 300 m by 300 m fields, packet delivery improved by approximately 161% to 197%. This shows that AWARE-UC becomes especially valuable as field size increases.")
    add_table(doc, ["Scenario", "LEACH Packets", "EDD-LEACH Packets", "AWARE-UC Packets", "AWARE-UC vs LEACH"], [
        ["100x100 square center", "5294.40", "5329.00", "10135.00", "91.43%"],
        ["100x100 circle center", "5479.20", "5504.80", "10312.00", "88.20%"],
        ["100x100 triangle center", "5706.80", "5769.40", "10525.00", "84.43%"],
        ["100x100 mixed center", "5379.20", "5408.20", "10119.00", "88.12%"],
        ["300x300 square center", "2075.20", "1765.00", "5832.80", "181.07%"],
        ["300x300 circle center", "2213.80", "2466.00", "6575.40", "197.02%"],
        ["300x300 triangle center", "2843.60", "2711.20", "7427.40", "161.20%"],
        ["300x300 mixed center", "2223.80", "2091.80", "6008.20", "170.18%"],
    ])

    add_heading(doc, "Sink-Placement Sweep", 2)
    add_body(doc, "The sink-placement sweep included 168 scenarios. AWARE-UC delivered more packets than LEACH and EDD-LEACH in all 168 scenarios.")
    add_table(doc, ["Protocol", "Mean FND", "Mean HND", "Mean AND", "Mean Packets to BS", "Mean Residual Energy"], [
        ["LEACH", "165.05", "595.05", "1054.07", "4909.89", "0.00000"],
        ["EDD-LEACH", "164.91", "595.55", "1055.71", "4915.10", "0.00029"],
        ["AWARE-UC", "640.27", "1711.78", "4137.75", "12655.58", "0.33487"],
    ])
    add_body(doc, "Figure 11 compares average packets by sink placement. It shows that AWARE-UC remains ahead of LEACH and EDD-LEACH even when the BS is moved away from the center, which is important because real deployments do not always permit ideal BS placement.")
    add_figure(doc, SINK_ANALYSIS_DIR / "fig_01_packets_by_sink.png", "Figure 11. Average packets delivered by sink placement.")
    add_body(doc, "Figure 12 compares FND by sink placement. The wider separation between AWARE-UC and the baselines shows that the proposed method improves the stable period of the network, not only the final packet count.")
    add_figure(doc, SINK_ANALYSIS_DIR / "fig_02_fnd_by_sink.png", "Figure 12. Average first node death by sink placement.")
    add_body(doc, "Figure 13 summarizes packet-delivery improvement as a heatmap across shape and sink-placement combinations. The consistently positive cells show that the improvement is not limited to one favorable topology.")
    add_figure(doc, SINK_ANALYSIS_DIR / "fig_05_heatmap_packets_vs_leach.png", "Figure 13. AWARE-UC packet-delivery improvement over LEACH by shape and sink placement.")

    add_heading(doc, "Dynamic BS Exploratory Case", 2)
    add_body(doc, "The dynamic BS experiment compared a centered static BS with a circular mobile BS. For AWARE-UC, the dynamic circular BS was approximately neutral to slightly worse: packet delivery reduced by 0.7%, HND reduced by 2.7%, and AND reduced by 3.0%. This indicates that simple mobility does not automatically improve performance. Future mobile-sink work should use adaptive or energy-aware movement instead of a fixed circular path.")
    add_table(doc, ["Case", "Protocol", "FND", "HND", "AND", "Packets to BS"], [
        ["Static center", "LEACH", "348.00", "1037.80", "1427.20", "5258.40"],
        ["Static center", "EDD-LEACH", "345.00", "1031.60", "1373.60", "5168.00"],
        ["Static center", "AWARE-UC", "1127.40", "2457.40", "4434.80", "10154.20"],
        ["Dynamic circle", "LEACH", "346.60", "1046.60", "1388.00", "5214.80"],
        ["Dynamic circle", "EDD-LEACH", "349.60", "1061.00", "1436.60", "5337.80"],
        ["Dynamic circle", "AWARE-UC", "1129.00", "2391.00", "4303.40", "10082.40"],
    ])

    add_heading(doc, "Chapter Five: Conclusion", 1)
    add_body(doc, "This research proposed AWARE-UC, a new availability-aware and weighted-energy adaptive routing protocol with uneven clustering for WSNs. The protocol improves on threshold-only EDD-LEACH by combining adaptive operating thresholds, multi-factor CH scoring, uneven clustering, energy-cost member assignment, and relay-assisted forwarding.")
    add_body(doc, "The results confirm that AWARE-UC improves both network lifetime and data delivery. In the final 30-run experiment, AWARE-UC delivered 10137.60 packets to the BS, compared with 5276.13 for LEACH, 5266.70 for SEP, and 5219.70 for EDD-LEACH. It also delayed all-node death from approximately 1411 rounds in LEACH to approximately 4384 rounds.")
    add_body(doc, "The core shape and sink-placement sweeps show that the model remains strong across different deployment shapes and BS positions. The dynamic BS case suggests that mobility should be adaptive before it can be expected to improve performance.")
    add_heading(doc, "Future Work", 2)
    add_bullets(doc, [
        "Develop an adaptive mobile BS strategy based on residual energy and traffic concentration.",
        "Test heterogeneous initial energy and non-uniform packet-generation rates.",
        "Add delay, latency, and packet-loss metrics.",
        "Compare AWARE-UC with more recent AI-driven and metaheuristic protocols.",
        "Validate the model in a network simulator or hardware testbed."
    ])

    add_heading(doc, "References", 1)
    references = [
        "Bekal, P., Kumar, P., Mane, P. R., & Prabhu, G. (2024). A comprehensive review of energy efficient routing protocols for query driven wireless sensor networks. F1000Research, 12, 644. https://doi.org/10.12688/f1000research.133874.3",
        "Li, H., Dai, Y., Chen, Q., Liao, D., & Jin, H. (2024). Energy efficient mobile sink driven data collection in wireless sensor network with nonuniform data. Scientific Reports, 14, 28190. https://doi.org/10.1038/s41598-024-79825-x",
        "Sharma, Y. K., Ahmed, G., & Saini, D. K. (2024). Uneven clustering in wireless sensor networks: A comprehensive review. Computers and Electrical Engineering, 118, 109844. https://doi.org/10.1016/j.compeleceng.2024.109844",
        "Shokouhifar, M., Fanian, F., Kuchaki Rafsanjani, M., Hosseinzadeh, M., & Mirjalili, S. (2024). AI-driven cluster-based routing protocols in WSNs: A survey of fuzzy heuristics, metaheuristics, and machine learning models. Computer Science Review, 54, 100684. https://doi.org/10.1016/j.cosrev.2024.100684",
        "Siamantas, G., Rountos, D., & Kandris, D. (2025). Energy Saving in Wireless Sensor Networks via LEACH-Based, Energy-Efficient Routing Protocols. Journal of Low Power Electronics and Applications, 15(2), 19. https://doi.org/10.3390/jlpea15020019",
        "Heinzelman, W. R., Chandrakasan, A., & Balakrishnan, H. (2000). Energy-efficient communication protocol for wireless microsensor networks. Proceedings of the 33rd Hawaii International Conference on System Sciences. https://doi.org/10.1109/HICSS.2000.926982",
        "Yang, L., Zhang, D., Li, L., & He, Q. (2024). Energy efficient cluster-based routing protocol for WSN using multi-strategy fusion snake optimizer and minimum spanning tree. Scientific Reports, 14, 16786. https://doi.org/10.1038/s41598-024-66703-9",
        "Enhancing Wireless Sensor Network performance: A Novel Adaptive Grid-Based Clustering Hierarchy protocol. (2025). Array, 27, 100440. https://doi.org/10.1016/j.array.2025.100440",
        "Implementation of novel learning based energy efficient routing protocols in wireless sensor networks for internet of things use cases. (2025). Discover Computing, 28, 190. https://doi.org/10.1007/s10791-025-09718-8",
    ]
    for ref in references:
        add_body(doc, ref)
    if REFS_APA.exists():
        existing = set(references)
        for ref in REFS_APA.read_text(encoding="utf-8").splitlines():
            ref = ref.strip()
            if ref and ref not in existing:
                add_body(doc, ref)
                existing.add(ref)

    try:
        doc.save(OUT_PATH)
        print(OUT_PATH)
    except PermissionError:
        fallback = OUT_PATH.with_name(f"{OUT_PATH.stem}_revision_{datetime.now():%Y%m%d_%H%M%S}{OUT_PATH.suffix}")
        doc.save(fallback)
        print(fallback)


if __name__ == "__main__":
    build_document()
