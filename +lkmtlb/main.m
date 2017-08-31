% main launcher of the biomech toolbox.
classdef main
    
    properties (Access = private)
        dataPath    % folder containing data
    end % private properties
    
    properties
    end % public properties
    
    %-------------------------------------------------------------------------%
    methods
        
        function self = main
            % verify that lkmtlb is the current working directory
            if ~contains(pwd, 'lokomatlab')
                error('make the lokomatlab package folder your current directory [lkmtlb warning].')
            end
            
            % 1) get data path
            self.dataPath = self.getDataPath;
            
            % 2) get data
            self.getData
            
        end % constructor
        
        %-------------------------------------------------------------------------%
        function output = getDataPath(~)
            % get the data path
            fprintf('Select data folder on the dialog box\n')
            output = uigetdir('Select data folder');
            fprintf('\tfolder loaded: ''%s''\n', output)
        end % getDataPath
        
        %-------------------------------------------------------------------------%
        function output = getData(self)
            % transform input data into spmo friendly data
            % field of interest
            field = 'c.results.MeanLeg.angAtFullCycle';
            fprintf('field of interest: %s\n', field);
            
            % get mat files
            matFiles = dir(sprintf('%s/*.mat', self.dataPath));
            fileNames = {matFiles.name};
            
            output = cellfun(@(x) self.loadData(x), fileNames)
        end % getData
        
        %-------------------------------------------------------------------------%
        function raw = loadData(self, fileNames)
            
        end % loadData
        
    end % methods
    
end % class