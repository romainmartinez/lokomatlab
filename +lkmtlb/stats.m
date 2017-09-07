% statistical analysis using Statistical Parametric Mapping
% see: [http://www.spm1d.org/] for documentation
classdef stats < handle
    
    properties (Access = private)
        data         % data structure
        pCorrected   % corrected p
    end % private properties
    
    properties
        correction
        parametric
        plots
    end % public properties
    
    %-------------------------------------------------------------------------%
    methods
        
        function self = stats(df, varargin)
            % inputs :
            %   correction (logical): true (default) for Bonferonni correction
            %   parametric (logical): true (default) for parametric testing
            %   plot       (logical): true (default) for plotting spm results
            
            p = inputParser;
            
            p.addRequired('data', @isstruct);
            
            p.addOptional('correction', true, @islogical);
            p.addOptional('parametric', true, @islogical);
            p.addOptional('plots', true, @islogical);
            
            p.parse(df, varargin{:})
            
            self.data = p.Results.data;
            self.correction = p.Results.correction;
            self.parametric = p.Results.parametric;
            self.plots = p.Results.plots;
            
            % add spm library
            addpath('./spm8')
            
            % run hotelling test
            %             self.hotelling
            
            % run post hoc tests
            self.run_postHoc;
            
        end % constructor
        
        %-------------------------------------------------------------------------%
        function hotelling(self)
            % participants x frames x variables
            % participants
            n = unique(self.data.participant);
            
            % preallocate matrices
            YA = zeros(numel(n), size(self.data.y, 1), length(unique(self.data.var)));
            YB = YA;
            
            for i = 1 : numel(n) % for each subject
                % pre group
                YA(i, :, :) = self.data.y(:, self.data.participant == n(i) & self.data.group == 1);
                % post group
                YB(i, :, :) = self.data.y(:,self.data.participant == n(i) & self.data.group == 2);
            end
            
            %(1) Conduct non-parametric test:
            s = rng;
            if s.Seed ~= 0
                rng(0)
            end
            snpm = spm1d.stats.nonparam.hotellings_paired(YA, YB);
            snpmi = snpm.inference(0.05, 'iterations', 500);
            disp('Non-Parametric results')
            disp( snpmi )
            
            %(2) Compare to parametric inference:
            spm = spm1d.stats.hotellings_paired(YA,YB);
            spmi = spm.inference(0.05);
            disp('Parametric results')
            disp(spmi)
            % plot:
            close all
            figure('position', [0 0 1000 300])
            subplot(121);  spmi.plot();  spmi.plot_threshold_label();  spmi.plot_p_values();
            subplot(122);  snpmi.plot(); snpmi.plot_threshold_label(); snpmi.plot_p_values();
        end
        
        function run_postHoc(self)
            % get number of test
            nTest = self.get_nTest;
            
            % get p (corrected if correction == true)
            self.pCorrected = self.get_pCorrected(nTest);
            
            for i = 1 : nTest
                % first group
                YA = self.data.y(:,self.data.var == i & self.data.group == 1)';
                % second group
                YB = self.data.y(:,self.data.var == i & self.data.group == 2)';
              
                % 1) normality test
                self.normality(YA, YB);
                
                % 2) ttest
                self.ttest_paired(YA, YB)
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
        
        function normality(self, YA, YB, varargin)
            spm = spm1d.stats.normality.ttest_paired(YA, YB);
            spmi = spm.inference(0.05);
            
            % plot
            if self.plots
                disp(spmi)
                figure('unit', 'normalized', 'position', [0 0 1 1]);
                subplot(221);  plot(YA', 'k');  hold on;  plot(YB', 'r');  title('Data')
                subplot(222);  spmi.plot();  title('Normality test')
            end
        end
        
        function ttest_paired(self, YA, YB)
            if self.parametric
                % parametric ttest
                spm = spm1d.stats.ttest_paired(YA, YB);
                spmi = spm.inference(self.pCorrected,...
                    'two_tailed', false,...
                    'interp',true);
            else
                % non-parametric ttest
                % Control random number generation
                spm = spm1d.stats.nonparam.ttest_paired(YA, YB);
                spmi = spm.inference(0.05,...
                    'two_tailed',false,...
                    'iterations', -1,...
                    'force_iterations', true);
            end
            % plot
            if self.plots
                subplot(223)
                spm1d.plot.plot_meanSD(YA, 'color','k');
                hold on
                spm1d.plot.plot_meanSD(YB, 'color','r');
                title('Mean and SD')
                
                subplot(224)
                spmi.plot();
                spmi.plot_threshold_label();
                spmi.plot_p_values();
                title('hypothesis testing')
            end
        end
        
    end % methods
    
end % class