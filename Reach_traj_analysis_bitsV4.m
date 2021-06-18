%% Analysis snipits for master_list

% Add the path to your curator folder
addpath(genpath('C:\Users\sgkb1\Documents\Matlab Course\CLARA_Vectors'));
% Be sure to load the most recent master_list before running any snipits
load most_recent_master_list_full_reach.mat

% NOTE:always update exp_group and days for each snipit


%% INDEX LOOPS 
%% Bad reches: Reaches to short to use (less than 5 frames)
temp=[];
for i=1:height(master_list)
    for j=1:height(master_list.allDays{i})
        temp=[];
        for k=1:height(master_list.allDays{i}.reaches{j})
            temp(k,1)=length(master_list.allDays{i}.reaches{j}.HandX{k})>5;
        end
        master_list.allDays{i}.reaches{j}=master_list.allDays{i}.reaches{j}(logical(temp),:);
    end
end
%% Bad reches: Velocity impossibly high
temp=[];
for i=1:height(master_list)
    for j=1:height(master_list.allDays{i})
        temp=[];
        for k=1:height(master_list.allDays{i}.reaches{j})
            temp(k,1)=sum(max(master_list.allDays{i}.reaches{j}.VelInt{k})>2950)<1;
        end
        master_list.allDays{i}.reaches{j}=master_list.allDays{i}.reaches{j}(logical(temp),:);
    end
end            
temp=[];
for i=1:height(master_list)
    for j=1:height(master_list.allDays{i})
        temp=[];
        for k=1:height(master_list.allDays{i}.reaches{j})
            temp(k,1)=max(master_list.allDays{i}.reaches{j}.AbsVel{k})<3000;
        end
        master_list.allDays{i}.reaches{j}=master_list.allDays{i}.reaches{j}(logical(temp),:);
    end
end     
%% Get rid of unwanted columns        
% for k=1:height(master_list)
%     for j=1:height(master_list.allDays{k})
%         master_list.allDays{k}.reaches{j}=removevars(master_list.allDays{k}.reaches{j},...
%             {'AbsVel','VelInt'});
% %             {'IntHandX', 'IntHandY', 'IntHandZ', 'DTWHandX', 'DTWHandY', 'DTWHandZ'});
%     end
% end

%% Simple reaches only

master_list_simpleR=master_list;
temp=double.empty;
for i=1:height(master_list_simpleR)
    for j=1:height(master_list_simpleR.allDays{i})
        temp=double.empty;
        for k=1:height(master_list_simpleR.allDays{i}.reaches{j})-1
            temp(k,1)=(master_list_simpleR.allDays{i}.reaches{j}.reachInit(k+1)...
                -master_list_simpleR.allDays{i}.reaches{j}.reachEnd(k))>50;
        end
        temp=[1;temp];
        master_list_simpleR.allDays{i}.reaches{j}=master_list_simpleR.allDays{i}.reaches{j}(logical(temp),:);
    end
end                

