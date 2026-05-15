function libext = dynamic_library_ext()

persistent libext_

if isempty(libext_)
    switch computer('arch')
        case 'glnxa64'
            libext_ = 'so';
        case {'maca64', 'maci64'}
            libext_ = 'dylib';
        case 'win64'
            libext_ = 'dll';
        otherwise
            libext_ = 'so';
    end
end

libext = libext_;

end
