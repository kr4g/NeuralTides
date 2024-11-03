(
// ~idxOSC = OSCdef(\receive_index, {
// 	arg msg;
// 	var id = msg[1], index = msg[2], duration = msg[3];
// 	~play_slice.value(id: id, index: index, duration: duration);
// }, '/index');

~ampOSC = OSCdef(\receive_amp, {
	arg msg;
	var id = msg[1], minAmp = msg[2], maxAmp = msg[3];
	if(id >= 1 and: id <= 4) {
		~synths[id][\lfo].set(\minAmp, minAmp, \maxAmp, maxAmp);
	};
}, '/amp');

~verbOSC = OSCdef(\receive_verb, {
	arg msg;
	var amt = msg[1];
	~fx.set(\amt, amt);
}, '/verb');

~tr = OSCdef(\handleTrig, { |msg|
	var id = msg[2], lfo = msg[3];
	// if (lfo < ~thresh && ~belowThresh[id] == False) {
	// 	var variant = ~variants[id].choose;
	// 	~belowThresh[id] = True;
	// 	// msg.postln;
	// 	NetAddr("127.0.0.1", 7400).sendMsg("/reload", id, variant);
	// };
	//
	// if (lfo >= ~thresh && ~belowThresh[id] == True) { ~belowThresh[id] = False; };

	NetAddr("127.0.0.1", 7400).sendMsg("/layer", id, lfo);
}, '/tr');

// ------------------------------------------------------------------------------------------------------------

~pos = OSCdef(\position, { |msg|
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