%% Success and failure
% This section makes a master list of all success and all failures. I will
% eventually add examples of how to index by other options (mouseID,
% experiment group, Unit number etc. in a later version.

master_list_success=master_list_simpleR;
for i=1:height(master_list_success)
    for j=1:height(master_list_success.allDays{i})
        master_list_success.allDays{i}.reaches{j}=...
            master_list_success.allDays{i}.reaches{j}(strcmp(master_list_success.allDays{i}.reaches{j}.behaviors,'success'),:);
    end
end

master_list_failure=master_list_simpleR;
for i=1:height(master_list_failure)
    for j=1:height(master_list_failure.allDays{i})
        master_list_failure.allDays{i}.reaches{j}=...
            master_list_failure.allDays{i}.reaches{j}(strcmp(master_list_failure.allDays{i}.reaches{j}.behaviors,'success')==0,:);
    end
end

master_list_failureR=master_list_simpleR;
for i=1:height(master_list_failureR)
    for j=1:height(master_list_failureR.allDays{i})
        master_list_failureR.allDays{i}.reaches{j}=...
            master_list_failureR.allDays{i}.reaches{j}(strcmp(master_list_failureR.allDays{i}.reaches{j}.behaviors,'fail_reach'),:);
    end
end

%% One experient group only

master_list_ExpGroup=master_list(strcmp('Arch_VNS',master_list.cohort),:);

%% VELOCITY (need to add to full reach_traj_extract loop)
% a=0;
% temp=double.empty;
% velint=double.empty;
% absvel=double.empty;
% tempeuc=double.empty;
% for k=1:height(master_list)
%     for j=1:height(master_list.allDays{k})
%         master_list.allDays{k}.reaches{j}.VelRaw=cell.empty(height(master_list.allDays{k}.reaches{j}),0);
%         master_list.allDays{k}.reaches{j}.AbsVel=cell.empty(height(master_list.allDays{k}.reaches{j}),0);
%         master_list.allDays{k}.reaches{j}.VelInt=cell.empty(height(master_list.allDays{k}.reaches{j}),0);
%         for m=1:height(master_list.allDays{k}.reaches{j})
%             velint=double.empty;
%             absvel=double.empty;
%             tempeuc=[master_list.allDays{k}.reaches{j}.HandX{m} master_list.allDays{k}.reaches{j}.HandY{m} master_list.allDays{k}.reaches{j}.HandZ{m}];
%             for i=1:size(tempeuc,1)-1
%                 absvel(i,1)=norm(tempeuc(i+1,:)-tempeuc(i,:));
%                 velint(i,:)=tempeuc(i+1,:)-tempeuc(i,:);
%             end     
%             velint(:,2)=velint(:,2)*-1;
%             master_list.allDays{k}.reaches{j}.VelRaw{m}=velint;
%             
% %             absvel=smoothdata(absvel, 'movmedian',3);
% %             velint=smoothdata(velint, 'movmedian',3);
%             
%             li=1:size(velint,1);
%             temp=(length(li)-1)/99;
%             lf=1:temp:length(li);
%             
%             velint=interp1(li,velint,lf,'pchip');
%             absvel=interp1(li,absvel,lf,'pchip')';
%             
%             master_list.allDays{k}.reaches{j}.AbsVel{m}=absvel;
%             master_list.allDays{k}.reaches{j}.VelInt{m}=velint;
%         end
%         a=a+1
%     end
% end


reaches.VelDTW=cell.empty(height(reaches),0);
for i=1:height(reaches)
    [pt,dudt,fofthandle] = interparc(0:0.01:1,reaches.VelRaw{i}(:,1),reaches.VelRaw{i}(:,2),reaches.VelRaw{i}(:,3));
    reaches.VelDTW{i}=pt;
end

temp=[];
for i=1:height(reaches)
    temp(i,1)=mean(reaches.VelRaw{i}(:,3));
    temp(i,2)=mean(reaches.VelDTW{i}(:,3));
    temp(i,3)=mean(reaches.VelInt{i}(:,3));
end
better=[(temp(:,2)-temp(:,1)) (temp(:,3)-temp(:,1))];
mean(better)


%% LOOPS FOR DATA ANALYSIS

%% Classification Latency
Latency=table.empty;
tempT=table.empty;
temp_hand_conf=[];
stimframe=[];
tempfname=[];
temploc=[];
for i=1:height(master_list_success)
    for j=1:height(master_list_success.allDays{i,1})
        tempfname=master_list_success.allDays{i,1}.filename{j,1};
        load(char([tempfname '_3D.mat']));
        for h=1:height(master_list_success.allDays{i,1}.reaches{j,1})
            if master_list_success.allDays{i,1}.reaches{j,1}.stim(h)~=0
                stimframe=master_list_success.allDays{i,1}.reaches{j,1}.stim(h);
                temp_hand_conf=table3D.handConfXY_10k{1,1}(1:stimframe);
                temploc=find(temp_hand_conf>9500,1,'last');
                tempT.Mouse=master_list_success.mouseName(i);
                tempT.Session=master_list_success.allDays{i,1}.filename(j);
                tempT.Bx_end=temploc;
                tempT.Bx_class=stimframe;
                tempT.Latency=stimframe-temploc;
                tempT.LatencyMs=tempT.Latency*6.6667;
                Latency=[Latency; tempT];
            else
                continue
            end
        end
    end
end
        


%% Mean Velocity
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

mean_vel=NaN(days,length(exp_group));
temp=double.empty;
a=1;
for k=exp_group%
    for m=1:days
        temp=double.empty;
        try
            for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
%                 temp(j,1)=nanmean(master_list.allDays{k}.reaches{m}.VelRaw{j}(:,3));
                temp(j,1)=nanmean(master_list_simpleR.allDays{k}.reaches{m}.AbsVel{j});
            end
            mean_vel(m,a)=nanmean(temp);
        end
    end
    a=a+1;
end

%% Max Velocity
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

max_vel=NaN(days,length(exp_group));
max_loc=NaN(days,length(exp_group));
% end_vel=NaN(days,length(exp_group));
temp=double.empty;
temp_also=double.empty;
temp_also_also=double.empty;
a=1;
for k=exp_group%
    for m=1:days
        temp=double.empty;
        temp_also=double.empty;
        try
            for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
%                 [temp(j,1), temp_also(j,1)]=max(master_list_success.allDays{k}.reaches{m}.AbsVel{j});
                temp_also_also(j,1)=max(master_list_simpleR.allDays{k}.reaches{m}.VelInt{j}(:,3));
            end
%             max_vel(m,a)=nanmean(temp);
%             max_loc(m,a)=nanmean(temp_also);
            max_vel(m,a)=nanmedian(temp_also_also);
%             temp_also_also=[temp_also_also; temp_also];

        end
    end
    a=a+1;
end


% figure(1)
% hold on
% histogram(max_loc_z,[0:4:100],'Normalization','probability','EdgeColor', 'none');
% histogram(max_loc_y,[0:4:100],'Normalization','probability','EdgeColor', 'none');
% histogram(max_loc_x,[0:4:100],'Normalization','probability','EdgeColor', 'none');
% ylim([0 0.30]);
% hold off

%% Path length by mouse
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

path_length=NaN(days,length(exp_group));
a=1;
for k=exp_group%
    for m=1:days
        try
            for j=1:height(master_list.allDays{k}.reaches{m})
                path_length(m,a)=nanmean(cell2mat(master_list.allDays{k}.reaches{m}.HandArcLen));
            end
        end
    end
    a=a+1;
end

%% Path length by cohort
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

path_length= NaN(days,length(exp_group));

%size(master_list_success)
a=1;
for j=exp_group
    
    for i=1:days    
        try
            path_length(i,a)=mean(cell2mat(master_list_success.allDays{j,1}.reaches{i}.HandArcLen));
        catch
            continue
        end
    end
    a=a+1;
end

% path_length_mean=cellfun(@mean,path_length);
% path_length_std=cellfun(@std,path_length);
% path_length_outlier=cellfun(@isoutlier, path_length,'UniformOutput', false);

%% Success percent
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

success=NaN(days,length(exp_group));
a=1;
for k=exp_group%
    try
        for m=1:days
            success(m,a)=master_list_simpleR.allDays{k}.performance{m};
        end
    end
    a=a+1;
end

%% number of successes
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

success=NaN(days,length(exp_group));
a=1;
for k=exp_group%
    try
        for m=1:days
            success(m,a)=height(master_list_success.allDays{k}.reaches{m});
        end
    
    end
    a=a+1;
end

%% Correlation within days
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

corrs=NaN(days,length(exp_group));
corrlist=double.empty;
tic
a=1
for k=exp_group%1:height(master_list_simpleR)%exp_group
    for m=1:days%1:height(master_list_simpleR.allDays{k})%days
        try
            corrlist=zeros(height(master_list_failure.allDays{k}.reaches{m}),height(master_list_failure.allDays{k}.reaches{m}));
            for j=1:height(master_list_failure.allDays{k}.reaches{m})
                reachcorr=double.empty;
                for i=1:height(master_list_failure.allDays{k}.reaches{m})
                    temp=corrcoef(master_list_failure.allDays{k}.reaches{m}.DTWHandNorm{j}(:,:),...
                        master_list_failure.allDays{k}.reaches{m}.DTWHandNorm{i}(:,:));
                    reachcorr=[reachcorr; temp(1,2)];
                end
                corrlist(:,j)=reachcorr;
            end
            corrlist(corrlist>=1)=NaN;
            %master_list_simpleR.allDays{k}.reaches{m}.WithinCorr=nanmean(corrlist, 2);
            corrs(m,a)=nanmean(nanmean(corrlist));
        end
    end
    a=a+1
end
toc


%% Correlation to ideal reach

% REMEMBER TO CHECK WHICH LIST YOU ARE PULLING THE CORRELATIONS FROM
% make ideal reach
exp_group=find(strcmp('VNS',master_list.cohort))';
days=8;
ideal_reach=cell(1,length(exp_group));
temp=double.empty;
temp2=double.empty;
a=1;
for k=19%exp_group%1:height(master_list_simpleR)%exp_group
    temp=double.empty;
    temp2=double.empty;
    try
        for m=(days-1):days%(height(master_list_success.allDays{k})-1):height(master_list_success.allDays{k})%m=(days-1):days%
            for j=1:height(master_list_success.allDays{k}.reaches{m})
                temp2(:,:,j)=master_list_success.allDays{k}.reaches{m}.DTWHandNorm{j};
            end
            temp=cat(3, temp, temp2);
        end
    end
    ideal_reach{1,a}=nanmean(temp,3);
    a=a+1;
end

% find correlation to ideal reach
corrs=NaN(days,length(exp_group));
ideal_reaches=NaN(days,length(exp_group));
temp=double.empty;
a=1;
b=0;
for k=exp_group%1:height(master_list_simpleR)%exp_group
    for m=1:days%height(master_list_simpleR.allDays{k})%days
        reachcorr=double.empty;
        b=0;
        try
            for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
                temp=corrcoef(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{j}(:,:), ideal_reach{1,a}(:,:));
                reachcorr=[reachcorr; temp(1,2)];
                if temp(1,2)>0.95
                    b=b+1;
                end
            end
            %master_list_simpleR.allDays{k}.reaches{m}.IdealCorr=reachcorr;
            corrs(m,a)=nanmean(reachcorr);
            ideal_reaches(m,a)=b/j;
        end
    end
    a=a+1;
end

% figure(1)
% hold on
% for i=1:length(exp_group)
%     plot(ideal_reach{1,i}(:,1),ideal_reach{1,i}(:,2))
% end
% set(gca, 'ydir', 'Reverse')
% hold off

%% Correlation to next reach

temp=double.empty;
a=1;

for k=1:height(master_list_simpleR)%exp_group
    for m=1:height(master_list_simpleR.allDays{k})%days
        reachcorr=NaN;
        master_list_simpleR.allDays{k}.reaches{m}.NextCorr(1)=NaN;
        try
            for j=2:height(master_list_simpleR.allDays{k}.reaches{m})
                temp=corrcoef(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{j}(:,:),...
                    master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{j-1}(:,:));
                reachcorr=[reachcorr; temp(1,2)];

            end
            master_list_simpleR.allDays{k}.reaches{m}.NextCorr=reachcorr;
        end
    end
    a=a+1;
end
%% Correlation between days
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

corrs=NaN(days,length(exp_group));
corrlist=double.empty;
reachcorr=double.empty;
a=1;
for k=exp_group%[3 4 11 12 13 15 16] %5:8%
    for m=2:days
        try
            corrlist=zeros(height(master_list_simpleR.allDays{k}.reaches{m-1}),height(master_list_simpleR.allDays{k}.reaches{m}));
            for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
                reachcorr=double.empty;
                for i=1:height(master_list_simpleR.allDays{k}.reaches{m-1})
                    temp=corrcoef(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{j}(:,:),...
                        master_list_simpleR.allDays{k}.reaches{m-1}.DTWHandNorm{i}(:,:));
                    reachcorr=[reachcorr; temp(1,2)];
                end
                corrlist(:,j)=reachcorr;
            end
            corrs(m,a)=nanmean(nanmean(corrlist));
        end
    end
    a=a+1
end


%% Percent of failure types
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

fail_reach=NaN(days,length(exp_group));
fail_grasp=NaN(days,length(exp_group));
fail_retrieval=NaN(days,length(exp_group));
a=1;
for k=exp_group%[3 4 11 12 13 15 16] %5:8%
    for m=1:days
        try
            fail_reach(m,a)=(sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_reach'))...
                /height(master_list_failure.allDays{k}.reaches{m}))*100;
            fail_grasp(m,a)=(sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_grasp'))...
                /height(master_list_failure.allDays{k}.reaches{m}))*100;
            fail_retrieval(m,a)=(sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_retrieval'))...
                /height(master_list_failure.allDays{k}.reaches{m}))*100;
%             fail_reach(m,a)=sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_reach'));
%             fail_grasp(m,a)=sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_grasp'));
%             fail_retrieval(m,a)=sum(strcmp(master_list_failure.allDays{k}.reaches{m}.behaviors, 'fail_retrieval'));
        end
    end
    a=a+1;
end


%% DISTANCE FROM PELLET by cohort

% enddist=cell.empty;
% endpoint=cell.empty;
% day_endpoint=double.empty;
% day_enddist=double.empty;
% a=1;
% for k=[3 4 11 12 13 15 16] %5:8%
%     for l=1:8
%         day_endpoint=double.empty;
%         day_enddist=double.empty;
%         for i=1:height(master_list_success.allDays{k}.reaches{l})
%             day_endpoint(i,:)=master_list_success.allDays{k}.reaches{l}.DTWHandNorm{i}(101,:);
%             day_enddist(i,1)=norm(master_list_success.allDays{k}.reaches{l}.DTWHandNorm{i}(101,:)- [0 0 0]);
%         end
%         % This is ugly, ask ryan about how to do it better
%         if a==1
%             endpoint{1,l}=day_endpoint;
%             enddist{1,l}=day_enddist;
%         else
%             endpoint{1,l}=[endpoint{1,l}; day_endpoint];
%             enddist{1,l}=[enddist{1,l}; day_enddist];
%         end
%     end
%     a=a+1
% end
% enpointabs=cellfun(@abs,endpoint,'UniformOutput',false);

%% DISTANCE FROM PELLET by mouse
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

enddist=NaN(days,length(exp_group));% 
endpointabs=NaN(days,length(exp_group),3);
day_endpoint=double.empty;
day_enddist=double.empty;

a=1;
for k=exp_group%[3 4 11 12 13 15 16] %5:8%
    for m=1:days
        try
            day_endpoint=double.empty;
            day_enddist=double.empty;
            for i=1:height(master_list_simpleR.allDays{k}.reaches{m})
                day_endpoint(i,:)=master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(101,:);
                day_enddist(i,1)=norm(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(101,:)- [0 0 0]);
            end
    %         if isempty(day_enddist)==1;
    %             day_endpoint(1,1:3)=NaN;
    %             day_enddist(1,1)=NaN;
    %         end
            enddist(m,a)=nanmean(day_enddist);
            endpointabs(m,a,1)=nanmean(abs(day_endpoint(:,1)));
            endpointabs(m,a,2)=nanmean(abs(day_endpoint(:,2)));
            endpointabs(m,a,3)=nanmean(abs(day_endpoint(:,3)));
        end
    end
    a=a+1;
end

% fuckit=NaN(1000,days);
% for m=1:days
%     b=1;
%     for k=exp_group
%         try
%             day_endpoint=double.empty;
%             day_enddist=double.empty;
%             for i=1:height(master_list_simpleR.allDays{k}.reaches{m})
%                 day_endpoint(i,:)=master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(101,:);
%                 day_enddist(i,1)=norm(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(101,:)- [0 0 0]);
%             end
%     %         if isempty(day_enddist)==1;
%     %             day_endpoint(1,1:3)=NaN;
%     %             day_enddist(1,1)=NaN;
%     %         end
%             fuckit(b:(b+length(day_enddist)-1),m)=day_enddist;
%             b=b+length(day_enddist);
%         end
%     end
% end

%% Closest point to pellet
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;
temp=[];
enddist=NaN(days,length(exp_group));% 
endpointabs=NaN(days,length(exp_group),3);
day_endpoint=double.empty;
day_enddist=double.empty;

a=1;
for k=exp_group%[3 4 11 12 13 15 16] %5:8%
    for m=1:days
        try
            day_endpoint=double.empty;
            day_enddist=double.empty;
            temp=[];
            for i=1:height(master_list_simpleR.allDays{k}.reaches{m})
                for j=1:size(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i},1)
                    temp(j,1)=norm(master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(j,:)- [0 0 0]);
                end
                [day_enddist(i,1), I]=min(temp);
                day_endpoint(i,:)=master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(I,:);
                
            end
    %         if isempty(day_enddist)==1;
    %             day_endpoint(1,1:3)=NaN;
    %             day_enddist(1,1)=NaN;
    %         end
            enddist(m,a)=nanmean(day_enddist);
            endpointabs(m,a,1)=nanmean(abs(day_endpoint(:,1)));
            endpointabs(m,a,2)=nanmean(abs(day_endpoint(:,2)));
            endpointabs(m,a,3)=nanmean(abs(day_endpoint(:,3)));
        end
    end
    a=a+1
