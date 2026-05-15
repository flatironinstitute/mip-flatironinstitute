function [status, cmdout] = run_and_log(cmd)

fprintf('  \033[32m%s\033[0m\n', cmd);
[status, cmdout] = system(cmd);
if ~isempty(cmdout)
    lines = splitlines(cmdout);
    fprintf('    %s\n', lines{1:end-1});
end

end
