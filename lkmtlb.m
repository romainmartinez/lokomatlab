%{
    %   Description: Lokomat analysis
    %
    %   author:  Romain Martinez
    %   email:   martinez.staps@gmail.com
    %   website: github.com/romainmartinez

    %----------- todo -----------%
    % Hotelling test
    % automate orgData (spm & gramm friendly)
    % gramm to plot spm (not R)
    %----------------------------%
%}
clear variables; clc; close all

dataPath = '/home/romain/Downloads/lokomatlab';
xi = lkmtlb.preprocessing(dataPath);

