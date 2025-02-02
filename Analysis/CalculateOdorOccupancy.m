function [on,off] = CalculateOdorOccupancy(flyTracks,savepath)

median_max = median(max(flyTracks.centroid(:,2,:)));
median_min = median(min(flyTracks.centroid(:,2,:)));
vthresh = (median(max(flyTracks.centroid(:,2,:))) - median((min(flyTracks.centroid(:,2,:)))))/2+median(min(flyTracks.centroid(:,2,:)));
%%
time= datestr(flyTracks.times);
time= datetime(time);
starttime= seconds(min(flyTracks.stim{2}));
endtime= seconds(max(flyTracks.stim{2}));
timedelta= time-time(1);
stimon=and(timedelta>starttime,timedelta<endtime);
%left side (oct) in odor and air period
occupancy_on = sum(flyTracks.centroid(stimon,2,:)<vthresh)./sum(flyTracks.centroid(stimon,2,:)>0);
mean(occupancy_on)
occupancy_off = sum(flyTracks.centroid(~stimon,2,:)<vthresh)./sum(flyTracks.centroid(~stimon,2,:)>0);
mean(occupancy_off)
%%
%This will provide the occupancy rate when the stimulus is on and off
on = reshape(occupancy_on,[15,1]);
off = reshape(occupancy_off,[15,1]);

%Create Table
FlyNumber = 1:15;
FlyNumber=FlyNumber';
Concentration_left = ones(15,1)*flyTracks.stim{3}(1,1);
Concentration_right = ones(15,1)*flyTracks.stim{3}(1,2);

ConcentrationExpmt1 = table(FlyNumber,Concentration_left,Concentration_right,on,off)
%experiment concenation, input concentration
ConcentrationExpmt1.OdorLeft(1:15) = flyTracks.stim{4}(1);
ConcentrationExpmt1.OdorRight(1:15) = flyTracks.stim{4}(2);
t = datestr(time(1),'mm-dd-yyyy_HH-MM-SS')
ConcentrationExpmt1.StartTime(1:15) = {t};
%%
newtable_conc = [ConcentrationExpmt1]
filename="test.csv"

filename=strcat(savepath,t,'_occupancies.csv')
writetable(newtable_conc,filename);

%% analysis plots
figure()
clf
subplot(1,2,1)
ylim([0 700])
xlim([0,3600])
hold on
patch([find(stimon, 1 ) find(stimon, 1), find(stimon,1, 'last') find(stimon, 1,'last' )],[min(ylim) max(ylim) max(ylim) min(ylim)], [0.8 0.8 0.8])
line([0 3600], [vthresh vthresh], 'linewidth',1,'linestyle',"--","Color","k")
for i=1:15
    plot(flyTracks.centroid(:,2,i))
end
xlabel("Time")
ylabel("Y position")
subplot(1,2,2)
scatter(off,on)
xlim([0,1])
ylim([0,1])
xlabel("Occupancy in Air Period")
ylabel("Occupancy in Odor Period")
