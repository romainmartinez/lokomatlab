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

dataPath = '/media/romain/E/Projet_Lokomat/Enfants_CP_Yosra';

% data preparation & transformation
xi = lkmtlb.preprocessing(dataPath);

lkmtlb.stats(xi.data,...
    'correction', true,...
    'plots', true,...
    'parametric', false);




