function [varargout] = callExpand(fun, x, hasin, nout)
    % Calls the specific function, expanding the vector x into a
    % comma-separated list of arguments
    xcell = num2cell(x);
    varargout = cell(nout, 1);
    if hasin
        [varargout{:}] = fun(xcell{:});
    else
        [varargout{:}] = fun();
    end
end