end

%% START OR END LOCATION 
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

mean_location_x=NaN(days,length(exp_group));%
mean_location_y=NaN(days,length(exp_group));%
mean_location_z=NaN(days,length(exp_group));%
temp=double.empty;
test=double.empty;
ftest=NaN(days,length(exp_group));
a=1;
for k=exp_group%
    for m=1:days
        try
            temp=double.empty;
            test=[];
            for i=1:height(master_list_simpleR.allDays{k}.reaches{m})
                temp(i,:)=master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{i}(101,:);
            end
        
            mean_location_x(m,a)=nanmean(temp(:,1));
            mean_location_y(m,a)=nanmean(temp(:,2));
            mean_location_z(m,a)=nanmean(temp(:,3));
            for i=1:length(temp)
                test(i,1)=norm(temp(i,:)-[mean_location_x(m,a) mean_location_y(m,a) mean_location_z(m,a)]);
            end
            ftest(m,a)=std(test);
        end
    end
    a=a+1;
end

ftest=ftest/900;
%% REACH DURATION 
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

duration=NaN(days,length(exp_group));
temp=double.empty;
a=1;
for k=exp_group%
    for m=1:days
        try
            temp=double.empty;
            for i=1:height(master_list_simpleR.allDays{k}.reaches{m})
%                 temp(i,1)=length(master_list.allDays{k}.reaches{m}.HandX{i})/150;
                temp(i,1)=(master_list_simpleR.allDays{k}.reaches{m}.reachEnd(i)-...
                    master_list_simpleR.allDays{k}.reaches{m}.reachInit(i))/150;
            end
            duration(m,a)=nanmean(temp);
        end
    end
    a=a+1;
