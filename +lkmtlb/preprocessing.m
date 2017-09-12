% data preparation & transformation.
% current field: c.results.MeanLeg.angAtFullCycle.
% if desired, change field in loadData method.
classdef preprocessing < handle
    
    properties (Access = private)
        dataPath    % folder containing data
        fileNames   % data files
        var         % degrees of freedom (name)
        ivar        % degree of freedom (integers)
    end % private properties
    
    properties
        data         % data structure
        nomenclature % data nomenclature
    end % public properties
    
    %-------------------------------------------------------------------------%
    methods
        
        function self = preprocessing(dataPath)
            % verify that lkmtlb is the current working directory
            if ~contains(pwd, 'lokomatlab')
                error('make the lokomatlab package folder your current directory [lkmtlb warning].')
            end
            
            % 1) get data path
            self.dataPath = dataPath;
            fprintf('folder loaded: ''%s''\n', self.dataPath)
            
            % 2) transform data into user & spm friendly
            self.data = [];
            self.getData;
            
            % 3) get data nomenclature
            self.getNomenclature;
            
        end % constructor
        
        %-------------------------------------------------------------------------%
        function getData(self)
            % get mat files
            matFiles = dir(sprintf('%s/*.mat', self.dataPath));
            self.fileNames = {matFiles.name};
            
            cellfun(@(x) self.loadData(x), self.fileNames);
        end % getData
        
        %-------------------------------------------------------------------------%
        function loadData(self, ifile)
            % get participant
            iparticipant = regexp(ifile,'\d+','match');
            iparticipant = str2double(iparticipant{:});
            
            % get group (pre or post)
            if contains(ifile, 'pre')
                group = 1;
            elseif contains(ifile, 'post')
                group = 2;
            else
                error('invalid filename (pre or post not find)')
            end
            
            % get raw data
            load(sprintf('%s/%s', self.dataPath, ifile))
            
            % transform data into user & spm friendly
            self.transformData(c, group, iparticipant);
            
        end % loadData
        
        %-------------------------------------------------------------------------%
        function transformData(self, raw, group, iparticipant)
            
            if isempty(self.data)
                % DOF
                self.var = {'thorax_X', 'thorax_Y', 'thorax_Z',...
                'pelvis_X', 'pelvis_Y', 'pelvis_Z',...
                'hip_X', 'hip_Y', 'hip_Z',... right
                'knee_X', 'knee_Y',... right
                'ankle_Z',... right
                'footprogress_Z'}; % left
                [~, ~, self.ivar] = unique(self.var, 'stable');
                
                % initialize struct
                outputFields = {'y', 'var', 'group', 'participant'};
                self.data = cell2struct(cell(length(outputFields), 1), outputFields);
            end
            
            % data
            self.data.y = [self.data.y ...
            raw.results.MeanLeg.angAtFullCycle.Thorax{1, 1}(:,1:3) ...    thorax_X, thorax_Y, thorax_Z
            raw.results.MeanLeg.angAtFullCycle.Pelvis{1, 1}(:,1:3) ...    pelvis_X, pelvis_Y, pelvis_Z
            raw.results.MeanLeg.angAtFullCycle.Hip{1, 1}(:,1:3) ...        right hip_X, hip_Y, hip_Z
            raw.results.MeanLeg.angAtFullCycle.Knee{1, 1}(:,1:2) ...       right knee_X, knee_Y
            raw.results.MeanLeg.angAtFullCycle.Ankle{1, 1}(:,3) ...        right ankle_Z
            raw.results.MeanLeg.angAtFullCycle.FootProgress{1, 1}(:,3) ... right footProgress_Z
            ];
        
            % group
            self.data.group = cat(2, self.data.group, repmat(group, 1, numel(self.var)));
            
            % var
            self.data.var = cat(2, self.data.var, self.ivar');
            
            % participant
            self.data.participant = cat(2, self.data.participant, repmat(iparticipant, 1, numel(self.var)));
        end
        
        function getNomenclature(self)
            % DoF names = self.var
            variable = unique(self.var, 'stable');
            % group names
            group = {'pre', 'post'};
            
            self.nomenclature = table(...
                self.data.participant',...
                group(self.data.group)',...
                variable(self.data.var)',...
                'VariableNames', {'participant', 'group', 'var'}...
                );
        end
        
    end % methods
    
end % class