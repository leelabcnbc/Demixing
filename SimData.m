%Faisal Baqai
%fbaqai@andrew.cmu.edu

hertz= 2:2:40;
hertz=repmat(hertz,1,10);
Rearrange=randperm(length(hertz));
intermeans=1./hertz(Rearrange); %Seconds
spiketimes=cumsum(exprnd(intermeans));

ExistingTrace=zeros(1,ceil(max(spiketimes)*1000+100)); %Calcium time series, milliseconds
for spike=1:1:length(spiketimes)
   [ ExistingTrace ] = SpikeTemplate (spiketimes(spike), ExistingTrace);
end
plot(ExistingTrace(1:5000))

FieldofView=zeros(80,80);
 