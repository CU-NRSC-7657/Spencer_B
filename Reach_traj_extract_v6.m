% ATTENTION: in order to run this code you need to download two functions:
% interparc and arclength. Both can be found in GitHub and should be added
% to the path

% This code assumes that your matlab 3D filse are in the same folder as
% your curator folder. If that is not the case, just add the matlab 3D
% folder to the path here at the top of the code

% Add the path to your curator folder
addpath(genpath('C:\Users\sgkb1\Documents\Matlab Course\CLARA_Vectors'));

% This makes a list of all animals with curated data
Curator_dir=dir(fullfile('C:','\Users\sgkb1\Documents\Matlab Course\CLARA_Vectors\Curators'));
Curator_list=table();
for i=1:length(Curator_dir)
    temp_dir=Curator_dir(i);
    if temp_dir.isdir==1
        Curator_list=[Curator_list;{temp_dir.name}];
    else
        continue
    end
end
%% Reach extraction and dynamic time warping

% This loop is designed to make a master list of all reaches by all mice,
% which can then be indexed into smaller lists of mice afterwards
tic
a=1
temp=double.empty;
velint=double.empty;
absvel=double.empty;
tempeuc=double.empty;
master_list=table.empty;
for k=[3:height(Curator_list)] % This starts at 3 because their are 2 folders ("." and "..") that need to be skipped
    % change this next line to the full file path to your curators fodler
    Mouse_dir=dir(fullfile('C:','\Users\sgkb1\Documents\Matlab Course\CLARA_Vectors\Curators',char(Curator_list{k,1})));
    master_list.mouseName{a}=char(Curator_list{k,1}); % this writes the name of each mouse in the list
    reach_mouse_list=table.empty;
    b=1
    days=size(Mouse_dir);
    % This section populates a table for each mouse with all of its
    % reaching days
    for j=3:days(1) % starts at 3 for the same reason as above
        if endsWith(Mouse_dir(j).name,'.xlsx')==1 % in case you have other notes in the folder
            reaches=readtable(Mouse_dir(j).name); % opens an individiual curation sheet
            tempfname=char(Mouse_dir(j).name); % Extracts the date_unit_session tag for the day
            tempfname=tempfname(1:26);
            % add some metadata, Date, training day etc.
            reach_mouse_list.Date{b}=tempfname(1:8);
            reach_mouse_list.Day{b}=b;
            reach_mouse_list.filename{b}=tempfname;
            reach_mouse_list.performance{b}=(sum(strcmp(reaches.behaviors,'success'))/height(reaches))*100;
            
            load(char([tempfname '_3D.mat'])); % this opens the MATAB_3D file, make sure you have added its location to the path
            reach_mouse_list.cropPointsTop{b}=table3D.cropPts{1,1}; % These are the crop points for the day's video
            
            % matlab functions don't like unit16 data so this changes it to
            % double
            for g=1:10
                table3D{1,g}{:,:}=double(table3D{1,g}{:,:});
            end
            
            % This adds all of the columns we will be taking from the
            % tracking data to the curator spreadsheet
            reaches.HandX=cell.empty(height(reaches),0);
            reaches.HandY=cell.empty(height(reaches),0);
            reaches.HandZ=cell.empty(height(reaches),0);
            reaches.sideHandP=cell.empty(height(reaches),0);
            reaches.frontHandP=cell.empty(height(reaches),0);
            
            reaches.PelletX=cell.empty(height(reaches),0);
            reaches.PelletY=cell.empty(height(reaches),0);
            reaches.PelletZ=cell.empty(height(reaches),0);
            reaches.sidePelletP=cell.empty(height(reaches),0);
            reaches.frontPelletP=cell.empty(height(reaches),0);
            
            % This loop populates each reach (row) with the tracking data
            % that occurrd between reachInit and reachMax. To change to
            % reachEnd, replace 'reaches{i,2}' with 'reaches{i,3}' for all
            % lines in the loop
            for i=1:height(reaches)
                reaches.HandX{i}=table3D.handX_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.HandY{i}=table3D.handY_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.HandZ{i}=table3D.handZ_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.sideHandP{i}=table3D.handConfXY_10k{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.frontHandP{i}=table3D.handConfZ_10k{1,1}(reaches{i,1}:reaches{i,2})';
                
                reaches.PelletX{i}=table3D.pelletX_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.PelletY{i}=table3D.pelletY_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.PelletZ{i}=table3D.pelletZ_100{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.PelletEuc{i}=[reaches.PelletX{i} reaches.PelletY{i} reaches.PelletZ{i}];
                reaches.sidePelletP{i}=table3D.pelletConfXY_10k{1,1}(reaches{i,1}:reaches{i,2})';
                reaches.frontPelletP{i}=table3D.pelletConfZ_10k{1,1}(reaches{i,1}:reaches{i,2})';
            end

            % This section creates collumns of interpolated data, it may be
            % redundant now that I have added the DTW section below, but I
            % have kept if for now in case I am wrong
            reaches.IntHandX=cell.empty(height(reaches),0);
            reaches.IntHandY=cell.empty(height(reaches),0);
            reaches.IntHandZ=cell.empty(height(reaches),0);
            reaches.IntHandEuc=cell.empty(height(reaches),0);
            % I run a very minimal smoothing function to the raw data to
            % try to eliminate single frame jumps in the tracking before I
            % make any other changes to the data
            for i=1:height(reaches)
                reaches.IntHandX{i}=smoothdata(reaches.HandX{i}, 'movmedian',3);
                reaches.IntHandY{i}=smoothdata(reaches.HandY{i}, 'movmedian',3);
                reaches.IntHandZ{i}=smoothdata(reaches.HandZ{i}, 'movmedian',5);                
            end
            
            for i=1:height(reaches)                
                li=1:length(reaches.HandX{i});
                temp=(length(li)-1)/100;
                lf=1:temp:length(li);
                reaches.IntHandX{i}=interp1(li,reaches.IntHandX{i},lf,'pchip')';
                reaches.IntHandY{i}=interp1(li,reaches.IntHandY{i},lf,'pchip')';
                reaches.IntHandZ{i}=interp1(li,reaches.IntHandZ{i},lf,'pchip')';

                reaches.IntHandEuc{i}=[reaches.IntHandX{i} reaches.IntHandY{i} reaches.IntHandZ{i}];
            end
            
            
            
            % This section adds columns of time warped data, as well as the
            % trajectory in euclidian coordinates, and the total length of
            % each trajectory
            
            % NOTE: This form of warping finds the total length of each
            % reach, then splits it into n number of sections of equal
            % length
            reaches.DTWHandX=cell.empty(height(reaches),0);
            reaches.DTWHandY=cell.empty(height(reaches),0);
            reaches.DTWHandZ=cell.empty(height(reaches),0);
            reaches.DTWHandEuc=cell.empty(height(reaches),0);
            reaches.HandArcLen=cell.empty(height(reaches),0);
            for i=1:height(reaches)
                reaches.DTWHandX{i}=smoothdata(reaches.HandX{i}, 'movmedian',3);
                reaches.DTWHandY{i}=smoothdata(reaches.HandY{i}, 'movmedian',3);
                reaches.DTWHandZ{i}=smoothdata(reaches.HandZ{i}, 'movmedian',5);
                % This try loop exists because the warping function does
                % not work if there are multiple frames where the tracking
                % point did not move. This usually only happens on very
                % long reaches (>50 frames)
                try
                    [pt,dudt,fofthandle] = interparc(0:0.01:1,reaches.DTWHandX{i},reaches.DTWHandY{i},reaches.DTWHandZ{i});
                catch
                    B =(diff(reaches.DTWHandX{i})~=0 & diff(reaches.DTWHandY{i})~=0 & diff(reaches.DTWHandZ{i})~=0);
                    reaches.DTWHandX{i}=reaches.DTWHandX{i}(B);
                    reaches.DTWHandY{i}=reaches.DTWHandY{i}(B);
                    reaches.DTWHandZ{i}=reaches.DTWHandZ{i}(B);
                    [pt,dudt,fofthandle] = interparc(0:0.01:1,reaches.DTWHandX{i},reaches.DTWHandY{i},reaches.DTWHandZ{i});
                end
                % pt is the variable with the new warped points, each
                % column is a dimension (x,y,z)
                reaches.DTWHandX{i}=pt(:,1);
                reaches.DTWHandY{i}=pt(:,2);
                reaches.DTWHandZ{i}=pt(:,3);
                reaches.DTWHandEuc{i}=pt;
                
                % You can calculate the total trajectory length from the
                % raw trajectory or the warped one. On well tracked reaches
                % it changes the length by less than a few pixels.
                reaches.HandArcLen{i}=arclength(pt(:,1), pt(:,2), pt(:,3),'spline');
                %reaches.HandArcLen=arclength(reaches.HandX{4},reaches.HandY{4},reaches.HandZ{4},'spline');                
            end
            
            % This section normalizes all reaches, so that the pellet is at
            % 0,0,0. This is done by session, not by reach, under the
            % assumption that the cameras do not move during sessions
            temp=double.empty;
            c=1;
            for i=1:height(reaches)
                % This keeps badly tracked pellets from affecting the data
                if mean(reaches.sidePelletP{i}(1:3))<9000 || mean(reaches.frontPelletP{i}(1:3))<9000
                    continue
                else
                    temp(c,:)=mean(reaches.PelletEuc{i}(1:3,:));
                    c=c+1;
                end
            end
            reaches.DTWHandNorm=cell.empty(height(reaches),0);
            for i=1:height(reaches)
                reaches.DTWHandNorm{i}=reaches.DTWHandEuc{i}-median(temp);
            end
            
            % This adds velocity data
            reaches.VelRaw=cell.empty(height(reaches),0);
            reaches.VelInt=cell.empty(height(reaches),0);
            reaches.AbsVel=cell.empty(height(reaches),0);
            for i=1:height(reaches)
                velint=[];
                absvel=[];
                tempeuc=[reaches.HandX{i} reaches.HandY{i} reaches.HandZ{i}];
                for m=1:size(tempeuc,1)-1
                    absvel(m,1)=norm(tempeuc(m+1,:)-tempeuc(m,:));
                    velint(m,:)=tempeuc(m+1,:)-tempeuc(m,:);
                end
                velint(:,2)=velint(:,2)*-1;
                reaches.VelRaw{i}=velint;
                
                li=1:size(velint,1);
                temp=(length(li)-1)/99;
                lf=1:temp:length(li);
            
                velint=interp1(li,velint,lf,'pchip');
                absvel=interp1(li,absvel,lf,'pchip')';
                
                reaches.VelInt{i}=velint;
                reaches.AbsVel{i}=absvel;
            end
            % This adds the expanded curator spreadsheet to the correct day
            % in the table for each mouse
            reaches=removevars(reaches,{'IntHandX', 'IntHandY', 'IntHandZ', 'DTWHandX', 'DTWHandY', 'DTWHandZ'});
            reach_mouse_list.reaches{b}=reaches;
            b=b+1
            
        else
            continue
        end
        clear table3D
    end
    % this adds each mouse's complete training table to the master list
    master_list.allDays{a}=reach_mouse_list;
    a=a+1
end
toc
% This gets rid of incomplete datasets %
% for i=1:size(master_list,1)
%     if height(master_list{i,2})<7
%         master_list(i,:)=[];
%     else
%         continue
%     end
% end

% This adds cohorts to the master list.%
% You need to make an excel sheetwith 2 columns: name and cohort, and fill
%them in with a mouseID and experiment group. 
cohorts=readtable('Cohort_list.xlsx'); %replace with the name of your cohort excel sheet
master_list.cohort=cell.empty(height(master_list),0);
for i=1:height(cohorts)
    temp=find(strcmp(cohorts.name{i},master_list.mouseName));
    if isempty(temp)==1
        continue
    else
        master_list.cohort{temp}=cohorts.cohort{i};
    end
end

cohort=find(strcmp('VNS',master_list.cohort))';
