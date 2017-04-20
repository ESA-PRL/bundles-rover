#! /usr/bin/env ruby

require 'orocos'
require 'rock/bundle'
require 'readline'
require 'orocos/log'
require 'vizkit'

include Orocos
Bundles.initialize

Orocos.run 'tmtc_mock::Task' => 'tmtc_mock',
           'dem_generation::Task' => 'dem_generation',
           'camera_trigger::Task' => 'trigger',
           'camera_firewire::CameraTask' => 'pancam_left',
           'camera_firewire::CameraTask' => 'pancam_right',
           'stereo::Task' => 'stereo_pancam' do

    #Orocos.log_all

    # open log file to be postprocessed
    if ARGV.size == 0 then
        log_replay = Orocos::Log::Replay.open( "pancam.log") 
    else
        log_replay = Orocos::Log::Replay.open( ARGV[0]+"pancam.log") 
    end

    # get services
    tmtc_mock = Orocos.name_service.get 'tmtc_mock'

    dem_generation = Orocos.name_service.get 'dem_generation'
    Orocos.conf.apply(dem_generation, ['panCam'], :override => true)

    stereo_pancam = Orocos.name_service.get 'stereo_pancam'
    Orocos.conf.apply(stereo_pancam, ['panCam'], :override => true)

    #pancam_left = Orocos.name_service.get 'pancam_left'
    #pancam_right = Orocos.name_service.get 'pancam_right'

    trigger = Orocos.name_service.get 'trigger'

    # connect
    tmtc_mock.telecommand_out.connect_to        trigger.telecommand_in
    #pancam_left.frame.connect_to                trigger.frame_left_in
    #pancam_right.frame.connect_to               trigger.frame_right_in
    log_replay.pancam_panorama.left_frame_out.connect_to  trigger.frame_left_in
    log_replay.pancam_panorama.right_frame_out.connect_to trigger.frame_right_in
    trigger.frame_left_out.connect_to           stereo_pancam.left_frame
    trigger.frame_right_out.connect_to          stereo_pancam.right_frame
    trigger.frame_left_out.connect_to           dem_generation.left_frame_rect
    stereo_pancam.distance_frame.connect_to     dem_generation.distance_frame
    stereo_pancam.left_frame_sync.connect_to    dem_generation.left_frame_rect
    stereo_pancam.right_frame_sync.connect_to   dem_generation.right_frame_rect
    trigger.telecommands_out.connect_to         dem_generation.telecommands_in

    # configure
    trigger.configure
    #pancam_left.configure
    #pancam_right.configure
    stereo_pancam.configure
    dem_generation.configure
    tmtc_mock.configure

    # start
    tmtc_mock.start
    #pancam_left.start
    #pancam_right.start
    trigger.start
    stereo_pancam.start
    dem_generation.start

    Vizkit.control log_replay
    Vizkit.exec

    Readline::readline("Press ENTER to exit\n")

    # stop
    tmtc_mock.stop
    #pancam_left.stop
    #pancam_right.stop
    trigger.stop
    stereo_pancam.stop
    dem_generation.stop
end
