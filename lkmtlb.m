%{
    %   Description: Lokomat analysis
    %
    %   author:  Romain Martinez
    %   email:   martinez.staps@gmail.com
    %   website: github.com/romainmartinez

    %----------- todo -----------%
    % Hotelling test
    % gramm to plot spm (not R)
    %----------------------------%
%}
clear variables; clc; close all

% dataPath = '/media/romain/E/Projet_Lokomat/Enfants_CP_Yosra';
dataPath = 'Z:/Projet_Lokomat/Enfants_CP_Yosra';

% data preparation & transformation
obj = lkmtlb.preprocessing(dataPath);

lkmtlb.stats(obj.data,...
    'correction', false,...
    'plots', true,...
    'parametric', false);




