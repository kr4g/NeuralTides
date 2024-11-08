(
~nLayers = 4;

/*~variants = (
	1: ['a', 'b', 'c'],
	2: ['a'],
	3: ['a'],
	4: ['a'],
);*/

~variant = (
	1: \a,
	2: \a,
	3: \a,
	4: \a,
);

~thresh = 0.001;
~belowThresh = Dictionary.new;
~nLayers.do{ |i| ~belowThresh[i + 1] = False };

~point = Buffer.alloc(s, 2);
~previous = Dictionary.new;

~nLayers.do{ |i| ~previous[i + 1] = nil };

~synths = Dictionary.new;

~synthQueue = Dictionary.new;
~nLayers.do{ |i| ~synthQueue[i + 1] = [] };
)
