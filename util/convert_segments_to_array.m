function traces_array = convert_segments_to_array(traces_segments)
    
    traces_array = cell(1,length(traces_segments));

    for i=1:length(traces_segments)
        traces_array{i} = single(cell2mat(traces_segments{i}'));
    end
end