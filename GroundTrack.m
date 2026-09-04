%% ========================================================================
%  GPS-OrbitTrack : GPS Satellite Orbits and Ground Tracks
%  ------------------------------------------------------------------------
%  Script  : GroundTrack.m
%  Purpose : Computes and visualizes GPS satellite orbits from two
%            ephemeris sources:
%            1) Precise ephemeris (SP3, igs19440.sp3): 3D orbits of
%               PRN 1-12 and their ground tracks on a world map
%               (ECEF -> geodetic conversion, Mercator projection).
%            2) Broadcast ephemeris (RINEX navigation file,
%               bor10990.17n): parses the Keplerian elements and
%               computes the orbit in the orbital plane by iteratively
%               solving Kepler's equation for the eccentric anomaly.
%  Inputs  : igs19440.sp3, bor10990.17n
%  Requires: Mapping Toolbox (referenceEllipsoid, ecef2geodetic,
%            shaperead, axesm, geoshow, plotm)
%  ------------------------------------------------------------------------
%  NOTE    : In the first section the rotation to the inertial (ECSF)
%            frame is not yet applied (r_inertial = r_ecef), so figure 1
%            actually shows the ECEF orbit; the animation loop shows a
%            single point per satellite; and the orbital-plane section
%            uses only the first broadcast record (be(1)) while the title
%            lists all PRNs. See the repository README (Status section).
%  ------------------------------------------------------------------------
%  Author  : Motahareh Esfandyari-Kaloukan
%  ========================================================================

clear
clc
close all
format long g 

[sph, sp] = sp3Cread ('igs19440.sp3') ;

global w GM
w = 7.2921151467*10^(-5) ;
GM = 3.986004418*1e14 ;

sat = [1:12] ;
for k = 1:size(sp, 2)
    
    x_ecef(k, :) = sp(k).CRD(1, sat).*1000 ;
    y_ecef(k, :) = sp(k).CRD(2, sat).*1000 ;
    z_ecef(k, :) = sp(k).CRD(3, sat).*1000 ;
    
    r_ecef = [x_ecef(k), y_ecef(k), z_ecef(k)]' ;
    
    t = [sp(k).Time(:, 4:6)]*[3600, 60, 1]' ;
    
      r_inertial = r_ecef ;
    
    x_inertial(k, :) = r_inertial(1) ;
    y_inertial(k, :) = r_inertial(2) ;
    z_inertial(k, :) = r_inertial(3) ;
    
end

x_inertial=[x_inertial;x_inertial(1)];
y_inertial=[y_inertial;y_inertial(1)];
z_inertial=[z_inertial;z_inertial(1)];


figure(1);
plot3(x_inertial, y_inertial, z_inertial);


xlabel('ECEF X [m]')
ylabel('ECEF Y [m]')
zlabel('ECEF Z [m]')

title(['Satellite orbit of GPS PRN ', num2str(sat),....
    ' satellite in ECSF reference frame']);

grid on, grid minor

%% ECEF:

ref = referenceEllipsoid('wgs84') ;

[lat, lon, h] = ecef2geodetic(ref, x_ecef, y_ecef, z_ecef) ;

figure(2)
landareas = shaperead('landareas.shp','UseGeoCoords',true);
axesm ('mercator', 'Frame', 'on', 'Grid', 'on');
geoshow(landareas,'FaceColor',[1 1 .5],'EdgeColor',[.6 .6 .6]);
hold on
legend


for iii=1:length(sat)
   plotm([lat(end,iii);lat(:,iii)] ,[lon(end,iii); lon(:,iii)], 'LineWidth', 2,'color', [rand,rand,rand])
   
   
     an = animatedline('Marker','*');    % animation  %showing groundtrack in order of PRN
for k=1:length(iii)
     addpoints(an,lat(k) ,lon(k));
       drawnow
    pause(0.2);
    clearpoints(an);
end
end
title(['Ground track of GPS PRN ' , num2str(sat), ' satellite']);

%% Orbital:

fid = fopen('bor10990.17n') ;

header_line = 8 ;

