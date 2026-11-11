# NuWro cross sections for ExtGen

Total CC and NC cross sections of NuWro, used by GENIE (through the
`NW25_11a_00_000` tune of `ubsim/ExtGen`) to decide which neutrinos interact,
on which nucleus and in which current. NuWro itself (`nuwro_extgen`, NuWro
branch `v08_00_00_br`) then generates the final state of each selected
interaction.

Files, one set per NuWro version and physics card. `<version>` is NuWro's
release (`25_11_1` = NuWro 25.11.1); `<cardhash>` is the first 8 hex digits
of the md5 of `ubsim/ExtGen/generators/nuwro/extgen_nuwro_card.sh`, which
writes every ExtGen NuWro card. Both tables record the NuWro build (commit /
`nuwro_extgen` md5) and card md5 in their header, and
`extgen_nuwro_grid_init.sh` refuses to serve with a different build or card.

* `nuwro_<version>_<cardhash>_xsec.txt`: table of
  `nu_pdg CC|NC target_pdg E[GeV] sigma[1e-38 cm^2 per nucleus]`, summed over
  the NuWro channels of that current (CC: QEL, RES, DIS, COH, MEC, HYP; NC:
  QEL, RES, DIS, COH, MEC), for each flavour (nu_e, nu_e-bar, nu_mu,
  nu_mu-bar) and every nucleus in the **whole** geometry (the 13 `volCryostat`
  nuclei plus N14, K39 and a free neutron, as for GiBUU).
* `nuwro_<version>_<cardhash>_xsec.xml`: the GENIE spline file made from it with
  `extgen_make_splines.py --tune NW25_11a_00_000 --cap 8 --extend-to 200`.
  This is what jobs use (`XSecTable: "genie/nuwro/<file>.xml"`).
* `nuwro_<version>_<cardhash>_max.txt`: largest NuWro weight seen per point
  and channel (`nu_pdg CC|NC target_pdg E dyn max_w[1e-38 cm^2 per nucleon]
  n_trials`), from which each grid job sets the Max of every channel (3 x the
  largest of the neighbouring points; a channel without weight there stays
  closed).

The NuWro build that grid jobs run, `nuwro_<version>_<cardhash>.tar.gz`
(`bin/nuwro_extgen`, `data/`, `BUILD_INFO` and the ExtGen NuWro scripts;
`make_nuwro_tarball.sh`; ROOT and Pythia6 come from CVMFS as recorded in
`BUILD_INFO`), is too large for uboonedata. It is stored in
`/pnfs/uboone/persistent/users/uboonepro/ExtGen`; copy it to a resilient area and pass it with
jobsub -f (`extgen_nuwro_grid_init.sh --nuwro-tarball <resilient path>
--nuwro-md5 <md5sum>`, as the ubsim/ExtGen xml templates do).

All three tables come from `extgen_nuwro_tables.py` (then `extgen_make_splines.py`)
over the scan campaign; a grid job takes them as
`extgen_nuwro_grid_init.sh --tables genie/nuwro/nuwro_<version>_<cardhash>`.

Two table sets, from the same NuWro build and differing only in the QEL model:

| set | QEL model | card | tarball (in the persistent area above) | use |
|---|---|---|---|---|
| `nuwro_25_11_1_0fefd586` | local Fermi gas (LFG), `sf_method = 0` for every nucleus | `extgen_nuwro_card.sh` md5 0fefd586 (ubsim b798379d, current) | `nuwro_25_11_1_0fefd586.tar.gz`, md5 d6cae3ca1ab0c99fb7a3fb99d427a29c | production (current) |
| `nuwro_25_11_1_595c318a` | spectral function (SF), `sf_method = 1` for C12, O16, Ar40, Fe56 (LFG elsewhere) | md5 595c318a (ubsim 5544a4de) | `nuwro_25_11_1_595c318a.tar.gz`, md5 4da72f88e63a67f8100c50251c38a334 | kept for comparisons |

The grid jobs check that the tables' card md5 equals that of the `extgen_nuwro_card.sh` installed with ubsim,
so the SF set only works with the SF card (ubsim 5544a4de) and its tarball (the tarball carries the same card).

Scan design (both sets): 568 scan jobs, 62 energies 0.01-8 GeV, 128 channels (4 flavours x CC/NC x 16 targets).
Trials per point and NuWro channel: 3.2M for Ar40 nu_mu CC/NC, 800k for the other Ar40 channels and nu_mu CC/NC
on Cr52, Fe56, Ni59, 200k for N14, K39 and the free neutron, 400k otherwise. Relative error of sigma at most 0.7%
from 0.2 GeV up. NuWro 25.11.1 branch `v08_00_00_br` 32065e3, `nuwro_extgen` md5 404327b3, gcc 12.1.0,
ROOT 6.28/12, Pythia 6.4.28 (UPS e26).

Physics (both): the NuWro MicroBooNE BNB card; NC MEC with `mec_kind = 1` (TEM, NuWro's only NC MEC model),
CC MEC 2020 Valencia; `spp_precision` 2000 (CC) and 8000 (NC). NaN weights (rare, hybrid RES model for
antineutrinos) are discarded as stock NuWro does, so the cross sections are those NuWro itself reports.

LFG set, `nuwro_25_11_1_0fefd586` (2026-11-05): QEL in the local Fermi gas instead of the spectral function for
C12, O16, Ar40 and Fe56 (the NuWro spectral function gives less QEL and, oddly, less FSI than LFG;
`nuwroval/sf_vs_lfg` in the development area). Against the SF set, Ar40 nu_mu, BNB flux averaged: CC QEL +16.3%,
NC QEL +26.6%, total CC +9.0%, NC +13.2%; RES, DIS, COH and MEC unchanged (0.9998-1.0003). C12, O16 and Fe56
change alike (total CC +6 to +7%); all other nuclei are unchanged within statistics. Job 349 uses seed 40349:
its job-list seed hit the stock NuWro NC DIS crash (cos theta out of range in `disevent`). Validated in the
run-4c production (1.85e20 POT, 2026-11-06) against stock NuWro with the same card.

SF set, `nuwro_25_11_1_595c318a` (2026-10-31): QEL spectral function for C12, O16, Ar40 and Fe56. Compared with
the first SF set (0bbe5a54, removed), NC MEC (TEM; that set had none) and NC `spp_precision = 8000`: Ar40 nu_mu
NC, BNB flux averaged, total +12.0%, RES -3.1%, MEC 0.029e-38 cm^2 per nucleon; CC unchanged. Jobs 75, 120 and
236 use seeds 20075, 20120 and 20236: their job-list seeds hit a stock NuWro crash (job 75: NC DIS, cos theta out
of range in `disevent`; 120 and 236: a hang in the spectral-function sampling).
