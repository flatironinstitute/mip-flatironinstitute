function test_bundled_packages
  bundled_dir = fullfile('build', 'bundled');
  files = dir(fullfile(bundled_dir, '*.mhl'));
  if isempty(files)
    error('test_bundled_packages: no .mhl files found in %s', bundled_dir);
  end
  fprintf('Found %d .mhl file(s) to test\n', numel(files));
  runtime_arch = current_architecture();
  for k = 1:numel(files)
    mhl_path = fullfile(files(k).folder, files(k).name);
    mip_json_path = [mhl_path '.mip.json'];
    info = jsondecode(fileread(mip_json_path));
    pkg_name = info.name;
    if package_skips_arch(mhl_path, info.name, runtime_arch)
      fprintf('\n=== SKIPPING %s (.skip_test lists %s) ===\n', ...
              files(k).name, runtime_arch);
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

function arch = current_architecture()
  switch computer('arch')
    case 'maca64',  arch = 'macos_arm64';
    case 'maci64',  arch = 'macos_x86_64';
    case 'glnxa64', arch = 'linux_x86_64';
    case 'win64',   arch = 'windows_x86_64';
    otherwise,      arch = computer('arch');
  end
end

function tf = package_skips_arch(mhl_path, pkg_short_name, arch)
% Returns true if the .mhl contains <pkg_short_name>/.skip_test and that
% file lists `arch` (one arch per line; '#' comments and blank lines ignored).
  tf = false;
  marker = sprintf('%s/.skip_test', pkg_short_name);
  [status, contents] = system(sprintf( ...
      'tar -xOzf "%s" "%s" 2>/dev/null', mhl_path, marker));
  if status ~= 0
    return;
  end
  for line = splitlines(contents)'
    s = strtrim(line{1});
    if isempty(s) || startsWith(s, '#'), continue; end
    if strcmp(s, arch), tf = true; return; end
  end
end
