%% Extract Kinematics
% This function creates a data structure (best format TBD) that has
% kinematic data for each reach from every mouse in your curator folder,
% organized by mouse name.

function theBIGdf=reach_extract(Curator_folder_path, Synology_pose_tracking_path)

% MAKE THIS A CATCH TO SEE IF THE REQUIRED FUNCTIONS ARE INSTALLED
if exist('interparc')==0 || exist('arclength')==0
    sprintf('You are missing functions! Please install interparc and arclength from the Add-on installer');
    return
end

% Adds the path of the two folders needed for kinematics
addpath(Curator_folder_path, Synology_pose_tracking_path);
% Creates a list of all curated mice in foloder
Curator_dir=struct2table(dir(Curator_folder_path));
Curator_list=Curator_dir.name(Curator_dir.isdir==1 & ismember(Curator_dir.name, {'.', '..'})==0 );
% Creates a table with space to add each training session
% CHECK IF THIS CAN BE REPLACED (ALSO AT END OF FUNCTION)
Full_list=table(Curator_list,cell(size(Curator_list,1),1),'VariableNames', {'mouseName', 'sessions'});

tic
it=0
theBIGdf=table.empty;
% iterate through each mouse in list
for i=1:height(Full_list)
    % get list of CSV files
    Mouse_dir=struct2table(dir(fullfile(char(Curator_folder_path),Full_list.mouseName{i})));
    Session_dir=Mouse_dir.name(endsWith(Mouse_dir.name,'.xlsx')==1);
        
    % iterate through each session for a mouse
    for k=1:size(Session_dir,1)
        % Read in the curator CSV
        sessionReaches=readtable(fullfile(Curator_folder_path, Full_list.mouseName{i}, Session_dir{k}));
        % allocate new columns (IS THERE A CLEANER WAY TO DO THIS?)
        sessionReaches=[sessionReaches, (cell2table(cell(height(sessionReaches),13), 'VariableNames',...
            {'handX','handY','handZ','handSideConf','handFrontConf',...
            'pelletX','pelletY','pelletZ','pelletSideConf','pelletFrontConf',...
            'velRaw', 'velInt', 'velAbs'}))];
        
        % Read the session pose tracking data
        load(fullfile(Synology_pose_tracking_path, [Session_dir{k}(1:26) '_3D.mat']));
        % matlab functions don't like unit16 data so this changes it to
        % double
        for g=1:10
            table3D{1,g}{:,:}=double(table3D{1,g}{:,:});
        end
            
        % iterate through each reach in a session
        % OPTIONAL: MAKE THE FUNCTION GO TO EITHER REACHMAX OR REACHEND
        a=2;
        for m=1:height(sessionReaches)
            sessionReaches.handX{m}=table3D.handX_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.handY{m}=table3D.handY_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.handZ{m}=table3D.handZ_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.handSideConf{m}=table3D.handConfXY_10k{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.handFrontConf{m}=table3D.handConfZ_10k{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';

            sessionReaches.pelletX{m}=table3D.pelletX_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.pelletY{m}=table3D.pelletY_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.pelletZ{m}=table3D.pelletZ_100{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.pelletSideConf{m}=table3D.pelletConfXY_10k{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
            sessionReaches.pelletFrontConf{m}=table3D.pelletConfZ_10k{1,1}(sessionReaches{m,1}:sessionReaches{m,a})';
        end   
        % This adds velocity data
        for m=1:height(sessionReaches)
            tempeuc=[sessionReaches.handX{m} sessionReaches.handY{m} sessionReaches.handZ{m}];
            absvel=[];
            velint=[];
            for o=1:size(tempeuc,1)-1
                absvel(o,1)=norm(tempeuc(o+1,:)-tempeuc(o,:));
                velint(o,:)=tempeuc(o+1,:)-tempeuc(o,:);
            end
            velint(:,2)=velint(:,2)*-1;
            sessionReaches.velRaw{m}=velint;

            li=1:size(velint,1);
            temp=(length(li)-1)/99;
            lf=1:temp:length(li);

            sessionReaches.velInt{m}=interp1(li,velint,lf,'pchip');
            sessionReaches.velAbs{m}=interp1(li,absvel,lf,'pchip')';
        end
        
        
        
        % add interps and DTW next THIS COULD BE AN OPTION IN THE FUNCTION
        sessionReaches=[sessionReaches, (cell2table(cell(height(sessionReaches),9), 'VariableNames',...
            {'intHandX','intHandY','intHandZ','intHandEuc',...
            'DTWHandX','DTWHandY','DTWHandZ','DTWHandEuc','handArcLength'}))];

        sessionReaches.intHandX=cellfun(@(x)smoothdata(x, 'movmedian',3), sessionReaches.handX, 'UniformOutput',false);
        sessionReaches.intHandY=cellfun(@(x)smoothdata(x, 'movmedian',3), sessionReaches.handY, 'UniformOutput',false);
        sessionReaches.intHandZ=cellfun(@(x)smoothdata(x, 'movmedian',5), sessionReaches.handZ, 'UniformOutput',false);
        
        sessionReaches(:,24:26)=[sessionReaches.intHandX, sessionReaches.intHandY, sessionReaches.intHandZ]; 
        
        for m=1:height(sessionReaches)                
            li=1:length(sessionReaches.handX{m});
            temp=(length(li)-1)/100;
            lf=1:temp:length(li);
            sessionReaches.intHandX{m}=interp1(li,sessionReaches.intHandX{m},lf,'pchip')';
            sessionReaches.intHandY{m}=interp1(li,sessionReaches.intHandY{m},lf,'pchip')';
            sessionReaches.intHandZ{m}=interp1(li,sessionReaches.intHandZ{m},lf,'pchip')';

            sessionReaches.intHandEuc{m}=[sessionReaches.intHandX{m} sessionReaches.intHandY{m} sessionReaches.intHandZ{m}];
        end
        
        
        
        for m=1:height(sessionReaches)
            % This try loop exists because the warping function does
            % not work if there are multiple frames where the tracking
            % point did not move. This usually only happens on very
            % long reaches (>50 frames)
            try
                [pt,dudt,fofthandle] = interparc(0:0.01:1,...
                    sessionReaches.DTWHandX{m},sessionReaches.DTWHandY{m},sessionReaches.DTWHandZ{m});
            catch
                B =(diff(sessionReaches.DTWHandX{m})~=0 & diff(sessionReaches.DTWHandY{m})~=0 & diff(sessionReaches.DTWHandZ{m})~=0);
                sessionReaches.DTWHandX{m}=sessionReaches.DTWHandX{m}(B);
                sessionReaches.DTWHandY{m}=sessionReaches.DTWHandY{m}(B);
                sessionReaches.DTWHandZ{m}=sessionReaches.DTWHandZ{m}(B);
                [pt,dudt,fofthandle] = interparc(0:0.01:1,...
                    sessionReaches.DTWHandX{m},sessionReaches.DTWHandY{m},sessionReaches.DTWHandZ{m});
            end
            % pt is the variable with the new warped points, each
            % column is a dimension (x,y,z)
            sessionReaches.DTWHandX{m}=pt(:,1);
            sessionReaches.DTWHandY{m}=pt(:,2);
            sessionReaches.DTWHandZ{m}=pt(:,3);
            sessionReaches.DTWHandEuc{m}=pt;

            % You can calculate the total trajectory length from the
            % raw trajectory or the warped one. On well tracked reaches
            % it changes the length by less than a few pixels.
            sessionReaches.handArcLength{m}=arclength(pt(:,1), pt(:,2), pt(:,3),'spline');
        end
        
        % This section normalizes all reaches, so that the pellet is at
        % 0,0,0. This is done by session, not by reach, under the
        % assumption that the cameras do not move during sessions
        temp=double.empty;
        c=1;
        for m=1:height(sessionReaches)
            % This keeps badly tracked pellets from affecting the data
            if mean(sessionReaches.pelletSideConf{m}(1:3))<9000 || mean(sessionReaches.pelletFrontConf{m}(1:3))<9000
                continue
            else
                temp(c,:)=mean([sessionReaches.pelletX{m}(:),sessionReaches.pelletY{m}(:),sessionReaches.pelletY{m}(:)]);
                c=c+1;
            end
        end
        sessionReaches.DTWHandNorm=cell.empty(height(sessionReaches),0);
        for m=1:height(sessionReaches)
            sessionReaches.DTWHandNorm{m}=sessionReaches.DTWHandEuc{m}-median(temp);
        end

        
        
        % pull any uneeded columns, Is it worth making  this an option in
        % the funciton?
        sessionReaches=removevars(sessionReaches,{'intHandX', 'intHandY', 'intHandZ', 'DTWHandX', 'DTWHandY', 'DTWHandZ'});
        
        % adds session level data to the dataframe
        Session_data=table('Size', [height(sessionReaches) 5], 'VariableTypes', {'string','string','string','double', 'double'},...
         'VariableNames', {'MouseID','filename', 'date', 'day', 'performance'});    
        tempRow={Full_list.mouseName{i}, Session_dir{k}(1:26), Session_dir{k}(1:8), k,...
            (sum(strcmp(sessionReaches.behaviors,'success'))/height(sessionReaches))*100};
        
        tempRow=repmat(tempRow, height(sessionReaches),1);
        Session_data(:,:)=tempRow;  
        sessionReaches=[Session_data sessionReaches];
        it=it+1
        theBIGdf=[theBIGdf; sessionReaches];
    
    end
    
end
toc    
end