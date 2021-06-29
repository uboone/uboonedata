// This is a WCT configuration file for use in a WC/LS simulation job.
// 
// It is expected to be named inside a FHiCL configuration.  The names
// for the "inputer" and "outputer" converter components MUST match
// what is used here in wcls_input and wcls_output objects.
//

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";


local params_sim = import "pgrapher/experiment/uboone/simparams.jsonnet";
local params_files = import "pgrapher/experiment/uboone/params.jsonnet";
local params_base = params_sim {
    lar: super.lar {
         DL: std.extVar("DiffusionLongitudinal") * wc.cm2/wc.s,
	 DT: std.extVar("DiffusionTransverse") * wc.cm2/wc.s,
	 lifetime: std.extVar("ElectronLifetime") * wc.ms,
    },

    files: super.files{
        chresp: params_files.files.chresp,
    },

    overlay: super.overlay {
        filenameMC: std.extVar("YZCorrfilenameMC"),
        histnames: std.extVar("YZCorrhistnames"),
    	scaleDATA_perplane: std.extVar("scaleDATA_perplane"),
    	scaleMC_perplane: std.extVar("scaleMC_perplane"),
      ELifetimeCorrection: if std.extVar("ELifetimeCorrection") == true then true else false,
    }
};
local params = if std.extVar("sys_resp") == true
                then params_base {
                    sys_status: true,
                    sys_resp: super.sys_resp {
                        start: [std.extVar("sys_resp_start") for n in [0,1,2]],
                        magnitude: std.extVar("sys_resp_magnitude"),
                        time_smear: std.extVar("sys_resp_time_smear"),
                    }
                }
                else params_base;

local tools_maker = import "pgrapher/common/tools.jsonnet";
local tools = tools_maker(params);
local sim_maker = import "pgrapher/experiment/uboone/sim_overlay.jsonnet";
local sim = sim_maker(params, tools);

local wcls_maker = import "pgrapher/ui/wcls/nodes.jsonnet";
local wcls = wcls_maker(params, tools);

// for dumping numpy array for debugging
local io = import "pgrapher/common/fileio.jsonnet";

//local nf_maker = import "pgrapher/experiment/uboone/nf.jsonnet";
local chndb_maker = import "pgrapher/experiment/uboone/chndb.jsonnet";

//local sp_maker = import "pgrapher/experiment/uboone/sp.jsonnet";

local anode = tools.anodes[0];
local rng = tools.random; // BR insert
    
// This tags the output frame of the WCT simulation and is used in a
// couple places so define it once.
local sim_adc_frame_tag = "orig";

// Collect the WC/LS input converters for use below.  Make sure the
// "name" matches what is used in the FHiCL that loads this file.
// art_label (producer, e.g. plopper) and art_instance (e.g. bogus) may be needed
// fudge factor to account for MC/data gain e.g. 200/242=0.826
local fudge = std.extVar("gain_fudge_factor");
local wcls_input = {
    depos: wcls.input.depos(name="", scale=-1.0*fudge, art_tag="ionization"),
};

// Collect all the wc/ls output converters for use below.  Note the
// "name" MUST match what is used in theh "outputers" parameter in the
// FHiCL that loads this file.
local wcls_output = {
    // ADC output from simulation
    // pedestal_mean = "native" to SetPedestals() for RawDigits based on a native calculation per channel
    sim_digits: wcls.output.digits(name="simdigits", tags=[sim_adc_frame_tag], pedestal_mean="native"),
    
    // The noise filtered "ADC" values.  These are truncated for
    // art::Event but left as floats for the WCT SP.  Note, the tag
    // "raw" is somewhat historical as the output is not equivalent to
    // "raw data".
    //nf_digits: wcls.output.digits(name="nfdigits", tags=["raw"]),

    // The output of signal processing.  Note, there are two signal
    // sets each created with its own filter.  The "gauss" one is best
    // for charge reconstruction, the "wiener" is best for S/N
    // separation.  Both are used in downstream WC code.
    //sp_signals: wcls.output.signals(name="spsignals", tags=["gauss"]),
};


// fill SimChannel
local wcls_simchannel_sink = g.pnode({
    type: 'wclsSimChannelSink',
    name: 'postdrift',
    data: {
        anode: wc.tn(anode),
        rng: wc.tn(rng),
        tick: 0.5*wc.us,
        start_time: -1.6*wc.ms, //0.0*wc.s,
        readout_time: self.tick*9600,
        nsigma: 3.0,
        drift_speed: params.lar.drift_speed,
        uboone_u_to_rp: 100*wc.mm,
        uboone_v_to_rp: 100*wc.mm,
        uboone_y_to_rp: 100*wc.mm,
        u_time_offset: 0.0*wc.us,
        v_time_offset: 0.0*wc.us,
        y_time_offset: 0.0*wc.us,
        use_energy: true,
    },
}, nin=1, nout=1, uses=[tools.anode]);


//local drifter = sim.drifter;
/// dynamic electron lifetime
local drifter = sim.ubdrifter;

// Signal simulation.
//local ductors = sim.make_anode_ductors(anode);
//local md_pipes = sim.multi_ductor_pipes(ductors);
//local ductor = sim.multi_ductor_graph(anode, md_pipes, "mdg");
local ductor = sim.signal;


// ch-by-ch variation simulation
local perchanvar = g.pnode({
    type: "PerChannelVariation",
    name: "PerChannelVariation",
    data: {
        gain: params.elec.gain,
        shaping: params.elec.shaping,
        tick: params.daq.tick,
        truncate: true,
        per_chan_resp: wc.tn(tools.perchanresp),
    },
}, nin=1, nout=1, uses=[tools.perchanresp]);



// Noise simulation adds to signal.
//local noise_model = sim.make_noise_model(anode, sim.empty_csdb);
//local noise_model = sim.make_noise_model(anode, sim.miscfg_csdb);
//local noise = sim.add_noise(noise_model);

local digitizer = sim.digitizer(anode, tag="orig");

local chcsdb = chndb_maker(params, tools).wclscs();
local miscondb = std.extVar("miscfg");
local miscon = if miscondb == "dynamic"
                then sim.misconfigure(params, chcsdb)
                else sim.misconfigure(params);

local sink = sim.frame_sink;
//local sink = sim.depo_sink;

local magnifio = g.pnode({
    type: "MagnifySink",
    name: "origmag",
    data: {
        output_filename: "sim-overlay-check.root",
        root_file_mode: "RECREATE",
        frames: ["orig"],
        anode: wc.tn(anode),
    },
}, nin=1, nout=1);
local graph = g.pipeline([wcls_input.depos,
                          drifter, 
                          wcls_simchannel_sink,
                          ductor, perchanvar, miscon, digitizer,
                          wcls_output.sim_digits,
                          //magnifio,
                          sink]);


local app = {
    type: "Pgrapher",
    data: {
        edges: g.edges(graph),
    },
};

// Finally, the configuration sequence which is emitted.

g.uses(graph) + [app]
