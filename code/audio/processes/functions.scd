(
~initializeData = { |numLayers|
	~variants = (
		1: ['a', 'b', 'c'],
		2: ['a'],
		3: ['a'],
		4: ['a'],
	);

	~variant = (
		1: \a,
		2: \a,
		3: \a,
		4: \a,
	);

	~data = Dictionary.new;
	numLayers.do { |i|
		var layerId = i + 1;
		~data[layerId] = Dictionary.new;
		~variants[layerId].do{ |item, j|
			~data[layerId][item.asSymbol] = Dictionary.newFrom([
				\source, Buffer.read(s, ~dataPath ++ "buffers/audio/%/src_%\%.wav".format(layerId, layerId, item)),
				\indices, Buffer.read(s, ~dataPath ++ "buffers/indices/%/idc_%\%.wav".format(layerId, layerId, item)),
				\umap, FluidDataSet.new(s).read(~dataPath ++ "json/%/umap_norm_%\%.json".format(layerId, layerId, item)),
				\labels, FluidLabelSet.new(s).read(~dataPath ++ "json/%/labels_%\%.json".format(layerId, layerId, item)),
				\tree, FluidKDTree.new(s, 1, 0.03).read(~dataPath ++ "json/%/kd_tree_%\%.json".format(layerId, layerId, item)),
			]);
		};
	};
};

~setupBuses = { |numLayers|
	~lfoBuses = Array.fill(numLayers, { Bus.audio(s, 2) });
	numLayers.do { |i|
		var layerId = i + 1;
		~synths[layerId] = Dictionary.new;

		~synths[layerId][\lfo] = Synth(\lfo, [
			\layerId, layerId,
			\minRange, 0.0,
			\maxRange, 0.8,
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
	var variant = ~variant[layerId];
	~data[layerId][variant][\labels].getLabel(nearest.asInteger, { |clust = -1, pt = -1|
		if (nearest != ~previous[layerId]) {
			if (nearest.class != Array) {
				pt = nearest.asInteger;
				~play_slice.(
					id: layerId,
					index: pt,
					src: ~data[layerId][variant][\source],
					indices: ~data[layerId][variant][\indices],
					duration: dur.linexp(0.0, 1.0, 0.25, 2.0),
					alpha: dur.linexp(0.001, 1.0, 0.1, 0.5),
					amp: 0.75,
					bus: ~lfoBuses[layerId - 1]
				);
			};
			// [layerId, variant, pt, clust].postln;
			NetAddr("127.0.0.1", 7400).sendMsg("/highlight", layerId, pt, clust.asInteger);
			~previous[layerId] = nearest;
		}
	});
};
)
