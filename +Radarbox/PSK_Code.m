classdef PSK_Code < Radarbox.Encoder
    %PSK_CODE 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        sigwave
        phi     % 相位单元
    end
    
    methods
        function obj = PSK_Code(Code,t,Fr,sigwave,phi)
            %PSK_CODE 构造此类的实例
            %   此处显示详细说明
            arguments
                Code    (1,:) {mustBeNumericOrLogical}
                t       (1,:) {mustBeNumeric}
                Fr      (1,1) {mustBeNumeric}
                sigwave (1,:) {mustBeNumeric}
                phi     (1,1) {mustBeNumeric}
            end
            obj = obj@Radarbox.Encoder(Code,t,Fr);
            obj.sigwave = sigwave;
            obj.phi = phi*pi/180;
        end
        
        function PSKsig = PSK(obj)
            %METHOD1 此处显示有关此方法的摘要
            %   此处显示详细说明
            PSKsig = obj.sigwave.*exp(1j*obj.ct*obj.phi);
        end
    end
end

