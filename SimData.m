%Faisal Baqai
%fbaqai@andrew.cmu.edu

hertz= 2:2:40;
hertz=repmat(hertz,1,10);
numcells=10;
maxtimes=zeros(1,numcells);
Stack=cell(1,numcells);
Duration=5000;%5 seconds of simulated video
LocMax=125;
Location=zeros(2,numcells);
CellPix=40;
for neuron=1:1:numcells
    
    Rearrange=randperm(length(hertz));
    intermeans=1./hertz(Rearrange); %Seconds
    spiketimes=cumsum(exprnd(intermeans));

    ExistingTrace=zeros(1,ceil(max(spiketimes)*1000+100)); %Calcium time series, milliseconds
    for spike=1:1:length(spiketimes)
       [ ExistingTrace ] = SpikeTemplate (spiketimes(spike), ExistingTrace);
    end
    %TimeSeries{neuron}=ExistingTrace;
    maxtimes(neuron)=length(ExistingTrace);
    if maxtimes(neuron)>Duration
       maxtimes(neuron)=Duration;
       ExistingTrace=ExistingTrace(1:Duration);
    end
    
    Stack{neuron}=zeros(CellPix,CellPix,maxtimes(neuron));
    for time=1:maxtimes(neuron);
        ZMatrix = Gauss2D( 9, 12, ExistingTrace(time));
        Stack{neuron}(:,:,time)=ZMatrix;
    end
    Location(:,neuron)=randi(LocMax-.5*CellPix,2,1);
    
end
maxofalltimes=max(maxtimes);

%plot(ExistingTrace(1:5000))
%maxtime=length(ExistingTrace);

FieldofView=zeros(LocMax+CellPix,LocMax+CellPix,maxofalltimes);
for neuron=1:1:numcells
    Corner=.5*CellPix+Location(:,neuron);
    Edge=Corner+CellPix-1;
    FieldofView(Corner(1):Edge(1),Corner(2):Edge(2),:)=FieldofView(Corner(1):Edge(1),Corner(2):Edge(2),:)+Stack{neuron};    
end

% Stack=zeros(41,41,maxtime);
% for time=1:maxtime;
%     ZMatrix = Gauss2D( 9, 12, ExistingTrace(time));
%     Stack(:,:,time)=ZMatrix;
% end
% %Range=[min(Stack(:)), max(Stack(:))];
Range=[0, 1.5];
% for step=1:1:Duration
%     imshow(FieldofView(:,:,step),Range)
%     drawnow
% end
%%
Format=size(FieldofView);
FieldofView(FieldofView>=Range(2))=Range(2);
FieldofView=FieldofView./Range(2);
FieldofView=reshape(FieldofView, Format(1),Format(2),1,Format(3));
v = VideoWriter('CalciumSim.avi');
v.FrameRate = 60;
open(v);
writeVideo(v, FieldofView);
close(v);