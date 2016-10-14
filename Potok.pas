unit Potok;

interface

uses
  System.Classes, ProgressForm;

type
mas = array of real;
  FirstThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

{
  Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure FirstThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end;

    or

    Synchronize(
      procedure
      begin
        Form1.Caption := 'Updated in thread via an anonymous method'
      end
      )
    );

  where an anonymous method is passed.

  Similarly, the developer can call the Queue method with similar parameters as
  above, instead passing another TThread class as the first parameter, putting
  the calling thread in a queue with the other thread.

}

{ FirstThread }

procedure FirstThread.Execute;
var a:mas;
i:longint;
flag:boolean;
begin
flag:=false;
SetLength(a,101);

  for I := 0 to 100 do
   begin
   a[i]:=a[i]+1;
   sleep (30);
   with progress, ProgressBar1 do
   Position:=i;
   end;
  progress.Close;
  end;


end.
