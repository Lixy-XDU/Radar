classdef ASK_Code < Radarbox.Encoder
    %ASK_CODE 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        sigwave
        amp = 1   % 幅度单元
    end
    
    methods
        function obj = ASK_Code(Code,t,Fr,sigwave,amp)
            %ASK_CODE 构造此类的实例
            %   此处显示详细说明
            arguments
                Code    (1,:) {mustBeNumericOrLogical}
                t       (1,:) {mustBeNumeric}
                Fr      (1,1) {mustBeNumeric}
                sigwave (1,:) {mustBeNumeric}
                amp     (1,1) {mustBeNumeric}
            end
            obj = obj@Radarbox.Encoder(Code,t,Fr);
            obj.sigwave = sigwave;
            obj.amp = amp;
        end
        
        function ASKsig = ASK(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            ASKsig = obj.sigwave.*obj.ct*obj.amp;
        end
    end
end

