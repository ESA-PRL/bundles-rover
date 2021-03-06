#! /usr/bin/env ruby

require 'rock/bundle'
require 'vizkit'

include Orocos

# Replay a ga_slam.0.log and visualize the output ports

Orocos.run do
    ####### Replay Logs #######
    bag = Orocos::Log::Replay.open('/media/heimdal/Dataset1/logs/20210125-1045/ga_slam.0.log')
    bag.use_sample_time = true


    ####### Vizkit Display #######
    # Vizkit.display bag.ga_slam.estimatedPose,
    #     :widget => Vizkit.default_loader.RigidBodyStateVisualization
    # Vizkit.display bag.ga_slam.estimatedPose,
    #     :widget => Vizkit.default_loader.TrajectoryVisualization

    Vizkit.display bag.ga_slam.mapCloud

    Vizkit.display bag.ga_slam.localElevationMapMean
    Vizkit.display bag.ga_slam.globalElevationMapMean

    ####### Vizkit Replay Control #######
    control = Vizkit.control bag
    control.speed = 1.0
#    control.seek_to 13000 # Nominal
#    control.seek_to 34700 #17181 #34000 #31000 # Nurburing
#    control.seek_to 59000 # Eight Track Dusk
#    control.seek_to 4955 #24000 #15378 # Side Track
    control.bplay_clicked

    ####### ROS RViz #######
    spawn 'roslaunch ga_slam_visualization ga_slam_visualization.launch'
    sleep 3

    ####### Vizkit #######
    Vizkit.exec
end

