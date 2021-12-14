Engine_Thunk : CroneEngine {
  var samples;
  var tracks;
  var track_amplitudes;
  var track_filters;
  var track_group;
  var track_amplitudes_group;
  var track_amplitude_busses;
  var track_filters_group;
  var track_filter_busses;
  var effects_group;
  var mixer_group;
  var reverb_bus;
  var reverb;
  var delay_bus;
  var delay;
  var mixer_bus;
  var mixer;

  *new { arg context, doneCallback;
	^super.new(context, doneCallback);
  }

  alloc {
	samples = Array.fill(64, { arg i;
	  Buffer.alloc(context.server, 1, 2);
	});

	(0..5).do({arg i;
	  SynthDef("track"++i, {
		arg trackAmplitudeOut,
		bufnum=0,
		rate=1,
		start=0,
		end=1,
		vel=1,
		volume=1,
		t_trig=0;

		var snd,pos,frames;

		rate = rate*BufRateScale.kr(bufnum);
		frames = BufFrames.kr(bufnum);

		vel = vel.max(0).min(1);
		volume = volume.max(0).min(1);

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

		snd = snd * vel * volume;

		Out.ar(trackAmplitudeOut, snd);
	  }).add;
	});

	(0..5).do({arg i;
	  SynthDef("trackamplitude"++i, {
		arg in,
		trackFilterOut,
		attack = 0.01,
		release = 0.2,
		t_trig=0;

		var snd, env, maxRelease;

		attack = attack.max(0.01).min(1);
		release = release.max(0.01).min(1);
		maxRelease = 5;

		env=EnvGen.ar(
		  Env.perc(attackTime: attack, releaseTime: release * maxRelease),
		  gate:t_trig,
		);

		snd = In.ar(in, 2) * env;

		Out.ar(trackFilterOut, snd);
	  }).add;
	});

	(0..5).do({arg i;
	  SynthDef("trackfilter"++i, {
		arg in,
		dryOut,
		reverbOut,
		reverbSend=0,
		delayOut,
		delaySend=0,
		cutoff=20000,
		resonance=0;

		var input, snd;
		input = In.ar(in, 2);

		cutoff = cutoff.max(0).min(20000);
		resonance = resonance.max(0).min(1);

		// maximum filter gain (4) self-oscillates, so we back it off a bit
		snd=MoogFF.ar(input, freq: cutoff, gain: 3.9*resonance);

		Out.ar(reverbOut,(snd * reverbSend));
		Out.ar(delayOut,(snd * delaySend));
		Out.ar(dryOut, snd);
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

	SynthDef("delay", {
	  arg out = 0,
	  in,
	  delaytime = 0.2,
	  decaytime = 1.0;

	  var input;
	  input = In.ar(in, 2);

	  delaytime = delaytime.max(0).min(4);
	  decaytime = decaytime.max(0).min(10);

	  Out.ar(out, CombC.ar(input, maxdelaytime: 2, delaytime: delaytime, decaytime: decaytime));
	}).add;

	SynthDef("mixer", {
	  arg out, in;

	  var input;
	  input = In.ar(in, 2);

	  Out.ar(out, input.softclip);
	}).add;

	context.server.sync;

	track_group = Group.new(context.xg);
	track_amplitudes_group = Group.new(track_group, addAction: \addAfter);
	track_filters_group = Group.new(track_amplitudes_group, addAction: \addAfter);
	effects_group = Group.new(track_filters_group, addAction: \addAfter);
	mixer_group = Group.new(effects_group, addAction: \addAfter);

	reverb_bus = Bus.audio(context.server, 2);
	delay_bus = Bus.audio(context.server, 2);
	mixer_bus = Bus.audio(context.server, 2);

	track_filter_busses = Array.fill(6, {arg i;
	  Bus.audio(context.server, 2); });

	track_amplitude_busses = Array.fill(6, {arg i;
	  Bus.audio(context.server, 2); });

	tracks = Array.fill(6,{arg i;
	  Synth("track"++i, [
		\bufnum:samples[i],
		\trackAmplitudeOut:track_amplitude_busses[i],
	  ], target:track_group);
	});

	track_amplitudes = Array.fill(6,{arg i;
	  Synth("trackamplitude"++i, [
		\in:track_amplitude_busses[i],
		\trackFilterOut:track_filter_busses[i],
	  ], target:track_amplitudes_group);
	});

	track_filters = Array.fill(6,{arg i;
	  Synth("trackfilter"++i, [
		\in:track_filter_busses[i],
		\reverbOut:reverb_bus,
		\delayOut: delay_bus,
		\dryOut: mixer_bus,
	  ], target:track_filters_group);
	});

	reverb = Synth("reverb", [\in: reverb_bus, \out: mixer_bus], target: effects_group);
	delay = Synth("delay", [\in: delay_bus, \out: mixer_bus], target: effects_group);
	mixer = Synth("mixer", [\in: mixer_bus, \out: context.out_b], target: mixer_group);

	this.addCommand("load_sample","is", { arg msg;
	  var idx = msg[1]-1;
	  var fn = msg[2];

	  Buffer.read(context.server, fn, action: { arg buf;
		samples[idx].free;

		if(buf.numChannels == 1) {
		  samples[idx] = Buffer.readChannel(context.server,fn,channels:[0,0]);
		  buf.free;
		} {
		  samples[idx] = buf;
		};
	  });
	});

	// <track_id>, <sample_id>, <velocity [0-1]>, <rate>
	this.addCommand("note_on","iiff", { arg msg;
	  var idx = msg[1]-1;
	  var sample_idx = msg[2]-1;

	  tracks[idx].set(
		\t_trig, 1,
		\bufnum, samples[sample_idx],
		\vel, msg[3],
		\rate, msg[4],
	  );

	  track_amplitudes[idx].set(
		\t_trig, 1,
	  );
	});

	// <track_id>, <volume [0-1]>
	this.addCommand("volume","if", { arg msg;
	  var idx = msg[1]-1;

	  tracks[idx].set(
		\volume, msg[2],
	  );
	});


	// <track_id>, <cutoff [0-20000]>
	this.addCommand("cutoff","if", { arg msg;
	  var idx = msg[1]-1;

	  track_filters[idx].set(
		\cutoff, msg[2],
	  );
	});

	// <track_id>, <resonance [0-1]>
	this.addCommand("resonance","if", { arg msg;
	  var idx = msg[1]-1;

	  track_filters[idx].set(
		\resonance, msg[2],
	  );
	});

	// <track_id>, <attack>
	this.addCommand("attack","if", { arg msg;
	  var idx = msg[1]-1;

	  track_amplitudes[idx].set(
		\attack, msg[2],
	  );
	});

	// <track_id>, <release>
	this.addCommand("release","if", { arg msg;
	  var idx = msg[1]-1;

	  track_amplitudes[idx].set(
		\release, msg[2],
	  );
	});

	// <track_id>, <start>
	this.addCommand("sample_start","if", { arg msg;
	  var idx = msg[1]-1;

	  tracks[idx].set(
		\start, msg[2],
	  );
	});

	// <track_id>, <end>
	this.addCommand("sample_end","if", { arg msg;
	  var idx = msg[1]-1;

	  tracks[idx].set(
		\end, msg[2],
	  );
	});

	// <track_id>, <reverb_send [0-1]>
	this.addCommand("reverb_send","if", { arg msg;
	  var idx = msg[1]-1;

	  track_filters[idx].set(
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

	// <track_id>, <delay_send [0-1]>
	this.addCommand("delay_send","if", { arg msg;
	  var idx = msg[1]-1;

	  track_filters[idx].set(
		\delaySend, msg[2],
	  );
	});

	// <delaytime [0-4]>
	this.addCommand("delay_time","f", { arg msg;
	  delay.set(
		\delaytime, msg[1],
	  );
	});

	// <decaytime [0-4]>
	this.addCommand("decay_time","f", { arg msg;
	  delay.set(
		\decaytime, msg[1],
	  );
	});
  }

  free {
	(0..63).do({arg i; samples[i].free});
	track_group.freeAll;
	track_filters_group.freeAll;
	effects_group.freeAll;
  }
}
