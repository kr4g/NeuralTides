ServerOptions.devices.do{ |item| item.postln; };

(
Server.killAll;
s = Server.local;
s.options.outDevice_(
	"MacBook Pro Speakers"
	// "Ryan’s AirPods P"
	// "External Headphones"
	// "Ryan’s AirPods P"
	// "Scarlett 4i4 USB"
	// "Klipsch One II"
	// "UMC1820"
	// "MME : OUT 01-10 (BEHRINGER UMC 1820)"
);
// s.options.inDevice_("Built-in Microph");
s.options.numInputBusChannels_(0);
s.options.numOutputBusChannels_(2);
s.options.sampleRate_(48000);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
s.reboot;
)

thisProcess.openUDPPort(57120);
thisProcess.openPorts;

(
var path = PathName(thisProcess.nowExecutingPath);
3.do { path = PathName(path.parentPath) };

~dataPath = path.fullPath ++ "data/";
~codePath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~codePath ++ "processes/globals.scd").load;
(~codePath ++ "processes/functions.scd").load;
(~codePath ++ "defs/synthdefs.scd").load;
)

(
~initializeData.(~nLayers);
)

(
(~codePath ++ "defs/oscdefs.scd").load;
~setupBuses.(~nLayers);
~fx = Synth.tail(nil, \verb);
)

(
Routine({
	// 60.wait;
	inf.do{ |i|
		var layerId = (i % (~nLayers + 1)) + 1;
		// var distribution = numLayers.collect{ rrand(0.0,1) }.normalizeSum;
		if (layerId <= ~nLayers) {
			layerId.postln;
			~nLayers.do{ |k|
				var id = k + 1;
				if (layerId == id) {
					~synths[id][\lfo].set(\lag, 5, \minRange, 0.0, \maxRange, 1, \curve, -2);
					NetAddr("127.0.0.1", 7400).sendMsg("/clusters", id, 0.25, 1);
				} {
					~synths[id][\lfo].set(\lag, 5, \minRange, 0.0, \maxRange, 0.5, \curve, 2);
					NetAddr("127.0.0.1", 7400).sendMsg("/clusters", id, 0, 0.5);
				};
			};
		} {
			~nLayers.do{ |j|
				var id = j + 1;
				~synths[id][\lfo].set(\lag, 5, \minRange, 0.0, \maxRange, 0.9, \curve, -2);
				NetAddr("127.0.0.1", 7400).sendMsg("/clusters", id, 0.0, 0.8);
			};
		};
		60.wait;
	};
}).play;
)

s.record("/Users/ryanmillett/Downloads/neural_tides.wav");

// ~layerProportions.play;