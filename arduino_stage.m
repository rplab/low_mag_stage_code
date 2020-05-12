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
           parse(p, varargin{:});
           for n = 1:numel(p.Parameters)
               obj.(p.Parameters{n}) = p.Results.(p.Parameters{n});
           end
           
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