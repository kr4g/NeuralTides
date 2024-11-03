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

(
var path = PathName(thisProcess.nowExecutingPath);
3.do { path = PathName(path.parentPath) };
~dataPath = path.fullPath ++ "data/";
~codePath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~codePath ++ "functions.scd").load;
(~codePath ++ "synthdefs.scd").load;
)

(
~nLayers = 4;
~initializeData.(~nLayers);
)

(
~setupBuses.(~nLayers);
(PathName.new(thisProcess.nowExecutingPath).parentPath ++ "oscdefs.scd").load;
)

~fx = Synth.tail(nil, \verb);