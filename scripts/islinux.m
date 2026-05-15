function flag = islinux()

flag = isunix() && ~ismac();

end
