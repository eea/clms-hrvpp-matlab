function generatemainseason(fl,vppname,vppnodata,vppid,vppfolder,outfolder)
    % Description
    % Input variables:
    % fl: cell{13,2} containing all full path of vpp tif files, 13 vpp
    %     parameters and 2 seasons.
    % vppname: {'SOSD','EOSD','MAXD','SOSV','EOSV','MINV','MAXV','AMPL','LENGTH','LSLOPE','RSLOPE','SPROD','TPROD','QFLAG'};
    % vppnodata: no data value in vpp tif file
    % vppid: the id of vpp to identify main season, i.e.,        
    %       1:'SOSD',2:'EOSD',3:'MAXD',4:'SOSV',5:'EOSV',6:'MINV',7:'MAXV',
    %       8:'AMPL',9:'LENGTH',10:'LSLOPE',11:'RSLOPE',12:'SPROD',
    %       13:'TPROD',14:'QFLAG'};
    %       The MSI app uses maximum value of 13 (TPROD) to identify main season
    % vppfolder: full path of folder contains all vpp tif files.
    % outfolder: full path of output folder.
    %% generate dominent season id (S1 or S2)
    
    % import s1 TPROD
    s1 = double(imread(fullfile(vppfolder,fl{vppid,1}))); % read s1 TPROD (double)
    s1(s1==vppnodata(vppid))=nan; % set nan value
    
    % import s2 TPROD
    s2 = double(imread(fullfile(vppfolder,fl{vppid,2}))); % read s2 TPROD (double)
    s2(s2==vppnodata(vppid))=nan; % set nan value
    
    % combine s1 and s2 to a 3d matrix
    s1_s2 = cat(3,s1,s2);
    
    % determine where the max TPROD is, <dsid> represent the dominant season
    [~,dsid] = max(s1_s2,[],3);
    
    %% generate dominent seasons
    for i = 1:length(vppname)
        % import s1
        vppfile = fullfile(vppfolder,fl{i,1});
        if ~isfile(vppfile)
            continue
        end
        [vpp_s1,~] = readgeoraster(vppfile); % 
    
        % import s2
        vppfile = fullfile(vppfolder,fl{i,2});
        if ~isfile(vppfile)
            continue
        end
        [vpp_s2,R] = readgeoraster(vppfile); % 
        info = geotiffinfo(vppfile);
    
        % create vpp_dominant
        vpp_dominant = vpp_s1;
        % replace values if the dominant season is s2 (dsid == 2)
        vpp_dominant(dsid==2) = vpp_s2(dsid==2);
    
        % generate new output
        ouputfile = strrep(fl{i,1},'_s1_','_main_');
        % write the dominant to tiff
        geotiffwrite(fullfile(outfolder,ouputfile),vpp_dominant,R,...
            'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    end
end