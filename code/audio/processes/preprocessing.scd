(
ServerOptions.devices.do{ |item|
	item.postln;
}
)

(
Server.killAll;
s = Server.local;
s.options.outDevice_(
	// "MacBook Pro Speakers"
	"External Headphones"
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

Synth(\default);

(
~nSrc = 2;
~vrs = "d";
)

// ------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------
//
// (
// ~folder = "/Users/ryanmillett/Downloads/Final_Normalized/" ++ ~nSrc;
// ~loader = FluidLoadFolder(~folder).play(s, {
// 	"done loading folder".postln;
// });
// )
//
// // sum to mono (if not mono)
// (
// if(~loader.buffer.numChannels > 1){
// 	~src = Buffer(s);
// 	~loader.buffer.numChannels.do{
// 		arg chan_i;
// 		FluidBufCompose.processBlocking(s,
// 			~loader.buffer,
// 			startChan:chan_i,
// 			numChans:1,
// 			gain:~loader.buffer.numChannels.reciprocal,
// 			destination:~src,
// 			destGain:1,
// 			action:{"copied channel: %".format(chan_i).postln}
// 		);
// 	};
// }{
// 	"loader buffer is already mono".postln;
// 	~src = ~loader.buffer;
// };
// )

// -------------------------------------------------------------------------------
(
~codePath = PathName.new(thisProcess.nowExecutingPath).parentPath;
(~codePath ++ "processes/globals.scd").load;
(~codePath ++ "processes/functions.scd").load;
(~codePath ++ "defs/synthdefs.scd").load;
)
// -------------------------------------------------------------------------------

// ~src = Buffer.read(s, "/Users/ryanmillett/GITEX_V2/GITEX_24/Buffers/Audio/src%\%.wav".format(~nSrc, ~vrs));
~src = Buffer.read(s, "/Users/ryanmillett/Downloads/drive-download-20241108T021508Z-001/land_3.wav");
// ~indices = Buffer.read(s, "/Users/ryanmillett/nt_babylon/data/idc_%\%.wav".format(~nSrc, "a"));

// slice the buffer in non real-time
(
~indices = Buffer(s);
FluidBufOnsetSlice.processBlocking(s,~src,metric:7,threshold:0.1,windowSize:1024,hopSize:-1,fftSize:2048,minSliceLength:8,filterSize:91,indices:~indices,action:{
	"found % slice points".format(~indices.numFrames).postln;
	"average duration per slice: %".format(~src.duration / (~indices.numFrames+1)).postln;
});
)

// analysis
(
~analyses = FluidDataSet(s);
~indices.loadToFloatArray(action:{
	arg fa;
	var mfccs = Buffer(s);
	var stats = Buffer(s);
	var flat = Buffer(s);

	fa.doAdjacentPairs{
		arg start, end, i;
		var num = end - start;

		FluidBufMFCC.processBlocking(s,~src,start,num,features:mfccs,numCoeffs:13,startCoeff:1);
		FluidBufStats.processBlocking(s,mfccs,stats:stats,select:[\mean]);
		FluidBufFlatten.processBlocking(s,stats,destination:flat);

		~analyses.addPoint(i,flat);

		"analyzing slice % / %".format(i+1,fa.size-1).postln;

		if((i%100) == 99){s.sync;}
	};

	s.sync;

	~analyses.print;
});
)

(
~umapped = FluidDataSet(s);
~normed = FluidDataSet(s);
FluidUMAP(s,numNeighbours:5,minDist:0.35, iterations: 250, learnRate: 0.1).fitTransform(~analyses,~umapped,action:{
	"umap done".postln;
	FluidNormalize(s).fitTransform(~umapped,~normed,{
		"transform done.".postln;
		~tree = FluidKDTree(s, numNeighbours: 1, radius: 0.0).fit(~normed, action: {"fit done".postln});
	});
});
)

// plot
(
~normed.dump({
	arg dict;
	var point = Buffer.alloc(s,2);
	var previous = nil;
	dict.postln;
	defer{
		~fp = FluidPlotter(dict:dict,mouseMoveAction:{
			arg view, x, y;
			// [x,y].postln;
			point.setn(0,[x,y]);
			~tree.kNearest(point,1,{
				arg nearest;
				if(nearest != previous){
					nearest.postln;
					view.highlight_(nearest);
					~play_slice.(
						id: 1,
						index: nearest.asInteger,
						src: ~src,
						indices: ~indices,
						duration: 1,
					);
					// ~ls.getLabel(nearest, {arg clust; clust.postln;});
					previous = nearest;
				}
			});
		});
	}
});
)


(
~kmeans = FluidKMeans(s);
~ls = FluidLabelSet(s);
~kmeans.numClusters_(12).fitPredict(~normed, ~ls,{
	~ls.dump({
		arg dict;
		~fp.categories_(dict);
	});
});
)

// -------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------

(
~src.write("/Users/ryanmillett/NeurIPS/data/buffers/audio/%/src_%\%.wav".format(~nSrc, ~nSrc, ~vrs));
~indices.write("/Users/ryanmillett/NeurIPS/data/buffers/indices/%/idc_%\%.wav".format(~nSrc, ~nSrc, ~vrs), "wav", "float");

~normed.write("/Users/ryanmillett/NeurIPS/data/json/%/umap_norm_%\%.json".format(~nSrc, ~nSrc, ~vrs));
~tree.write("/Users/ryanmillett/NeurIPS/data/json/%/kd_tree_%\%.json".format(~nSrc, ~nSrc, ~vrs));
~ls.write("/Users/ryanmillett/NeurIPS/data/json/%/labels_%\%.json".format(~nSrc, ~nSrc, ~vrs));
~kmeans.write("/Users/ryanmillett/NeurIPS/data/json/%/km_clusters_%\%.json".format(~nSrc, ~nSrc, ~vrs));
)
