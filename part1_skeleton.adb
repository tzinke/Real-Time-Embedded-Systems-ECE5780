-- File: part1.adb
with Ada.Text_IO;
use  Ada.Text_IO;

with Text_Io;
use  Text_Io;

with Ada.Calendar;
use  Ada.Calendar;

procedure Part1  is

  vTime, F1_Start, F1_Curr, F2_Curr, F3_Start, F3_Curr, Before, After: Duration;
  Drift : Duration := 0.0;

  package DIO is new Text_Io.Fixed_Io(Duration);  --To print Duration variables you can instantiate the generic
                                                    --package Text_Io.Fixed_Io with a duration type:
                                                    --"package DIO is new Text_Io.Fixed_Io(Duration);"
                                                    --The DIO package will then export, among other things,
                                                    --the procedure DIO.Put(D:Duration, Fore:Field, Aft:Field)
                                                    --to print variable D of type Duration. See an example
                                                    --on how to use this below.

    --Declare F1, which prints out a message when it starts and stops executing
  procedure F1(Currtime: Duration; StartF1: Duration; FinishF1: Duration) is
  begin
    if StartF1 = 0.0 and then FinishF1 = 0.0 then
      Put_Line("");  --Add a new line
      Put_Line("F1 has started executing. The time is now:");
      DIO.Put(Currtime);
    else
      Put_Line("");
      Put_Line("F1 has finished executing. The time is now:");
      DIO.Put(Currtime + (FinishF1 - StartF1)); --Needed since time starts at 0 and FinishF1 and StartF1 are not virtual times
    end if;
  end F1;

  -- Declare F2
  procedure F2(Currtime: Duration; FinishF1: Duration; FinishF2: Duration) is
  begin
    if FinishF1 = 0.0 and then FinishF2 = 0.0 then
        Put_Line("");  --Add a new line
        Put_Line("F2 has started executing. The time is now:");
        DIO.Put(Currtime);
    else
        Put_Line("");
        Put_Line("F2 has finished executing. The time is now:");
        DIO.Put(Currtime + (FinishF2 - FinishF1)); --Needed since time starts at 0 and FinishF1 and StartF1 are not virtual times
    end if;
  end F2;

  -- Declare F3
  procedure F3(Currtime: Duration; StartF1: Duration; FinishF3: Duration) is
  begin
    if StartF1 = 0.0 and then FinishF3 = 0.0 then
        Put_Line("");  --Add a new line
        Put_Line("F3 has started executing. The time is now:");
        DIO.Put(Currtime);
    else
        Put_Line("");
        Put_Line("F3 has finished executing. The time is now:");
        DIO.Put(Currtime + (FinishF3 - StartF1)); --Needed since time starts at 0 and FinishF1 and StartF1 are not virtual times
    end if;
  end F3;

  begin
    vTime := 0.0;
    Before := Ada.Calendar.Seconds(Ada.Calendar.Clock);
    --Main loop
    loop

      -- 1 second hyperperiod
      loop
        After := Ada.Calendar.Seconds(Ada.Calendar.Clock);
        if Drift /= 0.0 then
          Put_Line("");
          Put_Line("Correcting drift: value is currently: ");
          DIO.Put(Drift);
          Put_Line("");
        end if;
        exit when After - Before >= (1.000000000 - Drift);
      end loop;

      vTime := vTime + (After - Before); --Needed since time starts at 0
      F1_Start := Ada.Calendar.Seconds(Ada.Calendar.Clock); --Get start time of F1

      F1(Currtime => vTime, StartF1 => 0.0, FinishF1 => 0.0); --Initialize F1
      loop --F1 starts
        F1_Curr := Ada.Calendar.Seconds(Ada.Calendar.Clock);
        exit when  F1_Curr - F1_Start >= 0.3000; --Assuming F1 takes 0.3 seconds
      end loop; --F1 ends
      --After F1 finishes executing, call the F1 procedure again to obtain the finish time
      F1(Currtime => vTime, StartF1 => F1_Start, FinishF1 => F1_Curr);

      F2(Currtime => vTime + (F1_Curr - F1_Start), FinishF1 => 0.0, FinishF2 => 0.0);
      loop --F2 starts
        F2_Curr := Ada.Calendar.Seconds(Ada.Calendar.Clock);
        exit when F2_Curr - F1_Curr >= 0.1500;  -- Assuming F2 takes 0.15 seconds
      end loop;
      F2(Currtime => vTime + (F1_Curr - F1_Start), FinishF1 => F1_Curr, FinishF2 => F2_Curr);

      -- Wait for 0.5s to pass after F1_Start
      loop
        F3_Start := Ada.Calendar.Seconds(Ada.Calendar.Clock);
        exit when F3_Start - F1_Start >= 0.5000;
      end loop;

      -- Start F3
      F3(Currtime => vTime + (F3_Start - F1_Start), StartF1 => 0.0, FinishF3 => 0.0);
      loop
        F3_Curr := Ada.Calendar.Seconds(Ada.Calendar.Clock);
        exit when F3_Curr - F3_Start >= 0.2000; -- Run F3 for 0.2s
      end loop;
      F3(Currtime => vTime + (F3_Start - F1_Start), StartF1 => F3_Start, FinishF3 => F3_Curr);

      --Drift correction
      if Drift = 0.0 then
        Drift := (After - Before) - 1.00000;
      else
        Drift := 0.0;
      end if;

      Before := After;
    end loop; --Main loop
end Part1;
