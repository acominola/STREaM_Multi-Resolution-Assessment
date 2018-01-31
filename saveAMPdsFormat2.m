function success = saveAMPdsFormat2(HSIDinput, TS, targetRes, appNames, appNamesToSave, cr, housePos)
% Creating variables to save with header
folderName = sprintf('HSIDdata_%d_%d',targetRes, housePos);
mkdir(folderName);
cd(folderName);

for j=1:length(appNames)
    
    % Preparing input for saving
    currApp = appNames{j,1}; % current appliance
    disp(currApp);
    currAppToSave = appNamesToSave{1,j}; % AMPds acronym for saving file
    disp(currAppToSave);
    temp=HSIDinput.(currApp);
    %toSave.(currAppToSave)={'TS','P'; TS,temp};
    
    % Saving in AMPds format
    fileName=[currAppToSave '.csv'];
    %fid = fopen(fileName, 'w') ;
    %fprintf(fid, '%s,', toSave.(currAppToSave){1,1:end-1}) ;
    %fprintf(fid, '%s\n', toSave.(currAppToSave){1,end}) ;
    %fclose(fid) ;
    %dlmwrite(fileName, toSave.(currAppToSave)(2:end,:), '-append', 'precision', '%.0f') ;
    
    
    dataToWrite = table(  TS,temp,...
        'VariableNames',{'TS','P'});    
    writetable(dataToWrite,fileName);
    
    % Saving signatures
    if j==1
        signatureFolder = 'signatures';
        mkdir(signatureFolder);
    end
    cd(signatureFolder);
    
    cBound=round(length(temp)*cr);
    signatures.(currAppToSave)=temp(1:cBound);
    tempSig =signatures.(currAppToSave);
    
    name=[currAppToSave '_sig.txt'];
    save (name ,'-ascii','tempSig')
    cd ..
end
cd ..
success(2)=1;
end
