function copy_and_sanitize_lib(sourceLib, destDir)

persistent copy_and_sanitize_lib_

if isempty(copy_and_sanitize_lib_)
    switch computer('arch')
        case 'glnxa64'
            copy_and_sanitize_lib_ = @copy_and_sanitize_lib_linux;
        case {'maca64', 'maci64'}
            copy_and_sanitize_lib_ = @copy_and_sanitize_lib_macos;
        case 'win64'
            error('Windows is not yet supported.');
        otherwise
            error('Unsupported architecture.');
    end
end

copy_and_sanitize_lib_(sourceLib, destDir);

end

function copy_and_sanitize_lib_linux(sourceLib, destDir)

    cmd = sprintf('cp -Lf %s %s\n', sourceLib, destDir);
    run_and_log(cmd);

    [~, lib_name, lib_ext] = fileparts(sourceLib);
    lib = [lib_name lib_ext];
    local_lib = fullfile(destDir, lib);

    cmd = sprintf('patchelf --set-soname %s          %s', lib, local_lib);
    run_and_log(cmd);

    cmd = sprintf('patchelf --set-rpath ''$$ORIGIN'' %s', local_lib);
    run_and_log(cmd);
end

function copy_and_sanitize_lib_macos(sourceLib, destDir)

    cmd = sprintf('cp -Lf %s %s', sourceLib, destDir);
    run_and_log(cmd);

    [~, lib_name, lib_ext] = fileparts(sourceLib);
    lib = [lib_name lib_ext];
    local_lib = fullfile(destDir, lib);

    cmd = sprintf('install_name_tool -id @rpath/%s %s', lib, local_lib);
    run_and_log(cmd);

    cmd = sprintf('install_name_tool -add_rpath @loader_path %s', local_lib);
    run_and_log(cmd);

end