end

% figure
% hold on
% errorbar(nanmean(duration1,2),nanstd(duration1,0,2))
% errorbar(nanmean(duration,2),nanstd(duration,0,2))
% xlim([0 9])
% xlabel('Day')
% ylim([0 0.2])
% ylabel('Time (sec)')
% legend('Control', 'VNS')
% hold off
%% STIM ACCURACY
% by mouse
exp_group=find(strcmp('unused',master_list.cohort)==0)';
days=14;

percent_correct=NaN(days,length(exp_group));
false_positive=NaN(days,length(exp_group));
temp=double.empty;
temp_also=double.empty;
temp_also_also=double.empty;
a=1;
for k=exp_group%
    for m=1:days
        try
            temp=double.empty;
            temp_also=double.empty;
            temp_also_also=double.empty;
            temp=strcmp('success',master_list.allDays{k}.reaches{m}.behaviors) & master_list.allDays{k}.reaches{m}.stim~=0;
            temp_also=strcmp('success',master_list.allDays{k}.reaches{m}.behaviors);
            temp_also_also=strcmp('success',master_list.allDays{k}.reaches{m}.behaviors)==0 & master_list.allDays{k}.reaches{m}.stim~=0;
            percent_correct(m,a)=(((height(master_list.allDays{k}.reaches{m})-((nansum(temp_also)-nansum(temp))+nansum(temp_also_also)))/height(master_list.allDays{k}.reaches{m}))*100);
            false_positive(m,a)=((nansum(temp_also_also)/(nansum(strcmp('success',master_list.allDays{k}.reaches{m}.behaviors)==0)))*100);
        end
    end
    a=a+1
