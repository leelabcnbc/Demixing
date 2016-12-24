function [ NewTrace ] = SpikeTemplate (SpikeTime, ExistingTrace)
%SpikeTemplate Add to the fluorescence time series for a given spiketime
%   Detailed explanation goes here

x=0:1:30; %milliseconds of waveform
y=zeros(size(x));
y(1:15)=-0.0172619*x(1:15).^2 + 0.263095*x(1:15);
y(16:end)=147.412*exp(-0.442664*x(16:end));

NewTrace=ExistingTrace;
timeinms=ceil(SpikeTime*1000);
NewTrace(timeinms:1:timeinms+length(x)-1)= NewTrace(timeinms:1:timeinms+length(x)-1)+y;
end

