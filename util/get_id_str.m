function s = get_id_str(val, num)
    %convert a number to string with size num
    s = repmat('0', [1, num]);
    n = num2str(val);
    
    s(end-length(n)+1:end)=n;
end