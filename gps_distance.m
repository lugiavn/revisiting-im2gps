function d = gps_distance(lat1, long1, lat2, long2)
%GPS_DISTANCE return distance in meter
%   Detailed explanation goes here


    delta_long = -(long1 - long2);
    delta_lat = -(lat1 - lat2);
    a = sind(delta_lat/2) ^ 2 + cosd(lat1) * cosd(lat2) * (sind(delta_long/2)^2);
    c = 2 * atan2(sqrt(a), sqrt(1-a));
    R = 6371;
    d = R * c;
end

