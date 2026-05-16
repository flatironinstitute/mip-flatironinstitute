function test_bundled_packages
  bundled_dir = fullfile('build', 'bundled');
  files = dir(fullfile(bundled_dir, '*.mhl'));
  if isempty(files)
    error('test_bundled_packages: no .mhl files found in %s', bundled_dir);
  end
  fprintf('Found %d .mhl file(s) to test\n', numel(files));
  for k = 1:numel(files)
    mhl_path = fullfile(files(k).folder, files(k).name);
    mip_json_path = [mhl_path '.mip.json'];
    info = jsondecode(fileread(mip_json_path));
    pkg_name = info.name;
    marker = sprintf('%s/.skip_test_%s', info.name, info.architecture);
    [status, ~] = system(sprintf( ...
        'tar -tzf "%s" 2>/dev/null | grep -qx "%s"', mhl_path, marker));
    if status == 0
      fprintf('\n=== SKIPPING %s (.skip_test_%s present) ===\n', ...
              files(k).name, info.architecture);
      continue;
    end
    fprintf('\n=== Testing %s (package: %s) ===\n', files(k).name, pkg_name);
    mip('install', mhl_path);
    mip('load', pkg_name);
    mip('test', pkg_name);
    mip('uninstall', pkg_name);
    fprintf('OK: %s\n', pkg_name);
  end
  fprintf('\nAll %d package(s) passed\n', numel(files));
end
