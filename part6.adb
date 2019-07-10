-- File: part6.adb
-- Written by Taylor Zinke and Jarrett Sorensen

with Ada.Text_IO;
use  Ada.Text_IO;
with Text_Io;
use  Text_Io;
with Ada.Calendar;
use  Ada.Calendar;
with Ada.Numerics.Discrete_Random;
with Ada.Task_Identification;
use Ada.Task_Identification;

procedure Part6 is

    package DIO is new Text_Io.Fixed_Io(Duration);

    subtype numRand is Integer range 0 .. 25;
    package Random_Gen is new
        Ada.Numerics.Discrete_Random(numRand);
    use Random_Gen;
    G: Random_Gen.Generator; -- Produces random int from 0 to 25

    task FIFO is -- "Buffer" task
        entry stop;
        entry Get(Item: out Integer);
        entry Put(Item: in Integer);
    end FIFO;

    task body FIFO is
        type Buffer is array (0 .. 9) of Integer; --Array of 10 integers.
        Queue : Buffer;
        ConsInd, ProdInd : Integer := 0; -- Keep two indices for removal and insertion

    begin
        loop -- Set all array values to -1 to signify that each slot is empty
            Queue(ConsInd) := -1;
            ConsInd := ConsInd + 1;
            exit when ConsInd = 10;
        end loop;
        ConsInd := 0;
        Put_Line("FIFO initialized");

        loop
            select
                when Queue(ConsInd) /= -1 => -- if current index is -1, then queue is empty
                    accept Get(Item: out Integer) do
                        --Send Queue(ConsInd) to Consumer, set it to -1, and increase/reset ConsInd
                        Item := Queue(ConsInd);
                        Queue(ConsInd) := -1;
                        ConsInd := (ConsInd + 1) mod 10; -- mod 10 to wrap-around
                    end Get;
            or
                when Queue(ProdInd) = -1 => -- Queue is full if current index is not -1
                    accept Put(Item: in Integer) do
                        -- Set Queue(ProdInd) to Item, increase/reset ProdInd
                        Queue(ProdInd) := Item;
                        ProdInd := (ProdInd + 1) mod 10; -- mod 10 to wrap-around
                    end Put;
            or
                accept stop;
                Put_Line("FIFO terminating");
                exit;
            end select;
        end loop;
    end FIFO;

    task Producer is
        entry stop;
    end Producer;

    task body Producer is
        Rand25 : numRand;
    begin
        Put_Line("Producer initialized");
        loop
            select
                accept stop;
                Put_Line("Producer terminating");
                exit;
            else
                Rand25 := Random(G);
                if Rand25 < 3 then -- The acceptance condition here is more frequently met
                                   -- than that of the consumer.
                    delay Duration(Rand25); -- causes irregular intervals
                    Rand25 := Random(G); -- need new int to include everything over 6 in queue
                    FIFO.Put(Rand25);
                    Put(Integer'Image(Rand25));
                    Put_Line(" added to queue.");
                    Put_Line("");
                end if;
            end select;
        end loop;
    end Producer;

    task Consumer is
    end Consumer;

    task body Consumer is
        sum, num: Integer := 0;
        Rand25 : numRand;
    begin
        Put_Line("Consumer initialized");
        delay Duration(0.25); -- Without this, consumer would occasionally consume
                              -- before buffer was initialized to all -1 and
                              -- prematurely terminate program.
        loop
            Rand25 := Random(G);
            if Rand25 < 5 then
                delay Duration(Rand25); -- causes irregular intervals
                FIFO.Get(num);
                Put(Integer'Image(num));
                Put_Line(" removed from queue.");
                Put_Line("");
                sum := sum + num;
                if sum >= 100 then
                    Producer.stop;
                    loop
                        null;
                        exit when Producer'Terminated;
                    end loop;
                    FIFO.stop;
                    Put("The sum has reached ");
                    Put(Integer'Image(sum));
                    Put_Line("");
                    Put_Line("Consumer terminating");
                    exit;
                else
                    Put("The sum is now ");
                    Put_Line(Integer'Image(sum));
                    Put_Line("");
                end if;
            end if;
        end loop;
    end Consumer;

begin
    Reset(G);
end Part6;
