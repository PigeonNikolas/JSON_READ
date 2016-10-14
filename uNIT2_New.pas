unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,System.JSON,StrUtils;

    const cmdArray : Array [ 0..13 ] of String = (
  'id',
  'agentId',
  'name',
  'shortName',
  'address',
  'addressNotes',
  'location',
  'phone',
  'country',
  'region',
  'metro',
  'workingSchedule',
  'currencies',
  'operations');


type
  TCurrencies = array of string;

  Tlink =record
    self:string;
    country:string;
  end;

  TCountry = record
    ID:string;
    Name:string;
    _link:Tlink;
  end;

  TCoordinates = record
    lat:string;
    lon:string;
    zoom:string;
  end;

  Toperations = record
    _type:string;
    name:string;
  end;

  TReg = record
     ID:string;
     CountryID:string;
     Name:string;
     Subway:string;
     _links:Tlink;
   end;

  TWorking_Hours = Record
    weekday:string;
    date:string;
    open:string;
    close:string;
  End;

  TWorkingShedule = record
    OpenNow:string;
    timezoneId:string;
    Working_Hours:array of TWorking_Hours;
    Working_HoursNotes:String
  end;

  Tmetro = record
    MetroID    :string;
    MetroName   :string;
  end;

  TItem = record
    ID:string;
    agentID :string;
    name  :string;
    Shortname :string;
    address  :string;
    addressNotes:string;
    location  :TCoordinates;
    phone     :string;
    country   :TCountry;
    Region    :TReg;
    WorkingSchedule:TWorkingShedule;
    metro : TMetro;
    Currencies : TCurrencies;
    Operations: array of TOperations;
    notes:string;
    _links:TLink;
  end;

  TPoints = array of TItem;

  TForm2 = class(TForm)
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    Location: TEdit;
    Radius: TEdit;
    MaxNumber: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
     FJSONObject: TJSONObject;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  i:integer;
  s:string;
  FJSONObject:TJSONObject;
  FJSONArray: TJSONArray;

  FJSONObjectIn:TJSONObject ;
  FJSONArrayIn: TJSONArray;
implementation

{$R *.dfm}



Procedure ReadJSONValue(s:string; var Points:TPoints);
var i,j,k,m:integer;
  FJSONArrayInIn: TJSONArray;
  FJSONPAir:TJSONPAir;
  FJSONObject:TJSONObject;
  FJSONArray: TJSONArray;
  FJSONObjectIn:TJSONObject ;
  FJSONArrayIn: TJSONArray;