k = 1 ; j = 1 ;
while ~feof(fid)
    
    if k<=header_line
        txt = fgetl(fid) ;
        k = k + 1 ;
        continue
    else
        for c = 1:8
            if c==1
                
                txt = fgetl(fid) ;
                
                be(j).PRN                 = str2num(txt(1:2)) ;
                be(j).date                = str2num(txt(4:22)) ;
                be(j).SV_clock_bias       = str2num(txt(23:41)) ;
                be(j).SV_clock_drift      = str2num(txt(42:60)) ;
                be(j).SV_clock_drift_rate = str2num(txt(61:79)) ;
                
            elseif c==2
                
                txt = fgetl(fid) ;
                
                be(j).IODE    = str2num(txt(4:22)) ;
                be(j).Crs     = str2num(txt(23:41)) ;
                be(j).Delta_n = str2num(txt(42:60)) ;
                be(j).M0      = str2num(txt(61:79)) ;
                
            elseif c==3
                
                txt = fgetl(fid) ;
                
                be(j).Cuc    = str2num(txt(4:22)) ;
                be(j).e      = str2num(txt(23:41)) ;
                be(j).Cus    = str2num(txt(42:60)) ;
                be(j).Sqrt_A = str2num(txt(61:79)) ;
                
            elseif c==4
                
                txt = fgetl(fid) ;
                
                be(j).Toe   = str2num(txt(4:22)) ;
                be(j).Cic   = str2num(txt(23:41)) ;
                be(j).OMEGA = str2num(txt(42:60)) ;
                be(j).Cis   = str2num(txt(61:79)) ;
                
            elseif c==5
                
                txt = fgetl(fid) ;
                
                be(j).i0        = str2num(txt(4:22)) ;
                be(j).Crc       = str2num(txt(23:41)) ;
                be(j).omega     = str2num(txt(42:60)) ;
                be(j).OMEGA_DOT = str2num(txt(61:79)) ;
                
            elseif c==6
                
                txt = fgetl(fid) ;
                
                be(j).IDOT               = str2num(txt(4:22)) ;
                be(j).Code_on_L2_channel = str2num(txt(23:41)) ;
                be(j).GPS_Week           = str2num(txt(42:60)) ;
                be(j).L2_P_data_flag     = str2num(txt(61:79)) ;
                
            elseif c==7
                
                txt = fgetl(fid) ;
                
                be(j).SV_accuracy = str2num(txt(4:22)) ;
                be(j).SV_health   = str2num(txt(23:41)) ;
                be(j).TGD         = str2num(txt(42:60)) ;
                be(j).IODC        = str2num(txt(61:79)) ;
                
            elseif c==8
                
                txt = fgetl(fid) ;
                
                be(j).Transmission_time_of_message = str2num(txt(4:22)) ;
                be(j).Fit_interval                 = str2num(txt(23:41)) ;
                be(j).spare1                       = str2num(txt(42:60)) ;
                be(j).spare2                       = str2num(txt(61:79)) ;
                
            end
        end
        j = j + 1 ;
        k = k + 1 ;
    end
end
fclose(fid) ;

BE = be(1) ;

t0 = BE.Toe ; % Sec

A = BE.Sqrt_A^2 ;
n0 = sqrt(GM/A^3) ;
n = n0 + BE.Delta_n ;
e = BE.e ;

k = 1 ;
for t = 0:900:86400
    
    tk = t - t0 ;
    Mk = BE.M0 + n*tk ;
    E0 = Mk ;
    Error = 1 ;
    while Error>0.0001
        Ek = Mk + e*sin(E0) ;
        Error = abs(Ek-E0) ;
        E0 = Ek ;
    end
    %vk = acos((cos(Ek) - e)/(1 - e*cos(Ek))) ;
    cos_v = (cos(Ek) - e)/(1 - e*cos(Ek)) ;
    sin_v = sqrt(1 - e^2)*sin(Ek)/(1 - e*cos(Ek)) ;
    
    vk = atan2(sin_v, cos_v) ;
    v(k, :) = vk ;
    PHIk = vk + BE.omega ;
    uk = PHIk ;
    rk = A*(1 - e*cos(Ek)) ;
    
    X_orbital(k, :) = rk*cos(uk) ;
    Y_orbital(k, :) = rk*sin(uk) ;
    
    k = k + 1 ;
    
end

figure(3)

plot(X_orbital, Y_orbital, 'm')

xlabel('Orbital X [m]')
ylabel('Orbital Y [m]')

title(['Satellite orbit of GPS PRN ', num2str(BE.PRN),....
    ' satellite in orbital plane']) ;

grid on, grid minor
