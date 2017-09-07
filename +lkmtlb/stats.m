% statistical analysis using Statistical Parametric Mapping
% see: [http://www.spm1d.org/] for documentation
classdef stats < handle
    
    properties (Access = private)
        data         % data structure
    end % private properties
    
    properties
        correction
    end % public properties
    
    %-------------------------------------------------------------------------%
    methods
        
        function self = stats(df, varargin)
            % inputs :
            %   correction (logical): true (default) is you want Bonferonni
            
            p = inputParser;
            
            p.addRequired('data', @isstruct);
            p.addOptional('correction', true, @islogical);
            
            p.parse(df, varargin{:})
            
            self.data = p.Results.data;
            self.correction = p.Results.correction;
            
            % add spm library
            addpath('./spm8')
            
            % run post hoc tests
            self.run_postHoc;
            
        end % constructor
        
        %-------------------------------------------------------------------------%
        function run_postHoc(self)
            % get number of test
            nTest = self.get_nTest;
            
            % get p (corrected if correction == true)
            pCorrected = self.get_pCorrected(nTest);
            
            for i = 1 : nTest
                % first group
                YA = self.data.y(:,self.data.var == i & self.data.group == 1)';
                % second group
                YB = self.data.y(:,self.data.var == i & self.data.group == 2)';
                
%                 % 1) normality test
%                 spm = spm1d.stats.normality.ttest_paired(YA, YB);
%                 spmi = spm.inference(0.05);
%                 disp(spmi)
%                 
%                 % plot
%                 figure;
%                 subplot(131);  plot(YA', 'k');  hold on;  plot(YB', 'r');  title('Data')
%                 subplot(132);  plot(spm.residuals', 'k');  title('Residuals')
%                 subplot(133);  spmi.plot();  title('Normality test')
                
                % 2) parametric ttest
                spm = spm1d.stats.ttest_paired(YA, YB);
                spmi = spm.inference(pCorrected, 'two_tailed', false, 'interp',true);
                disp(spmi)
                
                % 3) non parametric test
                rng(0)
                alpha = 0.05;
                snpm = spm1d.stats.nonparam.ttest_paired(YA, YB);
                snpmi = snpm.inference(alpha, 'two_tailed', false, 'iterations', -1, 'force_iterations', true);
                disp('Non-Parametric results')
                disp(snpmi)
                
                % plot
                figure('Name', num2str(i),...
                    'Unit', 'Normalized',...
                    'Position', [0 0 .5 1]);
                title('coucou')
                % mean and SD:
                subplot(311)
                spm1d.plot.plot_meanSD(YA, 'color','k');
                hold on
                spm1d.plot.plot_meanSD(YB, 'color','r');
                title('Mean and SD')
                
                % parametric test
                subplot(312)
                spmi.plot();
                spmi.plot_threshold_label();
                spmi.plot_p_values();
                title('parametric test')

                % non parametric test
                subplot(313)
                snpmi.plot();
                snpmi.plot_threshold_label();
                snpmi.plot_p_values();
                title('non parametric test')
            end
        end % run_postHoc
        
        function n = get_nTest(self)
            i = unique(self.data.var);
            n = numel(i);
        end % ntest
        
        function p = get_pCorrected(self, nTest)
            pBase = 0.05;
            if self.correction
                p = spm1d.util.p_critical_bonf(0.05, nTest);
            else
                p = pBase;
            end
        end % pCorrected
        
    end % methods
    
end % class