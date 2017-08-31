% statistical analysis using Statistical Parametric Mapping
% see: [http://www.spm1d.org/] for documentation
classdef stats < handle
    
    properties (Access = private)
        data         % data structure
    end % private properties
    
    properties
    end % public properties
    
    %-------------------------------------------------------------------------%
    methods
        
        function self = stats(df)
            % add spm library
            addpath('./spm8')
            self.data = df;
            
            % reshape data
            [A, B] = self.reshapeData;
            
            % 1) paired Hotelling’s T2 test
            self.hotelling(A, B)
            
            
            % 2) post hoc (separate t tests on each vector component)
            % for each post hoc test use a Bonferroni correction.
            % for Hotelling’s T2 tests conduct separate t tests on each vector component
            % but acknowledge that this neglects vector component covariance.
        end % constructor
        
        %-------------------------------------------------------------------------%
        
        function [A, B] = reshapeData(self)
            % transform data into 3d matrix
            % participants x frames x variables
            
            % participants
            n = unique(self.data.participant);
            
            % preallocate matrices
            A = zeros(numel(n), length(self.data.y), length(unique(self.data.dof)));
            B = A;
            
            for i = 1 : numel(n) % for each subject
                % pre group
                A(i, :, :) = self.data.y(self.data.participant == n(i) & self.data.group == 1, :)';
                % post group
                B(i, :, :) = self.data.y(self.data.participant == n(i) & self.data.group == 2, :)';
            end
            
        end
        
        function hotelling(~, A, B)
            % paired Hotelling’s T2 test
            spm = spm1d.stats.hotellings_paired(A, B);
            spmi = spm.inference(0.05);
            disp(spmi)
            
            % plot
            close all
            spmi.plot();
            spmi.plot_threshold_label();
            spmi.plot_p_values();
        end
    end % methods
    
end % class