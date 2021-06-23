Engine_Thunk : CroneEngine {
  var samples;
  var tracks;
  var track_group;
  var effects_group;
  var reverb_bus;
  var reverb;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    samples = Array.fill(64, { arg i;
      Buffer.alloc(context.server, 1, 2);
    });

    (0..5).do({arg i;
      SynthDef("track"++i, {
        arg dryOut=0,
        reverbOut,
        reverbSend=0,
        bufnum=0,
        rate=1,
        start=0,
        end=1,
        vel=1,
        cutoff=1,
        resonance=0.5,
        t_trig=0;

        var snd,pos,frames,duration,env,clamped_vel;

        rate = rate*BufRateScale.kr(bufnum);
        frames = BufFrames.kr(bufnum);
        duration = frames*(end-start)/rate.abs/context.server.sampleRate;

        vel = vel.max(0).min(1);
        cutoff = cutoff.max(0).min(1);
        resonance = resonance.max(0).min(1);

        env=EnvGen.ar(
          Env.new(
            levels: [0,1,1,0],
            times: [0,duration,0],
          ),
          gate:t_trig,
        );

        pos=Phasor.ar(
          trig:t_trig,
          rate:rate,
          start:start*frames,
          end:end*frames,
          resetPos:start*frames,
        );

        snd=BufRd.ar(
          numChannels:2,
          bufnum:bufnum,
          phase:pos,
          loop:0,
          interpolation:4,
        );

        snd = snd * env * vel;

        // maximum filter gain (4) self-oscillates, so we back it off a bit
        snd=MoogFF.ar(snd, freq: 20000*cutoff, gain: 3.9*resonance);

        Out.ar(reverbOut,(snd * reverbSend));
        Out.ar(dryOut,(snd * (1 - reverbSend)));

      }).add;
    });

    SynthDef("reverb", {
      arg out = 0,
      in,
      room,
      damp;

      var input;
      input = In.ar(in, 2);

      Out.ar(out, FreeVerb2.ar(input[0], input[1], mix: 1, room: room, damp: damp));
    }).add;

    context.server.sync;

    track_group = Group.new(context.xg);
    effects_group = Group.new(track_group, addAction: \addAfter);
    reverb_bus = Bus.audio(context.server, 2);

    tracks = Array.fill(6,{arg i;
      Synth("track"++i,[\bufnum:samples[i], \reverbOut:reverb_bus, \dryOut: context.out_b], target:track_group);
    });

    reverb = Synth("reverb", [\in: reverb_bus, \out: context.out_b], target: effects_group);

    this.addCommand("load_sample","is", { arg msg;
      var idx = msg[1]-1;
      var fn = msg[2];

      Buffer.read(context.server, fn, action: { arg buf;
        if(buf.numChannels == 1) {
          samples[idx].free;
          samples[idx] = Buffer.readChannel(context.server,fn,channels:[0,0]);
        } {
          samples[idx].free;
          samples[idx] = buf;
        };
        buf.free;
      });
    });

    // <track_id>, <sample_id>, <velocity [0-1]>
    this.addCommand("note_on","iif", { arg msg;
      var idx = msg[1]-1;
      var sample_idx = msg[2]-1;

      tracks[idx].set(
        \t_trig, 1,
        \bufnum, samples[sample_idx],
        \vel, msg[3]
      );
    });

    // <track_id>, <cutoff [0-1]>
    this.addCommand("cutoff","if", { arg msg;
      var idx = msg[1]-1;

      tracks[idx].set(
        \cutoff, msg[2],
       );
    });

    // <track_id>, <resonance [0-1]>
    this.addCommand("resonance","if", { arg msg;
      var idx = msg[1]-1;

      tracks[idx].set(
        \resonance, msg[2],
       );
    });

    // <track_id>, <reverb_send [0-1]>
    this.addCommand("reverb_send","if", { arg msg;
      var idx = msg[1]-1;

      tracks[idx].set(
        \reverbSend, msg[2],
       );
    });

    // <room [0-1]>
    this.addCommand("reverb_room","f", { arg msg;
      reverb.set(
        \room, msg[1],
       );
    });

    // <damp [0-1]>
    this.addCommand("reverb_damp","f", { arg msg;
      reverb.set(
        \damp, msg[1],
       );
    });
  }

  free {
    (0..63).do({arg i; samples[i].free});
    track_group.freeAll;
    effects_group.freeAll;
  }
}