begin
i:=0;
k:=0;
j:=0;
m:=0;
FJSONObject:=TJSONOBject.ParseJSONValue(s) as TJSONOBject;
setlength(Points, StrToInt(FJSONObject.Pairs[0].JsonValue.Value));  // Ѕудем извращатьс€ и нумеровать будем не с единицы
FJSONPair:=FJSONObject.Pairs[1];
FJSONArray:=FJSONObject.Values['items'] as TJSONArray;
for i:=0 to StrToInt(FJSONObject.Pairs[0].JsonValue.Value) do
begin
FJSONObject:=FJSONArray.Items[i] as TJSONObject;      //Ѕерем i-ый элемент исходного массива JSON и расматриваем его
  For j := 0 to FJSONObject.Count-1 do
  case AnsiIndexStr(VarToStr(FJSONObject.Pairs[j].JsonString.Value),cmdArray) of                  //—мотрим как называетс€ пара

  0:    Points[i].ID:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  1:    Points[i].agentID:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  2:    Points[i].name:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);          // ¬ самом простом случае напр€мую считываем значение в переменную
  3:    Points[i].Shortname:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  4:    Points[i].address:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  5:    Points[i].addressNotes:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  6:    begin       //≈сли же полученна€ вещь - массив, то ни чего не остаетс€ как обрабатывать его как массив

        FJSONObjectIn:=FJSONObject.GetValue('location') as TJSONObject;

        Points[i].location.lat:=VarToStr(FJSONObjectIn.Pairs[0].JSONValue.Value);
        Points[i].location.lon:=VarToStr(FJSONObjectIn.Pairs[1].JSONValue.Value);
        Points[i].location.zoom:=VarToStr(FJSONObjectIn.Pairs[2].JSONValue.Value) ;

      end;
  7:    Points[i].phone:=VarToStr(FJSONObject.Pairs[j].JsonValue.Value);
  8:    begin

        FJSONObjectIn:=FJSONObject.getValue('country') as TJSONObject;
        Points[i].country.ID:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
        Points[i].country.Name:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);

        end;
  9:   begin
        FJSONObjectIn:=FJSONObject.getValue('region') as TJSONObject;
        Points[i].Region.ID:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
        Points[i].Region.CountryID:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);
        Points[i].Region.Name:=VarToStr(FJSONObjectIn.Pairs[2].JsonValue.Value);
        Points[i].Region.Subway:=VarToStr(FJSONObjectIn.Pairs[3].JsonValue.Value);
  end;



  10:   begin
        k:=0;
        FJSONArrayIn:=FJSONObject.GetValue('metro') as TJSONArray;
        while k<FJSONArrayIn.Count-1 do
          begin

          FJSONObjectIn:=FJSONArrayIn.Items[k] as TJSONObject;
          Points[i].metro.MetroID:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
          Points[i].metro.MetroName:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);
          k:=k+1;

          end;
        end;


  11:   begin
        FJSONOBjectIn:=FJSONOBject.GetValue('workingSchedule') as TJSONObject;

        Points[i].WorkingSchedule.OpenNow:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
        Points[i].WorkingSchedule.timezoneId:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);
        Points[i].WorkingSchedule.Working_HoursNotes:=VarToStr(FJSONObjectIn.Pairs[3].JsonValue.Value);

        FJSONArrayIn:= FJSONOBjectIn.GetValue('workingHours') as TJSONArray;
        setlength(Points[i].WorkingSchedule.Working_Hours,FJSONArrayIn.Count);
        while k<FJSONArrayIn.Count-1  do
          begin
          FJSONOBjectIn:=FJSONArrayIn.Items[k] as TJSONObject;
          Points[i].WorkingSchedule.Working_Hours[k].weekday:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
          Points[i].WorkingSchedule.Working_Hours[k].date:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);
          Points[i].WorkingSchedule.Working_Hours[k].open:=VarToStr(FJSONObjectIn.Pairs[2].JsonValue.Value);
          Points[i].WorkingSchedule.Working_Hours[k].close:=VarToStr(FJSONObjectIn.Pairs[3].JsonValue.Value);
          k:=k+1
          end;

      end;
 12:  begin
      FJSONArrayIn:= FJSONOBject.GetValue('currencies') as TJSONArray;
      SetLength(Points[i].Currencies,FJSONArrayIn.Count);
      for k := 0 to FJSONArrayIn.Count-1 do
        Points[i].Currencies[k]:=FJSONArrayIn.Items[k].Value

      end;


 13:  begin
      FJSONArrayIn:= FJSONOBject.GetValue('operations') as TJSONArray;
      setlength(Points[i].Operations, FJSONArrayIn.Count);
      for k := 0 to FJSONArrayIn.Count-1 do
          begin
          FJSONObjectIn:=FJSONArrayIn.Items[k] as TJSONObject;
          Points[i].Operations[k]._type:=VarToStr(FJSONObjectIn.Pairs[0].JsonValue.Value);
          Points[i].Operations[k].name:=VarToStr(FJSONObjectIn.Pairs[1].JsonValue.Value);
          end;
      end;


   end;
  end;
end;

procedure TForm2.Button1Click(Sender: TObject);
var Points:TPoints;
begin
  s:='https://info.api.unistream.com/api/v1/poses/search?location='+location.text+'&radius='+radius.text+'&maxResults='+maxNumber.text;
  s:=IdHTTP1.Get(s);
  ReadJSONValue(s,Points);
  end;

procedure TForm2.Button2Click(Sender: TObject);
begin
if i<FJSONObject.Count-1 then
begin
  if (VarToStr(FJSONObject.Pairs[i].JsonValue.Value)<>'') then
  edit1.text:=VarToStr(FJSONObject.Pairs[i].JsonString.Value)+'    '+VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  i:=i+1
end
else
if i<FJSONObject.Count-1 then
ShowMessage('JSON is over')

end;

end.
