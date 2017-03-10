% returns the minimum/maximum values for Gazebo params
function [ gazebo_params ] = GazeboParamsBoundaries(  )
    gazebo_params.MIN_INERTIA = 0.00001;
    gazebo_params.MIN_MASS = 0.01;
end

