function writesdpagmp(mod,filename,header)

%
% Export YALMIP problem to SDPA. Inputs: 
%
%       mod:      the model obtained from YALMIP's function "export"
%       filename: the name of the file to write
%       header:   a string to add to the beginnning of the SDPA file, for
%                 description


FF = cellfun(@full,mod.F,'UniformOutput',false);
[nmax,mmax] = size(FF);
BS = abs(mod.bLOCKsTRUCT);
for nn=1:nmax               % loop to construc SDPA problem
    for mm=1:mmax
        if isempty(FF{nn,mm})
            FF{nn,mm} = zeros(BS(nn));
        end
    end
end 
gensdpagmpfile(filename,mod.mDIM,mod.nBLOCK,mod.bLOCKsTRUCT,mod.c,FF,header);