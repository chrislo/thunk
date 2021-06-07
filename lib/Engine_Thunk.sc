Engine_Thunk : CroneEngine {
  var samples;
  var tracks;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    samples = Array.fill(64, { arg i;
      Buffer.read(context.server, "/Users/chris/silence.wav");
    });

    (0..5).do({arg i;
      SynthDef("track"++i, { arg out=0, bufnum=0, rate=1, start=0, end=1, vel=127, t_trig=0;
        var snd,pos,frames,duration,env,clamped_vel;

        rate = rate*BufRateScale.kr(bufnum);
        frames = BufFrames.kr(bufnum);
        duration = frames*(end-start)/rate.abs/context.server.sampleRate;

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

        clamped_vel = vel.max(0).min(127);
        snd = snd * env * (clamped_vel/127);

        Out.ar(out,snd);

      }).add;
    });

    context.server.sync;

    tracks = Array.fill(6,{arg i;
      Synth("track"++i,[\bufnum:samples[i]], target:context.xg);
    });

    this.addCommand("load_sample","is", { arg msg;
      // lua is sending 1-index
      samples[msg[1]-1].free;
      samples[msg[1]-1] = Buffer.read(context.server,msg[2]);
    });

    this.addCommand("note_on","iii", { arg msg;
      // lua is sending 1-index
      tracks[msg[1]-1].set(
        \t_trig, 1,
        \bufnum, msg[2]-1,
        \vel, msg[3]
      );
    });
  }

  free {
    (0..63).do({arg i; samples[i].free});
    (0..5).do({arg i; tracks[i].free});
  }
}
