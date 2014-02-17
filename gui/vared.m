function [vr] = vared(data,synth,dt)

ds=data-synth;

dsn=(norm(ds))^2*dt;

d=(norm(data))^2*dt;

vr=1-(dsn/d);



