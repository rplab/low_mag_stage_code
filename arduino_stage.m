% Program:  arduino_stage.m
%
% Summary:  This is a class for communicating with an arduino-controlled stage
%           built for a low-magnification microscope. Both hardware and
%           software are currently under construction. The design involves
%           an Arduino Uno and the Adafruit v2 Motor Shield, which drives 2 
%           stepper motors. This class combines the objects for the
%           arudino, the motor shield, and the stepper motors, making them
%           properties, and implements a function for moving the stage to a
%           specified position.
%
% Properties:   a - arduino class
%               shield - shield class
%               stepperX, stepperY - stepper motor classes
%               position - 1x2 array that stores the current [X,Y]
%                          positions in units of mm.
%               mm_per_step - (int) number of mm per step of the motor.
%                           estimated, for example, by dividing the shaft
%                           thread spacing by the number of steps per
%                           revolution of the motor.
%               COMport - (str) COM port for the arduino
%               XY_motor_ids - 1x2 int array that specifies which motor on
%                           the board is the X axis and which is the Y.
%
% Dependencies: This class requries Matlab's Arduino support package, as 
%               as the specific library for the Adafruit v2 Motor Shield. 
%
% Usage:    
%           stage = arudino_stage(OPTIONS); where OPTIONS are optional
%               stage parameters that are specified with the inputParser
%               syntax. OPTIONS currently include position, mm_per_step,
%               COMport, and XY_motor_ids. Calling this constructor
%               initializes the arudino objects, which can also be set
%               manually.
%
%           stage = stage.METHOD(OPTIONS) where METHOD is a method that
%               modifies a stage property. Ex:
%
%                   stage = stage.moveto([1000,500]);
%
%               moves the stage to [X,Y] = [1000,500] and then updates the
%               position property.
%
% TODO:     -X and Y movements might want to be interleaved ("diagonal
%               motion")
%           -Error handling
%           -Test with actual 2D system (only 1 axis so far).
%           -Implement limit switches
%
% Author:   Brandon Schlomann
%
% Date:     5/12/20 -- first written
%
% VCS:      Parthasarathy lab github: low_mag_stage_code repository
%

classdef arduino_stage
    
   properties
       a;
       shield;
       stepperX;
       stepperY;
       position = [0,0];
       mm_per_step = 0.05;
       COMport = 'COM3';
       XY_motor_ids = [1,2];
   end
   
   methods
       % constructor
       function obj = arduino_stage(varargin)
           % parse input
           p = inputParser;
           addParameter(p, 'COMport', obj.COMport);
           addParameter(p, 'XY_motor_ids', obj.XY_motor_ids);
           addParameter(p, 'mm_per_step', obj.mm_per_step);
           addParameter(p, 'position', obj.position);
           addParameter(p, 'init_arduino', false);
           parse(p, varargin{:});
           [~,overlap_ids,~] = intersect(p.Parameters,properties(obj));
           for n = 1:numel(overlap_ids)
               obj.(p.Parameters{overlap_ids(n)}) = p.Results.(p.Parameters{overlap_ids(n)});
           end
           
           if p.Results.init_arduino
               % initial params that are not properties
               RPM = 300;
               steps_per_rev = 200;
               
               % initialize arduino objects
               obj.a = arduino(obj.COMport,'Uno','Libraries','Adafruit\MotorShieldV2');
               obj.shield = addon(obj.a,'Adafruit\MotorShieldV2');
               obj.stepperX = stepper(obj.shield,obj.XY_motor_ids(1),steps_per_rev);
               obj.stepperX.RPM = RPM;
               obj.stepperY = stepper(obj.shield,obj.XY_motor_ids(2),steps_per_rev);
               obj.stepperY.RPM = RPM;
           end
           
       end
       
       function obj = moveto(obj,new_position)
           num_steps_to_move = round((new_position - obj.position)./obj.mm_per_step);
           
           % move x
           move(obj.stepperX,num_steps_to_move(1));
           
           % move y
           move(obj.stepperY,num_steps_to_move(2));
           
           % update position
           obj.position = new_position;

       end
       
       function obj = zero(obj)
           
           obj.position = [0,0];
           
       end
       
   end
       
    
    
end