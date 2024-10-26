classdef FMCW_Wave < Radarbox.RadarWave
    properties
        T       % 正斜率时宽
        NT      % 扫频周期数
        theta = 0  % 初始相位
        options
    end

    methods
        function obj = FMCW_Wave(f0,t1,t2,fs,T,f_end,NT,theta,vr,options)
            arguments
                f0    (1,1) {mustBeNumeric}
                t1    (1,1) {mustBeNumeric}
                t2    (1,1) {mustBeNumeric}
                fs    (1,1) {mustBeNumeric}
                T     (1,1) {mustBeNumeric}
                f_end (1,1) {mustBeNumeric}
                NT    (1,1) {mustBeNumeric} = 1
                theta (1,1) {mustBeNumeric} = 0
                vr    (1,1) {mustBeNumeric} = 0
                options (1,:) char {mustBeMember(options, ...
                    {'up','down','tri'})} = 'tri'
            end
            obj = obj@Radarbox.RadarWave(f0,f_end,t1,t2,fs);
            obj.NT = NT;
            obj.T = T;
            obj.f_end = f_end;
            obj.theta = theta*pi/180;
            obj = obj.Wave_Doppler(vr);
            obj.options = options;
            obj = FMCW_sigwave(obj);

            obj.wavetype = Radarbox.Type.WaveType.FMCW;
        end
        % function obj = FMCW_sig(obj,options)
        %     arguments
        %         obj (1,1) {mustBeA(obj,'Radarbox.RadarWave')} 
        %         options (1,:) char {mustBeMember(options, ...
        %             {'up','down','tri'})} = 'tri'
        %     end
        %     single_t = (0:1/obj.fs:obj.T-1/obj.fs) + obj.t1;
        %     switch options
        %         case 'up'
        %             single_wave = chirp(single_t,obj.f0,obj.T, ...
        %                 obj.f_end,'linear',0,'complex');
        %             t = obj.timeline_span(single_t,obj.T,obj.NT-1);
        %         case 'down'
        %             single_wave = chirp(single_t,obj.f_end,obj.T, ...
        %                 obj.f0,'linear',0,'complex');
        %             t = obj.timeline_span(single_t,obj.T,obj.NT-1);
        %         case 'tri'
        %             single_wave = [chirp(single_t,obj.f0,obj.T, ...
        %                            obj.f_end,'linear',0,'complex'), ...
        %                            chirp(single_t,obj.f_end,obj.T, ...
        %                            obj.f0,'linear',0,'complex')];
        %             single_t = [single_t,single_t + obj.T];
        %             t = obj.timeline_span(single_t,2*obj.T,obj.NT-1);
        %     end
        %     sigwave = repmat(single_wave,1,obj.NT)*exp(1j*obj.theta);
        %     obj.sigwave = [sigwave,zeros(1,length(obj.t)-length(sigwave))];
        %     % obj.t = t;
        % end
        function obj = FMCW_sigwave(obj)
            n_ax = floor(obj.T*obj.fs);
            obj = obj.Frequency_Domain(n_ax);
            obj.f_ax = obj.f_ax * obj.beta_v;
            switch obj.options
                case 'up'
                    obj.f_ax = obj.Wave_cycle_extension(obj.NT,obj.f_ax,0,0);
                case 'down'
                    obj.f_ax = obj.Wave_cycle_extension(obj.NT,fliplr(obj.f_ax),0,0);
                case 'tri'
                    obj.f_ax = [obj.f_ax,fliplr(obj.f_ax(2:end-1))];
                    obj.f_ax = obj.Wave_cycle_extension(obj.NT,obj.f_ax,0,0);
            end
            sigwave = obj.Wave_generator(obj.theta);
            obj.sigwave = [sigwave,zeros(1,length(obj.t)-length(sigwave))];
        end
        function FMCW_plot(obj)
            figure('Name','FMCW');
            % obj.fig_number = obj.fig_number + 1;
            % disp(obj.fig_number);
            plot(obj.t,real(obj.sigwave));
            axis([obj.t1,obj.t2,-1.1,1.1]);
            title('$FMCW\ in\ Time\ Domain$','FontSize', ...
                7,'Interpreter','latex');
            pause(0.001);
        end
    end
    methods (Access = private)  
        % 循环写法，需要预分配内存以加速 10.087  1.123 2.642 2.221
        % function t = timeline_span(~,single_t,T,k)
        %     t = single_t;
        %     for i = 1:k
        %         t = [t,single_t + i*T];
        %     end
        % end

        % 递归写法,运行速度和循环写法差不多 10.329  1.112 2.587 2.244
        % function t = timeline_span(obj,single_t,T,i)
        %     if i ~= 0
        %         t = obj.timeline_span(single_t,T,i-1);
        %         t = [t,single_t + i*T];
        %     else
        %         t = single_t;
        %     end
        % end

        % 预分配内存的循环写法 10.139  1.082 2.039 1.685 最快无疑！
        function t = timeline_span(~,single_t,T,k)
            N = length(single_t);
            t = zeros(1,(k+1)*N);
            for i = 0:1:k
                t(1+i*N:(i+1)*N) = single_t + i*T;
            end
        end
    end
    methods (Static)
        function obj = FMCW_Rebuild(obj)
            arguments
                obj (1,1) {mustBeA(obj,'Radarbox.FMCW_Wave')}
            end 
            obj = obj.FMCW_sigwave();
        end
    end
end