(
~layerLevels = OSCdef(\layers, {
	arg msg;
	// msg.postln;
	~nLayers.do{ |i|
		var layerId = i + 1;
		var n = (layerId * 2) - 1;
		// "% % %".format(layerId, n, n + 1).postln;
		~synths[layerId][\lfo].set(\lag, 0.1, \minRange, msg[n], \maxRange, msg[n + 1]);
	};
}, '/layers');

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
	// msg.postln;
	if (lfo < ~thresh && ~belowThresh[id] == False) {
		~variant[id] = ~variants[id].choose.asSymbol;
		~belowThresh[id] = True;

		// if (id == 1) { ~variant[id].postln; };

		NetAddr("127.0.0.1", 7400).sendMsg("/reload", id, ~variant[id]);
	};

	if (lfo >= ~thresh && ~belowThresh[id] == True) { ~belowThresh[id] = False; };

	NetAddr("127.0.0.1", 7400).sendMsg("/layer", id, lfo);
}, '/tr');

~reset = OSCdef(\reset, { |msg|
	msg.postln;
}, '/reset');

// ------------------------------------------------------------------------------------------------------------

~pos = OSCdef(\position, { |msg|
	var x = msg[1], y = msg[2], dur = msg[3];
	~point.setn(0, [x, y]);
	~nLayers.do{ |i|
		var layerId = i + 1;
		var variant = ~variant[layerId];
		// ~synths[layerId][\lfo].set(\minRange, 0.0, \maxRange, 1.0);

		defer{
			~data[layerId][variant][\tree].kNearest(~point, 1, { |nearest|
				~processNearestPoint.(layerId, nearest, dur);
		});}
	};
}, '/pos');
)
