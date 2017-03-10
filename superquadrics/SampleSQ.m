function [scale, shape] = SampleSQ(  )
    %from 2 to 20 cm
    scale = randsample(10,3)'/500;
    %all SQ spectrum
    shape = randsample(10,2)'/10;
end

