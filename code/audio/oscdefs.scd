(
~idxOSC = OSCdef(\receive_index, {
	arg msg;
	var id = msg[1], index = msg[2], duration = msg[3];
	~play_slice.value(id: id, index: index, duration: duration);
}, '/index');

~ampOSC = OSCdef(\receive_amp, {
	arg msg;
	var id = msg[1], amp = msg[2];
	if(id >= 1 and: id <= 4) {
		~ampCtrls[id - 1].set(\maxAmp, amp);
	};
}, '/amp');

~verbOSC = OSCdef(\receive_verb, {
	arg msg;
	var amt = msg[1];
	~fx.set(\amt, amt);
}, '/verb');

~tr = OSCdef(\handleTrig, { |msg|
	var id = msg[2], lfo = msg[3];
	NetAddr("127.0.0.1", 7400).sendMsg("/lfo" ++ id, lfo);
}, '/tr');

// ------------------------------------------------------------------------------------------------------------

~pos = OSCdef(\position, { |msg|
	// msg.postln;
	var n = NetAddr("127.0.0.1", 7400);
	var x = msg[1], y = msg[2], dur = msg[3];
	~point.setn(0, [x, y]);
	~nLayers.do{ |i|
		var layerId = i + 1;
		defer{
			~data[layerId][\tree].kNearest(~point, 1, { |nearest|
				~processNearestPoint.(layerId, nearest, dur);
		});}
	};
}, '/pos');
)
