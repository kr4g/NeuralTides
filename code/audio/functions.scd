(
~point = Buffer.alloc(s, 2);
~previous = Dictionary.new;
4.do{ |i| ~previous[i + 1] = nil };

~synths = Dictionary.new;
~synthQueue = (
	1: [],
	2: [],
	3: [],
	4: []
);

~initializeData = { |numLayers|
	~data = Dictionary.new;
	numLayers.do { |i|
		var layerId = i + 1;
		~data[layerId] = Dictionary.newFrom([
			\source, Buffer.read(s, ~dataPath ++ "buffers/audio/%/src%a.wav".format(layerId, layerId)),
			\indices, Buffer.read(s, ~dataPath ++ "buffers/indices/%/idc_%a.wav".format(layerId, layerId)),
			\umap, FluidDataSet.new(s).read(~dataPath ++ "json/%/umap_norm_%a.json".format(layerId, layerId)),
			\labels, FluidLabelSet.new(s).read(~dataPath ++ "json/%/labels_%a.json".format(layerId, layerId)),
			\tree, FluidKDTree.new(s, 1, 0.03).read(~dataPath ++ "json/%/kd_tree_%a.json".format(layerId, layerId)),
		]);
	};
};

~setupBuses = { |numLayers|
	~lfoBuses = Array.fill(numLayers, { Bus.audio(s, 2) });
	numLayers.do { |i|
		var layerId = i + 1;
		~synths[layerId] = Dictionary.new;

		~synths[layerId][\lfo] = Synth(\lfo, [
			\in, ~lfoBuses[i],
			\out, 0
		]);
	};
};

~play_slice = {
	arg id = -1, src = nil, indices = nil, index = -1, duration = 1, amp = 1, bus = 0, alpha = 0;
	var newSynth = nil;

	if (~synthQueue[id].size >= 5) {
		if (~synthQueue[id][0].isPlaying) {
			~synthQueue[id][0].free;
		};
		~synthQueue[id] = ~synthQueue[id].drop(1);
	};

	newSynth = Synth(\play_slice, [
		\src, src,
		\indices, indices,
		\id, id,
		\index, index,
		\amp, amp,
		\duration, duration,
		\alpha, alpha,
		\out, bus
	]).onFree();

	~synthQueue[id] = ~synthQueue[id].add(newSynth);
};

~processNearestPoint = { |layerId, nearest, dur|
	~data[layerId][\labels].getLabel(nearest.asInteger, { |clust = -1, pt = -1|
		if (nearest != ~previous[layerId]) {
			if (nearest.class != Array) {
				pt = nearest.asInteger;
				~play_slice.(
					id: layerId,
					index: pt,
					src: ~data[layerId][\source],
					indices: ~data[layerId][\indices],
					duration: dur.linexp(0.0, 1.0, 0.25, 2.0),
					alpha: dur.linexp(0.0, 1.0, 0.1, 0.5),
					amp: 0.75,
					bus: ~lfoBuses[layerId - 1]
				);
			};
			NetAddr("127.0.0.1", 7400).sendMsg("/highlight", layerId, pt, clust);
			~previous[layerId] = nearest;
		}
	});
};
)
