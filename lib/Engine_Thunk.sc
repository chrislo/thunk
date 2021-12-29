Engine_Thunk : CroneEngine {
  var samples;
  var track_filters;
  var track_group;
  var track_groups;
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
  var player_env;
  var player_filter_env;

  *new { arg context, doneCallback;
	^super.new(context, doneCallback);
  }

  alloc {
	samples = Array.fill(64, { arg i;
	  Buffer.alloc(context.server, 1, 2);
	});

	player_env = {
	  arg attack = 0.01,
	  release = 0.01,
	  duration = 0.5,
	  gate = 1;

	  var attackTime, releaseTime, sustainTime;

	  attack = attack.max(0.01).min(1);
	  release = release.max(0.01).min(1);
	  attackTime = attack * duration;
	  releaseTime = release * duration;
	  sustainTime = duration - attackTime - releaseTime;

	  EnvGen.ar(
		Env.linen(attackTime, sustainTime, releaseTime),
		gate:gate,
		doneAction: 2,
	  );
	};

	player_filter_env = {
	  arg filter_attack = 0.01,
	  filter_release = 1,
	  cutoff = 20000;

	  EnvGen.ar(
		Env.perc(filter_attack, filter_release, cutoff)
	  );
	};

	SynthDef("oneshotplayer", {
	  arg trackFilterOut,
	  bufnum=0,
	  rate=1,
	  start=0,
	  end=1,
	  vel=1,
	  filter=0,
	  rq=1,
	  t_trig=0;

	  var snd, env, flt, frames;

	  rate = rate*BufRateScale.kr(bufnum);
	  frames = BufFrames.kr(bufnum);
	  vel = vel.max(0).min(1);

	  snd=PlayBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate: rate,
		trigger: t_trig,
		startPos: start*frames,
		loop:0,
		doneAction: 2,
	  );

	  env = SynthDef.wrap(player_env);
	  flt = SynthDef.wrap(player_filter_env);
	  snd = Select.ar(filter, [snd * vel, RLPF.ar(snd * vel, flt, rq)]) * env;

	  Out.ar(trackFilterOut, snd);
	}).add;

	SynthDef("loopplayer", {
	  arg trackFilterOut,
	  bufnum=0,
	  rate=1,
	  start=0,
	  startloop=0,
	  end=1,
	  vel=1,
	  filter=0,
	  rq=1,
	  t_trig=0;

	  var snd, env, flt, frames;

	  rate = rate*BufRateScale.kr(bufnum);
	  frames = BufFrames.kr(bufnum);
	  vel = vel.max(0).min(1);

	  snd=LoopBuf.ar(
		numChannels:2,
		bufnum:bufnum,
		rate: rate,
		gate: 1,
		startPos: start*frames,
		startLoop: start*frames,
		endLoop: end*frames,
	  );

	  env = SynthDef.wrap(player_env);
	  flt = SynthDef.wrap(player_filter_env);
	  snd = Select.ar(filter, [snd * vel, RLPF.ar(snd * vel, flt, rq)]) * env;

	  Out.ar(trackFilterOut, snd);
	}).add;

	(0..5).do({arg i;
	  SynthDef("trackfilter"++i, {
		arg in,
		dryOut,
		reverbOut,
		reverbSend=0,
		delayOut,
		delaySend=0,
		cutoff=20000,
		resonance=0,
		volume=1;

		var input, snd;
		input = In.ar(in, 2);

		cutoff = cutoff.max(0).min(20000);
		resonance = resonance.max(0).min(1);
		volume = volume.max(0).min(1);

		// maximum filter gain (4) self-oscillates, so we back it off a bit
		snd=MoogFF.ar(input, freq: cutoff, gain: 3.9*resonance) * volume;

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
	track_groups = Array.fill(6, {arg i; Group.new(track_group, addAction: \addToTail); });
	track_filters_group = Group.new(track_group, addAction: \addAfter);
	effects_group = Group.new(track_filters_group, addAction: \addAfter);
	mixer_group = Group.new(effects_group, addAction: \addAfter);

	reverb_bus = Bus.audio(context.server, 2);
	delay_bus = Bus.audio(context.server, 2);
	mixer_bus = Bus.audio(context.server, 2);

	track_filter_busses = Array.fill(6, {arg i;
	  Bus.audio(context.server, 2); });

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

	// 1: <track_id>
	// 2: <sample_id>
	// 3: <velocity [0-1]>
	// 4: <rate>
	// 5: sample_start
	// 6: sample_end
	// 7: <loop [0, 1]>
	// 8: attack
	// 9: release
	// 10: duration
	// 11: filter [0,1]
	// 12: filter_attack
	// 13: filter_release
	// 14: cutoff
	// 15: rq
	this.addCommand("note_on","iiffffifffiffff", { arg msg;
	  var track_id = msg[1];
	  var idx = track_id-1;
	  var sample_idx = msg[2]-1;
	  var player;
	  var looping = msg[7].asBoolean;

	  // Release any currently active players for this track
	  track_groups[idx].release;

	  if (looping) {
		player = Synth("loopplayer", [
		  \bufnum:samples[sample_idx],
		  \vel, msg[3],
		  \rate, msg[4],
		  \start, msg[5],
		  \end, msg[6],
		  \attack, msg[8],
		  \release, msg[9],
		  \duration, msg[10],
		  \filter, msg[11],
		  \filter_attack, msg[12],
		  \filter_release, msg[13],
		  \cutoff, msg[14],
		  \rq, msg[15],
		  \trackFilterOut:track_filter_busses[idx],
		], target:track_groups[idx]);
	  } {
		player = Synth("oneshotplayer", [
		  \bufnum:samples[sample_idx],
		  \vel, msg[3],
		  \rate, msg[4],
		  \start, msg[5],
		  \end, msg[6],
		  \attack, msg[8],
		  \release, msg[9],
		  \duration, msg[10],
		  \filter, msg[11],
		  \filter_attack, msg[12],
		  \filter_release, msg[13],
		  \cutoff, msg[14],
		  \rq, msg[15],
		  \trackFilterOut:track_filter_busses[idx],
		], target:track_groups[idx]);
	  };

	  player.set(\t_trig, 1);
	});

	// <track_id>, <volume [0-1]>
	this.addCommand("volume","if", { arg msg;
	  var idx = msg[1]-1;

	  track_filters[idx].set(
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
	mixer_group.freeAll;
  }
}
