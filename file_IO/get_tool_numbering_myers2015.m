function tool_numbering = get_tool_numbering_myers2015(ix)
    n_1s = floor(log10(ix))+1;
    n_0s = 8 - n_1s;
    tool_numbering = '';
    for i=1:n_0s
        tool_numbering = [tool_numbering '0'];
    end
    tool_numbering = [tool_numbering num2str(ix)];
end