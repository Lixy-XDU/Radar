classdef LFM_Wave < Radarbox.RadarWave
    properties
        tau     % 脉冲时宽
        PRF     % 重频频率
        N       % 脉冲个数
        theta = 0  % 初始相位
    end
    properties (Access = private)
        single_wave
    end
    methods
        function obj = LFM_Wave(f0,t1,t2,fs,tau,f_end,PRF,N,theta,vr)
            arguments
                f0    (1,1) {mustBeNumeric}
                t1    (1,1) {mustBeNumeric}
                t2    (1,1) {mustBeNumeric}
                fs    (1,1) {mustBeNumeric}
                tau   (1,1) {mustBeNumeric}
                f_end (1,1) {mustBeNumeric}
                PRF   (1,1) {mustBeNumeric}
                N     (1,1) {mustBeNumeric} = 1
                theta (1,1) {mustBeNumeric} = 0
                vr    (1,1) {mustBeNumeric} = 0
            end
            obj = obj@Radarbox.RadarWave(f0,f_end,t1,t2,fs);
            obj.N = N;
            obj.PRF = PRF;
            obj.tau = tau;
            obj.f_end = f_end;
            obj.theta = theta*pi/180;
            obj = obj.Wave_Doppler(vr);
            obj = LFM_sigwave(obj);
            Judge_Reasonableness(obj);

            obj.wavetype = Radarbox.Type.WaveType.LFM;
        end
        % function [obj,sigwave,t] = LFM_sig(obj)
        %     bandwidth = obj.f_end - obj.f0;
        %     sLFM = phased.LinearFMWaveform('SweepBandwidth',bandwidth,...
        %         'OutputFormat','Pulses','SampleRate',obj.fs,...
        %         'PulseWidth',obj.tau,'PRF',obj.PRF,'NumPulses',obj.N, ...
        %         'FrequencyOffset',obj.f0);   
        %     % sigwave = chirp(obj.t,obj.f0,obj.tau,obj.f_end);
        %     sigwave = step(sLFM)*exp(1j*obj.theta);
        %     obj.sigwave = [sigwave',zeros(1,length(obj.t)-length(sigwave))];
        %     numpulses = size(sigwave,1);
        %     t = (0:(numpulses-1))/obj.fs+obj.t1;
        %     % obj.t = t;
        % end
        function obj = LFM_sigwave(obj)
            obj = obj.LFM_single_wave();
            phi_step = 2*pi*obj.fs/obj.PRF;
            obj.sigwave = obj.Wave_cycle_extension(obj.N,obj.single_wave,0,phi_step);
            obj.sigwave = [obj.sigwave,zeros(1,length(obj.t)-length(obj.sigwave))];
        end
        function obj = LFM_single_wave(obj)
            % Generate a single wave vector.
            n_ax = floor(obj.tau*obj.fs);
            obj = obj.Frequency_Domain(n_ax);
            obj.f_ax = obj.f_ax * obj.beta_v;
            sw = obj.Wave_generator(obj.theta);
            len = floor(obj.fs/obj.PRF);
            obj.single_wave = [sw,zeros(1,len-length(sw))];
        end
        function LFM_plot(obj)
            figure("Name",'LFMW');
            % obj.fig_number = obj.fig_number + 1;
            % disp(obj.fig_number);
            plot(obj.t,real(obj.sigwave));
            axis([obj.t1,obj.t2,-1.1,1.1]);
            title('$LFM\ Wave\ in\ Time\ Domain$','FontSize', ...
                7,'Interpreter','latex');
            pause(0.001);
        end
    end
    methods (Access = private)
        function Judge_Reasonableness(obj)
            % 参数范围检验
            p = inputParser;
            q = inputParser;
            % t2 >= N/PRF
            x = obj.t2;
            addRequired(p,'x',@(x) validateattributes(x,{'numeric'}, ...
                {'>=',obj.N/obj.PRF}));
            parse(p,x);
            % 1/PRF >= tau
            y = 1/obj.PRF;
            addRequired(q,'y',@(y) validateattributes(y,{'numeric'}, ...
                {'>=',obj.tau}));
            parse(q,y);
        end
    end
    methods (Static)
        function obj = LFM_Rebuild(obj)
            arguments
                obj (1,1) {mustBeA(obj,'Radarbox.LFM_Wave')}
            end 
            obj = obj.LFM_sigwave();
        end
    end
end