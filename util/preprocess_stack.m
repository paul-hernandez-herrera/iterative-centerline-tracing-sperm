function stack = preprocess_stack(stack)
    %function to increase contrast of structures
    stack = single(stack);

    stack(:) = normalizeVol(stack, 1, 255);
    stack = log(stack);

end