end

% by all reaches from CLARA
behaviors=cell.empty;
stims=double.empty;
for k=exp_group%
    for m=1:days
        try
            behaviors=[behaviors; master_list.allDays{k}.reaches{m}.behaviors];
            stims=[stims; master_list.allDays{k}.reaches{m}.stim];
        end
    end
end
accuracy_tbl=table(behaviors,stims);

true_pos=sum(strcmp('success',accuracy_tbl.behaviors) & accuracy_tbl.stims~=0);
true_neg=sum(strcmp('success',accuracy_tbl.behaviors)==0 & accuracy_tbl.stims==0);
false_pos=sum(strcmp('success',accuracy_tbl.behaviors)==0 & accuracy_tbl.stims~=0);
false_neg=sum(strcmp('success',accuracy_tbl.behaviors) & accuracy_tbl.stims==0);

%% NUMBER OF REACH ATTEMPTS
exp_group=find(strcmp('Arch_VNS',master_list.cohort))';
days=8;

attempts=NaN(days,length(exp_group));
a=1;
for k=exp_group%
    for m=1:days
        try
            attempts(m,a)=height(master_list_simpleR.allDays{k}.reaches{m});
        end
    end
    a=a+1
end

%% Distribution of reach timestamps
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

timestamps=cell(days,1);
temp=[];
a=1;
for m=1:days
    temp=[];
    for k=exp_group%
        temp=[temp; [master_list.allDays{k}.reaches{m}.reachInit(:)...
            master_list.allDays{k}.reaches{m}.reachMax(:)...
            master_list.allDays{k}.reaches{m}.reachEnd(:)]];
    end
    for i=1:size(temp,1)
        temp(i,:)=temp(i,:)-temp(i,2);
    end
    temp=temp/150;
    timestamps{a,1}=temp;
    a=a+1;
end



for i=1:size(timestamps,1)
    figure
    hold on
    histogram(timestamps{i}(:,1),edges1,'Normalization','probability');
    histogram(timestamps{i}(:,3),edges2,'Normalization','probability');

    xlabel('Time from reachMax (ms)')
    ylabel('Relative frequency')
    legend('reachInit','reachEnd')
    title(strcat('Day',num2str(i)))
    ylim([0 0.18])
    hold off
end
%% LOOPS FOR DATA VISUALIZATION



%% Plot reach

figure(6)
hold on
plot(master_list.allDays{2}.reaches{7}.DTWHandNorm{2}(:,1),...
    master_list.allDays{2}.reaches{7}.DTWHandNorm{2}(:,2))
plot(master_list.allDays{9}.reaches{8}.DTWHandNorm{9}(:,1),...
    master_list.allDays{9}.reaches{8}.DTWHandNorm{9}(:,2))
scatter(0,0,200,'filled')
set(gca, 'ydir', 'Reverse')
xlim([-8000 1000])
hold off
%% Trajectories for a session
b=8; %mouse index number
c=2; %day index number

clear p
figure(2)
hold on
for i=1:height(master_list.allDays{b}.reaches{c})
%     p(i)=plot(master_list_success.allDays{b}.reaches{c}.DTWHandNorm{i}(1:101,1),...
%         master_list_success.allDays{b}.reaches{c}.DTWHandNorm{i}(1:101,2),'DisplayName',num2str(i));
    p(i)=plot(master_list.allDays{b}.reaches{c}.VelInt{i}(:,1));
end
% set(gca, 'ydir', 'Reverse')
ylim([0 2000])
for i = 1:numel(p)
    % Add a new row to DataTip showing the DisplayName of the line
    p(i).DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Reach',repmat({p(i).DisplayName},size(p(i).XData))); 
end

title(strcat(master_list_success.mouseName{b},'(',num2str(b),')',{' '},'Day',{' '}, num2str(c)))
hold off
%%

figure
hold on
histogram(hist)
set(gca,'xscale','log')
hold off

