# GiBUU cross sections for ExtGen

Total CC and NC cross sections of GiBUU, used by GENIE (through the
`GB25_05a_00_000` tune of `ubsim/ExtGen`) to decide which neutrinos interact,
on which nucleus and in which current. GiBUU itself then generates the final
state of each selected interaction.

Files, one set per GiBUU version and physics card. `<version>` is GiBUU's
release (`2025p5` = Release 2025, patch 5); `<cardhash>` is the first 8 hex
digits of the md5 of `ubsim/ExtGen/generators/gibuu/extgen_gibuu_card.sh`,
which writes every ExtGen GiBUU card. Both tables record the full GiBUU build
(commit / `GiBUU.x` md5) and card md5 in their header, and
`extgen_gibuu_grid_init.sh` refuses to serve with a different build or card.

* `gibuu_<version>_<cardhash>_xsec.txt`: table of
  `nu_pdg CC|NC target_pdg E[GeV] sigma[1e-38 cm^2 per nucleus]`, summed over
  every process enabled in the production card, for each flavour
  (nu_e, nu_e-bar, nu_mu, nu_mu-bar) and every nucleus in the **whole**
  geometry. GENIE requires a spline for every nucleus of every material in the
  geometry, even outside `TopVolume`: for `microboonev12.gdml` that is the 13
  `volCryostat` nuclei plus N14, K39 and a free neutron (ROOT reads the GDML
  material `Vacuum` as Z = 0, A = 1).
* `gibuu_<version>_<cardhash>_xsec.xml`: the GENIE spline file made from it with
  `extgen_make_splines.py --tune GB25_05a_00_000 --cap 8 --extend-to 200`.
  This is what jobs use (`XSecTable: "genie/gibuu/<file>.xml"`).
* `gibuu_<version>_<cardhash>_max.txt`: largest trial weight seen per point
  (`nu_pdg CC|NC target_pdg E max_w[1e-38 cm^2 per nucleon] n_trials`), from
  which each grid job sets GiBUU's equal-weights Max (3 x the largest of the
  neighbouring points, floor 50).

The GiBUU build that grid jobs run, `gibuu_<version>_<commit7>.tar.gz`
(`GiBUU.x`, its gfortran runtime libraries, `buuinput` and the ExtGen GiBUU
scripts; `make_gibuu_tarball.sh`), is too large for uboonedata. It is stored in
`/pnfs/uboone/persistent/users/uboonepro/ExtGen`; copy it to a resilient area and pass it with
jobsub -f (`extgen_gibuu_grid_init.sh --gibuu-tarball <resilient path>
--gibuu-md5 <md5sum>`, as the ubsim/ExtGen xml templates do). The job checks the
md5 and the build in its `BUILD_INFO`.

All three tables come from `extgen_gibuu_tables.py` (then `extgen_make_splines.py`)
over the scan campaign; a grid job takes them as
`extgen_gibuu_grid_init.sh --tables genie/gibuu/gibuu_<version>_<cardhash>`.

Current set: `gibuu_2025p5_516d3a20` (GiBUU a4dbdba, `GiBUU.x` md5 d8ea5b75;
884 scan jobs, 2026-10-25): 62 energies 0.01-8 GeV, 128 channels (4 flavours x
CC/NC x 16 targets). Per point: 2M trials for Ar40 nu_mu CC/NC, 500k for the
other Ar40 channels and nu_mu CC/NC on Cr52, Fe56, Ni59, 20k for N14, K39 and
the free neutron, 80k otherwise.

Current tarball (in the persistent area above): `gibuu_2025p5_8cfc370.tar.gz` (md5
a6850ad78fb521f701fc87c14235abc2): GiBUU Release 2025 patch 5, branch
`v08_00_00_br` 8cfc370 (multi-run fix, random real-perturbative pairing and
redraw after the just-collided veto), `GiBUU.x` md5 980db57e, card 25a5f19f,
gcc 12.1.0, no ROOT. It is used with the 516d3a20 tables and
`--allow-build-mismatch`: the tables come from build a4dbdba and card 516d3a20,
and the later FSI and card changes do not affect them (the scans have no FSI
time steps; checked against the patched standalone: numu CC 1.0045 +- 0.0022,
NC 0.9995 +- 0.0020). Validated in the 260k-event run-4c production
(2026-11-05).

The cross sections must come from the same card as the production, with
only the energy and target changed. Each production job checks them against
GiBUU's own trial statistics.
