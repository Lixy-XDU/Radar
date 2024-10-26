classdef Noise
    %NOISE 生成各种噪声，并可输入信号序列与信噪比从而实现加噪。
    %   
    properties
        mu      % Mean
        sigma   % Standard Deviation
        noise_seq
    end
    
    methods
        function obj = Noise(mu,sigma)
            %NOISE 构造此类的实例
            %   此处显示详细说明
            obj.mu = mu;
            obj.sigma = sigma;
        end
        
        function obj = Noise_GW(obj,seq,SNR)
            %NOISE_GW Gaussian White Noise
            %   此处显示详细说明
            arguments
                obj (1,1) {mustBeA(obj,'Radarbox.Noise')} 
                seq (1,:)
                SNR (1,1)
            end
            obj = obj.Deal(seq,SNR);
            obj.noise_seq = obj.mu + obj.sigma * randn(1,size(seq,2));
        end
        function obj = Noise_R(obj,seq,SNR)
            %NOISE_R Rayleigh Noise
            arguments
                obj (1,1) {mustBeA(obj,'Radarbox.Noise')} 
                seq (1,:)
                SNR (1,1)
            end
            obj = obj.Deal(seq,SNR);
            N = size(seq,2);
            X = randn(1,N);
            Y = randn(1,N);
            obj.noise_seq = obj.sigma*sqrt(X.^2+Y.^2);
            % Reconstitution mu & sigma
            obj.mu = sqrt(pi/2)*obj.sigma;
            obj.sigma = (4-pi)*obj.sigma^2/2;
        end
    end
    methods (Access = private)
        function obj = Deal(obj,seq,SNR)
            [Edc,Eac] = Radarbox.Noise.Power(seq);
            [Nmu,Var] = Radarbox.Noise.Noise_Var(Edc,Eac,SNR);
            obj.mu = Nmu;
            obj.sigma = sqrt(Var);
        end
    
    end
    methods (Static)
        function [seq_an,Var] = Noise_add(seq,NoiseType,SNR,mu,sigma)
            %NOISE_ADD This function serves outside.
            arguments
                seq (1,:)
                NoiseType (1,1)
                SNR (1,1) = 10
                mu  (1,1) = 0
                sigma   (1,1) = 0
            end
            nobj = Radarbox.Noise(mu,sigma);
            switch NoiseType
                case Radarbox.Type.NoiseType.Gauss
                % case 1
                    nobj = nobj.Noise_GW(seq,SNR);
                case Radarbox.Type.NoiseType.Rayleigh
                % case 2
                    nobj = nobj.Noise_R(seq,SNR);
            end
            Var = nobj.sigma^2;
            seq_an = seq + nobj.noise_seq;
        end
        function [Edc,Eac] = Power(seq)
            arguments
                seq (1,:)
            end
            N = size(seq,2);
            Edc = mean(seq)^2/N;
            Eac = sum(seq.^(2),"all")/N - Edc;
        end
        function [Nmu,Var] = Noise_Var(Edc,Eac,SNR)
            Var = 10^(-SNR/10)*Eac;
            Nmu = sqrt(10^(-SNR/10)*Edc);
        end
    end
end

