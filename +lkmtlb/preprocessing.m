% data preparation & transformation.
% current field: c.results.MeanLeg.angAtFullCycle.
% if desired, change field in loadData method.
classdef preprocessing < handle
    
    properties (Access = private)
        dataPath    % folder containing data
        fileNames   % data files
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
            raw = c.results.MeanLeg.angAtFullCycle;
            
            % transform data into user & spm friendly
            self.transformData(raw, group, iparticipant);
            
        end % loadData
        
        %-------------------------------------------------------------------------%
        function transformData(self, raw, group, iparticipant)
            % get DoF
            fields = fieldnames(raw);
            DoF = 1:3;
            
            % initialize struct
            if isempty(self.data)
                outputFields = {'y', 'dof', 'group', 'participant'};
                self.data = cell2struct(cell(length(outputFields), 1), outputFields);
            end
            
            for ifield = fields'
                self.data.y = vertcat(self.data.y, raw.(ifield{:}){1, 1}');
                self.data.group = cat(2, self.data.group, repmat(group, 1, 3));
                self.data.dof = cat(2, self.data.dof, DoF);
                self.data.participant = cat(2, self.data.participant, repmat(iparticipant, 1, 3));
                
                % increment DoF
                DoF = DoF + 3;
            end
        end
        
        function getNomenclature(self)
            % DoF names
            A = {'hip', 'knee', 'ankle', 'footProgress', 'thorax', 'pelvis'};
            B = {'X', 'Y', 'Z'};
            C = strcat(repmat(A, numel(B), 1), repmat(B', 1, numel(A)));
            dof = C(:)';
            
            % group names
            group = {'pre', 'post'};
            
            % participants names
            participants = num2cell(self.data.participant);
            participants = cellfun(@(x) strcat('patient_', num2str(x)), participants, 'UniformOutput', false);
            
            self.nomenclature = table(...
                participants',...
                group(self.data.group)',...
                dof(self.data.dof)',...
                'VariableNames', {'participants', 'group', 'dof'}...
                );
        end
        
    end % methods
    
end % class