%% VIDEO OF A SINGLE REACH
b=6; %mouse index number
c=6; %day index number

% find the videos
video_dir='Z:\BIOElectricsLab\RAW_DATA\AutomatedBehavior\';
date=num2str(master_list.allDays{b}.filename{c}(1:8));
unit=num2str(master_list.allDays{b}.filename{c}(10:15));
session=num2str(master_list.allDays{b}.filename{c}(17:end));

full_dir=strcat(video_dir,date,'\',unit,'\',session);
temp_list=ls(full_dir);
for i=1:size(temp_list,1)
    if contains(temp_list(i,:), 'sideCam') && contains(temp_list(i,:), '.mp4')
        video_file_name_side=temp_list(i,1:43);
    elseif contains(temp_list(i,:), 'topCam') && contains(temp_list(i,:), '.mp4')
        video_file_name_top=temp_list(i,1:43);
    elseif contains(temp_list(i,:), 'frontCam') && contains(temp_list(i,:), '.mp4')
        video_file_name_front=temp_list(i,1:44);
    else        
        continue
    end
end

side_vid=VideoReader(strcat(full_dir,'\',video_file_name_side));
top_vid=VideoReader(strcat(full_dir,'\',video_file_name_top));
front_vid=VideoReader(strcat(full_dir,'\',video_file_name_front));


% Extract the frames wanted
frames_wanted=[5900 6015]
% d=6; % day index number
% frames_wanted=[master_list_success.allDays{b}.reaches{c}.reachInit(d) (master_list_success.allDays{b}.reaches{c}.reachEnd(d))]
% frames_wanted=[master_list_success.allDays{b}.reaches{c}.reachInit(d) master_list_success.allDays{b}.reaches{c}.reachMax(d)...
%     master_list_success.allDays{b}.reaches{c}.reachEnd(d) master_list_success.allDays{b}.reaches{c}.stim(d)];
frames_side=read(side_vid,frames_wanted);
frames_front=read(front_vid,frames_wanted);
frames_top=read(top_vid,frames_wanted);
% for i=1:3%size(frames_wanted,2)
%     try
%         frames(:,:,:,i)=read(side_vid,frames_wanted(i));
%     end
% end
% frames(:,:,:,4)=read(side_vid,frames_wanted(4));
clear side_vid;
clear front_vid;
clear top_vid;


% create new video of reach (trajectory overlay is optional)
load(char([strcat(master_list.allDays{b}.filename{c}, '_3D.mat')]));
save_loc='C:\Users\sgkb1\Documents\Matlab Course\CLARA_Vectors\Curators';
% test=imcrop(temp, [160,70,200,200]);
crop=[120 70]
% delete(strcat(save_loc,'\','test.avi'));
v=VideoWriter(strcat(save_loc,'\','test.avi'));
open(v)
a=0;
for j=1:size(frames_front,4)
    tempf=frames_top(:,:,:,j);
    fig=figure(9);
    imshow(tempf);
    hold on
%     plot((table3D.handZ_100{1}(master_list_success.allDays{b}.reaches{c}.reachInit(d):master_list_success.allDays{b}.reaches{c}.reachEnd(d))/100)+crop(1),...
%         (table3D.handY_100{1}(master_list_success.allDays{b}.reaches{c}.reachInit(d):master_list_success.allDays{b}.reaches{c}.reachEnd(d))/100)+crop(2));
%     if j>25 && j<63
%         scatter((table3D.handZ_100{1}(frames_wanted(1,1)+j)/100)+crop(1),...
%             (table3D.handY_100{1}(frames_wanted(1,1)+j)/100)+crop(2),'filled')
%     end
%     scatter((table3D.handZ_100{1}((master_list_success.allDays{b}.reaches{c}.reachInit(d))+a)/100)+crop(1),...
%         (table3D.handY_100{1}((master_list_success.allDays{b}.reaches{c}.reachInit(d))+a)/100)+crop(2),'filled');
    set(gca,'units','normalized','position',[0 0 1 1]); % set the axes units to pixels
    hold off

    newf=getframe(fig);
%     for i=length(newf.cdata):-1:1
%         if newf.cdata(1,i,1)==240
%             newf.cdata(:,i,:)=[];
%         end
%     end

    writeVideo(v,newf.cdata);
    a=a+1;
end
v=VideoWriter(strcat(save_loc,'\','test.avi'));

d=6; 
figure
hold on
plot((table3D.handX_100{1}(master_list_success.allDays{b}.reaches{c}.reachInit(d):master_list_success.allDays{b}.reaches{c}.reachEnd(d))/100)+crop(1),...
        (table3D.handY_100{1}(master_list_success.allDays{b}.reaches{c}.reachInit(d):master_list_success.allDays{b}.reaches{c}.reachEnd(d))/100)+crop(2));
xlim([0 360]);
ylim([0 270]);
set(gca, 'ydir', 'Reverse')

%% Plot mean velocity
exp_group=find(strcmp('Control',master_list.cohort))';
days=8;

mean_vel_plot=cell(days,length(exp_group));
temp=double.empty;
a=1;
for k=exp_group%
    for m=1:days
        temp=double.empty;
        try
            for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
%                 temp(j,:,1)=master_list.allDays{k}.reaches{m}.VelInt{j}(:,1)';
%                 temp(j,:,2)=master_list.allDays{k}.reaches{m}.VelInt{j}(:,2)';
%                 temp(j,:,3)=master_list.allDays{k}.reaches{m}.VelInt{j}(:,3)';
                temp(j,:)=master_list_simpleR.allDays{k}.reaches{m}.AbsVel{j}(:)';
            end
            mean_vel_plot{m,a}=nanmedian(temp);            
%             mean_vel_plot{m,a,1}=nanmean(temp(:,:,1));
%             mean_vel_plot{m,a,2}=nanmean(temp(:,:,2));
%             mean_vel_plot{m,a,3}=nanmean(temp(:,:,3));
        end
    end
    a=a+1;
end

clear p_vel
figure(6)
hold on
for i=1:size(mean_vel_plot,2)
    try
        p_vel(i)=plot(mean_vel_plot{8,i},'DisplayName',num2str(exp_group(i)));
    end
end
% ylim([0 350])
for i = 1:numel(p_vel)
    p_vel(i).DataTipTemplate.DataTipRows(end+1) = ...
        dataTipTextRow('Mouse',repmat({p_vel(i).DisplayName},size(p_vel(i).XData))); 
end

hold off
% 
% figure(5)
% hold on
% for i=1:height(master_list.allDays{13}.reaches{8})
%     plot(master_list.allDays{13}.reaches{8}.VelInt{i}(:,3))
% end
% hold off

%% Plot trajectory cohort

% exp_group=find(strcmp('Control',master_list.cohort))';
% m=8;
% temp=[];
% a=1;
% for k=exp_group
%     for j=1:height(master_list_simpleR.allDays{k}.reaches{m})
%         try
%             temp(:,:,a)=master_list_simpleR.allDays{k}.reaches{m}.DTWHandNorm{j};
%             a=a+1;
%         end
%     end
% end
% 
%  testtraj=mean(temp,3);
% figure(4)
% hold on
% plot3(test(1:24,1),test(1:24,3),test(1:24,2),'LineWidth',4)
% plot3(test(24:64,1),test(24:64,3),test(24:64,2),'LineWidth',4)
% plot3(test(64:end,1),test(64:end,3),test(64:end,2),'LineWidth',4)
% % scatter3(0,0,0,200,'filled')
% set(gca, 'zdir', 'Reverse')
% hold off

% a=1;
% for i=1:m
%     for j=1:length(exp_group)
%         temp(a,:)=mean_vel_plot{i,j};
%         a=a+1;
%     end
% end
m=8;
figure
hold on
t=[];
% to alter opacity in matlab: 'Color',[0 0 1 0.3]
for k=19%exp_group%
    for j=1:height(master_list.allDays{k}.reaches{m})
        s=plot(master_list.allDays{k}.reaches{m}.DTWHandNorm{j}(:,1), master_list.allDays{k}.reaches{m}.DTWHandNorm{j}(:,2),... 
            'Color',[1 0 0],'DisplayName',strcat('Mouse',num2str(k),'Day',num2str(m), 'Reach',num2str(j)));
%         s=plot(master_list.allDays{k}.reaches{m}.VelInt{j}(:,3),... 
%             'Color',[1 0 0],'DisplayName',strcat('Mouse',num2str(k),'Day',num2str(m), 'Reach',num2str(j)));
        t=[t;s];
    end
end
% temp=mean(temp,3);
plot(temp2(:,1), temp2(:,2),'g','LineWidth',3)
% for i = 1:numel(t)
%     t(i).DataTipTemplate.DataTipRows(end+1) = ...
%         dataTipTextRow('info',repmat({t(i).DisplayName},size(t(i).XData))); 
% end
scatter(0,0,200,'filled')
xlim([-10000 2000])
ylim([-8000 8000])
set(gca, 'ydir', 'Reverse')
hold off

% temp=cell2mat(mean_vel_plot(8,:)');
% temp2=cell2mat(mean_vel_plot(1,:)');
% figure(5)
% hold on
% % plot(mean(temp),'b')
% % plot(mean(temp2),'r')
% plot(mean_vel_plot{8,7},'b')
% plot(mean_vel_plot{1,7},'r')
% hold off

%% Plot Start/End Point

exp_group=find(strcmp('Control',master_list.cohort))';
m=1; %Day
n=8; %second day if wanted
figure
hold on
for k=exp_group%
    for j=1:height(master_list.allDays{k}.reaches{m})
        s=scatter(master_list.allDays{k}.reaches{m}.DTWHandNorm{j}(101,1)/900,...
            master_list.allDays{k}.reaches{m}.DTWHandNorm{j}(101,2)/900,...
            'filled','MarkerFaceColor', '#808080', 'MarkerEdgeColor','none');
%          s.MarkerFaceAlpha = 0.3;
    end
    
    for j=1:height(master_list.allDays{k}.reaches{n})
        s=scatter(master_list.allDays{k}.reaches{n}.DTWHandNorm{j}(101,1)/900,...
            master_list.allDays{k}.reaches{n}.DTWHandNorm{j}(101,2)/900,...
            'filled', 'b', 'MarkerEdgeColor','none');
%          s.MarkerFaceAlpha = 0.3;
    end 
    
end
scatter(0,0,400,'filled','g')
% xlim([-8000 4000])
% ylim([-10000 8000])
set(gca, 'ydir', 'Reverse')
hold off
export_fig temp.eps
%%
%zscore
tempz=cell.empty;
for i=1:size(mean_vel_plot,1)
    for j=1:size(mean_vel_plot,2)
        for k=1:size(mean_vel_plot,3)
            tempz{i,j,k}=zscore(mean_vel_plot{i,j,k});
        end
    end
end

figure
hold on
for i=1:size(tempz,2)
    plot(tempz{8,i,3});
end
hold off


temp=[];
temp_out=[];
for i=1:size(mean_vel_plot,1)
    for j=1:size(mean_vel_plot,2)
        temp=corrcoef(mean_vel_plot{i,j,1},mean_vel_plot{i,j,2});
        temp_out(i,j,1)=temp(1,2);
        temp=corrcoef(mean_vel_plot{i,j,1},mean_vel_plot{i,j,3});
        temp_out(i,j,2)=temp(1,2);
        temp=corrcoef(mean_vel_plot{i,j,2},mean_vel_plot{i,j,3});
        temp_out(i,j,3)=temp(1,2);
    end
end
        
a=1;
temp=[];
for i=exp_group
    for j=1:days
        for k=1:height(master_list_success.allDays{i}.reaches{j})
            if master_list_success.allDays{i}.reaches{j}.reachEnd(k)-master_list_success.allDays{i}.reaches{j}.reachInit(k)==31
                temp(a,:)=[i j k];
                a=a+1;
            else
                continue
            end
        end
    end
end

figure
plot(master_list_success.allDays{temp(a,1)}.reaches{temp(a,2)}.HandX{temp(a,3)},...
    master_list_success.allDays{temp(a,1)}.reaches{temp(a,2)}.HandY{temp(a,3)}, 'LineWidth', 3)
set(gca, 'ydir', 'Reverse')

wall1=[6000;6000];
wall2=[-6500;-6500];
figure
hold on
for i=1:100
%     plot3(testtraj(i:i+1,1),testtraj(i:i+1,3),testtraj(i:i+1,2),'LineWidth',4,'Color',cmap(i,:))
    plot3(reaches.DTWHandNorm{a}(i:i+1,1),reaches.DTWHandNorm{a}(i:i+1,3),...
        reaches.DTWHandNorm{a}(i:i+1,2),'LineWidth',4,'Color',cmap(i,:))
    plot3(reaches.DTWHandNorm{a}(i:i+1,1),reaches.DTWHandNorm{a}(i:i+1,3),...
        wall1(1:2),'LineWidth',4,'Color',cmap(i,:))
    plot3(wall2(1:2),reaches.DTWHandNorm{a}(i:i+1,3),...
        reaches.DTWHandNorm{a}(i:i+1,2),'LineWidth',4,'Color',cmap(i,:))
end
xlim([-6500 0])
ylim([-5000 0])
zlim([0 6000])
scatter3(0,0,0,200,'filled')
set(gca, 'zdir', 'Reverse')
hold off


export_fig temp.eps


%%
% load(char([strcat(master_list_simpleR.allDays{14}.filename{10}, '_3D.mat')]));

for_kim=master_list_simpleR.allDays{14}.reaches{10}(:,1:6);
for_kim.HandX=cell(height(master_list_simpleR.allDays{14}.reaches{10}),1);
for_kim.HandY=cell(height(master_list_simpleR.allDays{14}.reaches{10}),1);
for_kim.HandZ=cell(height(master_list_simpleR.allDays{14}.reaches{10}),1);
for i=1:height(master_list_simpleR.allDays{14}.reaches{10})
    for_kim.HandX{i}=table3D.handX_100{1}(for_kim.reachInit(i):for_kim.reachEnd(i));
    for_kim.HandY{i}=table3D.handY_100{1}(for_kim.reachInit(i):for_kim.reachEnd(i));
    for_kim.HandZ{i}=table3D.handZ_100{1}(for_kim.reachInit(i):for_kim.reachEnd(i));
end
%% RAW REACH SESSION WITH TIMEPOINTS

figure
hold on
for i=1:height(for_kim)
    plot3(for_kim.HandX{i},for_kim.HandZ{i},for_kim.HandY{i},...
        'Color','#808080')
end
    
for i=1:height(for_kim)
    scatter3(for_kim.HandX{i}(1),for_kim.HandZ{i}(1),for_kim.HandY{i}(1),...
        20,'MarkerEdgeColor','none','MarkerFaceColor','#7E2F8E')
    scatter3(for_kim.HandX{i}(for_kim.reachMax(i)-for_kim.reachInit(i)+1),...
        for_kim.HandZ{i}(for_kim.reachMax(i)-for_kim.reachInit(i)+1),...
        for_kim.HandY{i}(for_kim.reachMax(i)-for_kim.reachInit(i)+1),...
        20,'MarkerEdgeColor','none','MarkerFaceColor','#77AC30')
    scatter3(for_kim.HandX{i}(end),for_kim.HandZ{i}(end),for_kim.HandY{i}(end),...
        20,'MarkerEdgeColor','none','MarkerFaceColor','#4DBEEE')
end
set(gca, 'zdir', 'Reverse')
view([-15 30])
hold off

export_fig temp.eps
    
 %% CURATOR DISTRIBUTION
 exp_group=find(strcmp('Control',master_list_success.cohort))';
 temp=table.empty;
 for i=exp_group
     for j=1:height(master_list_success.allDays{i})
         temp=[temp; master_list_success.allDays{i}.reaches{j}(:,1:4)];
     end
 end   

test=temp(temp.stim~=0,:);
test=table2array(test);

temp=test-test(:,3);
temp=temp/150;

[~,idx] = sort(temp(:,1));
test=temp(idx,:);

test=test((test(:,4)<1),:);

row=(1:1:917)';

figure
hold on
barh(test(:,1),'FaceColor','#303030')
barh(test(:,2),'FaceColor','#808080')
barh(test(:,4),'FaceColor','#C8C8C8')
scatter(test(:,1),row(:,1),10,'filled')
scatter(test(:,2),row(:,1),10,'filled')
scatter(test(:,3),row(:,1),10,'filled')
scatter(test(:,4),row(:,1),10,'filled')

%%
data=rand(6,4); %Replace me with real data!
idx=1:1:size(data,2);
names={'Base'; 'Option1'; 'Option2'; 'Wash'};
sdevs=std(data);

figure
hold on
for i=1:size(data,1)
    scatter(idx, data(i,:))
end
xlim([0 5]) %Set to [0 n+1 days]
errorbar(mean(data),sdevs, 'LineStyle','none')
set(gca,'xtick',[1:4],'xticklabel',names)
hold off
