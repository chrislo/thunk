Engine_Thunk : CroneEngine {
  var samples;
  var tracks;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    samples = Array.fill(64, { arg i;
      Buffer.alloc(context.server, 1, 2);
    });

    (0..5).do({arg i;
      SynthDef("track"++i, {
        arg out=0,
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

        Out.ar(out,snd);

      }).add;
    });

    context.server.sync;

    tracks = Array.fill(6,{arg i;
      Synth("track"++i,[\bufnum:samples[i]], target:context.xg);
    });

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
  }

  free {
    (0..63).do({arg i; samples[i].free});
    (0..5).do({arg i; tracks[i].free});
  }
}
