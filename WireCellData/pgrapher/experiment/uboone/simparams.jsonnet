// Here we override params.jsonnet to provide simulation-specific params.

local wc = import "wirecell.jsonnet";
local base = import "pgrapher/experiment/uboone/params.jsonnet";

base {
    lar: super.lar {
        // be sure you really want to have this. default value: 8 ms
        lifetime: 1000.0*wc.ms,
    },
    daq: super.daq {

        // Number of readout ticks.  See also sim.response.nticks.
        // In MB LArSoft simulation, they expect a different number of
        // ticks than acutal data. 
        nticks: 9600,
    },        

    // These parameters only make sense for running WCT simulation on
    // microboone in larsoft.  The "trigger" section is not
    // "standard".  This section is just a set up for use below in
    // "sim".  There is no trigger, per se, in the simulation but
    // rather a contract between the generators of energy depositions
    // (ie, LarG4) and the drift and induction simulation (WCT).  For
    // details of this contract see:
    // https://microboone-docdb.fnal.gov/cgi-bin/private/ShowDocument?docid=12290
    trigger : {

        // A hardware trigger occurs at some "absolute" time but near
        // 0.0 for every "event".  It is measured in "simulation" time
        // which is the same clock used for expressing energy
        // deposition times.  The following values are from table 3 of
        // DocDB 12290.
        hardware: {
            times: {

                none: 0.0,

                // BNB hardware trigger time.  Note interactions
                // associated with BNB neutrinos should all be produced
                // starting in the beam gate which begins at 3125ns and is
                // 1600ns in duration.
                bnb : -31.25*wc.ns,


                // Like above but for NUMI.  It's gate is 9600ns long starting
                // at 4687.5ns.
                numi : -54.8675*wc.ns,

                ext : -414.0625*wc.ns,
                
                mucs: -405.25*wc.ns,
            },

            // Select on of the trigger types
            type: "bnb",

            time: self.times[self.type],
        },

        // Measured relative to the hardware trigger time above is a
        // time offset to the time that the first tick of the readout
        // should sample.  This is apparently fixed for all hardware
        // trigger types (?).
        time_offset: -1.6*wc.ms,

        time: self.hardware.time + self.time_offset,
    },

    sim: super.sim {
        
        // For running in LArSoft, the simulation must be in fixed time mode. 
        fixed: true,
        continuous: false,
        fluctuate: true,

        ductor : super.ductor {
            start_time: $.daq.start_time - $.elec.fields.drift_dt + $.trigger.time,
        },

       
        // Additional e.g. 10 us time difference is due to the larger drift velocity 
        // in Garfield field response where the collection plane peak
        // at around 81 us instead of response_plane (10 cm to Y plane) /drift_speed.
        // Assuming a constant drift velocity, this correction is needed.
        // Interplane timeoffset still holds and will be intrinsically taken into account
        // in the 2D decon. 
        // ATTENTION: when response variation (sys_status) turned on, an offset is needed.
        // smearing function is centralized at t=0 instead of starting from t=0
        reframer: super.reframer{
            tbin: if $.sys_status == true 
                    then (81*wc.us-($.sys_resp.start[0]))/($.daq.tick)
                    else (81*wc.us)/($.daq.tick),
            nticks: $.daq.nticks,
            toffset: if $.sys_status == true 
                        then $.elec.fields.drift_dt - 81*wc.us + $.sys_resp.start[0]
                        else $.elec.fields.drift_dt - 81*wc.us,
        },

    },
    // This is a non-standard, MB-specific variable.  Each object
    // attribute holds an array of regions corresponding to a
    // particular set of field response functions.  A region is
    // defined as an array of trios: plane, min and max wire index.
    // Each trio defines a swath in the transverse plane bounded by
    // the min/max wires.  A region is finally the intersection or
    // overlap of all its trios in the transverse plane.
    shorted_regions : {
        uv: [ 
            [ { plane:0, min:296, max:296 } ],
            [ { plane:0, min:298, max:315 } ],
            [ { plane:0, min:317, max:317 } ],
            [ { plane:0, min:319, max:327 } ],
            [ { plane:0, min:336, max:337 } ],
            [ { plane:0, min:343, max:345 } ],
            [ { plane:0, min:348, max:351 } ],
            [ { plane:0, min:376, max:400 } ],
            [ { plane:0, min:410, max:445 } ],
            [ { plane:0, min:447, max:484 } ],
            [ { plane:0, min:501, max:503 } ],
            [ { plane:0, min:505, max:520 } ],
            [ { plane:0, min:522, max:524 } ],
            [ { plane:0, min:536, max:559 } ],
            [ { plane:0, min:561, max:592 } ],
            [ { plane:0, min:595, max:598 } ],
            [ { plane:0, min:600, max:632 } ],
            [ { plane:0, min:634, max:652 } ],
            [ { plane:0, min:654, max:654 } ],
            [ { plane:0, min:656, max:671 } ],
        ],
        vy: [
            [ { plane:2, min:2336, max:2399 } ],
            [ { plane:2, min:2401, max:2414 } ],
            [ { plane:2, min:2416, max:2463 } ],
        ],
    },

    files: super.files{
        chresp: null,
    },

    sys_status: false,
    sys_resp: {
        // overall_short_padding should take into account this offset "start".
        // currently all "start" should be the same cause we only have an overall time offset
        // compensated in reframer
        // These values correspond to files.fields[0, 1, 2]
        // e.g. normal, shorted U, and shorted Y
        start: [-10*wc.us, -10*wc.us, -10*wc.us], 
        magnitude: [1.0, 1.0, 1.0],
        time_smear: [0.0*wc.us, 0.0*wc.us, 0.0*wc.us],
    },

    overlay: {
        filenameMC: "",
        histnames: [],
	scaleDATA_perplane: [],
	scaleMC_perplane: [],
  ELifetimeCorrection: false,
    }

}
