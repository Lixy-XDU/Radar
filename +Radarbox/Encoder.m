classdef Encoder
    %ENCODER 编码器
    %   此处显示详细说明

    properties
        Code
        t       % 时间轴
        fs      % 采样率
        Fr      % 重频
        ct      % 时域码波形
        % N       % 码长
    end

    methods
        function obj = Encoder(Code,t,Fr)
            %ENCODER 构造此类的实例
            %   此处显示详细说明
            arguments
                Code (1,:) {mustBeNumericOrLogical}
                t    (1,:) {mustBeNumeric}
                Fr   (1,1) {mustBeNumeric}
            end
            obj.Code = Code;
            obj.t = t;
            obj.Fr = Fr;
            obj.fs = 1/(t(2)-t(1));
            obj.ct = Code_generator(obj);
            % obj.N = N;
        end

        function ct = Code_generator(obj)
            %Code_generator 时域码波形产生器
            %   此处显示详细说明
            N = ceil(obj.fs/obj.Fr);
            ct = zeros(1,length(obj.t));
            for i = 1:length(obj.Code)
                ct(1+(i-1)*N:i*N) = obj.Code(i);
            end
        end
    end

    methods (Static)
        function cd = Code_rand_01sequence(N)
            %Code_rand_01sequence 随机01序列生成器
            cd = rand(1,N) > 0.5;
        end

        function cd = Code_Barker(N)
            % arguments
            %     N (1,1) int {mustBeMember(N,{2,3,4,5,7,11,13})}
            % end
            switch N
                case 2
                    cd = [1,-1];
                case 3
                    cd = [1,1,-1];
                case 4
                    cd = [1,1,-1,1];
                case 5
                    cd = [1,1,1,-1,1];
                case 7
                    cd = [1,1,1,-1,-1,1,-1];
                case 11
                    cd = [1,1,1,-1,-1,-1,1,-1,-1,1,-1];
                case 13
                    cd = [1,1,1,1,1,-1,-1,1,1,-1,1,-1,1];
                otherwise
                    error('No such Barker code.');
            end
        end
    end
end

