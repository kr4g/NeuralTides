(
SynthDef(\play_slice, {
	arg id = 0, index = 0, src, indices, pan = 0, gate = 1;

	var startsamp, stopsamp, phs, sig, lfo, durMin, durMax, dursecs, trigEnv, env;
	var duration = \duration.kr(1);
	var alpha = \alpha.kr(0);
	// var grainSize = \grainSize.kr(1);

	startsamp = Index.kr(indices, index);
	stopsamp = Index.kr(indices, index + 1);

	phs = Phasor.ar(0, BufRateScale.ir(src), startsamp, stopsamp, startsamp);
	sig = BufRd.ar(1, src, phs);
	dursecs = (stopsamp - startsamp) / BufSampleRate.ir(src);

	dursecs = min(dursecs, 1);
	// durMax = min(dursecs, 1);
	// durMin = max(dursecs, 0.01);
	//
	// dursecs = \grainSize.kr(1).linlin(0.0,1.0,durMin,durMax);

	trigEnv = EnvGen.kr(
		Env(
			[0, 1, 1, 0],
			[dursecs * 0.125, dursecs * 0.75, dursecs * 0.125], \lin
		),
		gate: Impulse.kr(1 / dursecs), doneAction: 0
	);

	sig = sig * trigEnv;

	env = Env.perc(alpha * duration,
		(1.0 - alpha) * duration,
		curve: alpha.linlin(0.0,1.0,-2,1)).kr(doneAction: 2);

	sig = sig * \amp.kr(1, 0.05) * env * -20.dbamp;

	Out.ar(\out.kr(0), [sig, sig]);
}).add;

SynthDef(\lfo, {
	var sig = In.ar(\in.kr(0), 2);
	var lfo = SinOsc.ar(freq: LFNoise1.ar(freq: Rand(0.03, 0.05))
		.range(0.125/8, 0.5), phase: Rand(-8pi, 8pi))
	.range(\minRange.kr(0.0, 0.1), \maxRange.kr(1, 0.1));
	sig = sig * lfo;
	sig = Pan2.ar(sig, LFNoise1.ar(SinOsc.ar(ExpRand(0.13, 0.19)).range(0.833, 3.167)));
	SendTrig.kr(Impulse.kr(20), \layerId.kr(-1), lfo);
	Out.ar(\out.kr(0), sig);
}).add;

SynthDef(\verb, {
	var sig = In.ar(\in.kr(0), 2);
	var verb = JPverb.ar(sig, t60: 3.0, size: 3.5, earlyDiff: 0.707, modDepth: 0.5, modFreq: 2.5);
	sig = XFade2.ar(sig, verb, (\amt.kr(0.5) * 2) - 1);
	Out.ar(\out.kr(0), sig);
}).add;
)
