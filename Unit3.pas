unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  Menus, StdCtrls, cxButtons, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, US_Info_Points_of_Delivery, ExtCtrls,  DBXJSON,
  DBXJSONReflect,DBXJSONCommon,IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,StrUtils,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, dxSkinscxPCPainter;

  const cmdArray : Array [ 0..13 ] of String = (
  'name',
  'address',
  'phone',
  'workingSchedule',
  'Operations',
  'type',
  'openNow',
  'timeZoneId',
  'workingHours',
  'weekday',
  'date',
  'open',
  'close',
  'workingHoursNotes');

type


  TAddress = class(TForm)
    Panel1: TPanel;
    grNearestPointsDBTableView1: TcxGridDBTableView;
    grNearestPointsLevel1: TcxGridLevel;
    grNearestPoints: TcxGrid;
    MoreInformation: TcxButton;
    IdHTTP1: TIdHTTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    procedure MoreInformationClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

 //   TCurrencies = array of string;

 { Tlink =record
    self:string;
    country:string;
  end;  }

 { TCountry = record
    ID:string;
    Name:string;
    _link:Tlink;
  end;  }

 { TCoordinates = record
    lat:string;
    lon:string;
    zoom:string;
  end;  }

  Toperations = record
    _type:string;
    name:string;
  end;

 { TReg = record
     ID:string;
     CountryID:string;
     Name:string;
     Subway:string;
     _links:Tlink;
   end;  }

  TWorking_Hours = Record
    weekday:string;
    date:string;
    open:string;
    close:string;
  End;

  TWorkingShedule = record
    OpenNow:string;
    timezoneId:string;
    Working_Hours:array of TWorking_hours;
    Working_HoursNotes:String
  end;

  Tmetro = record
    MetroID    :string;
    MetroName   :string;
  end;

  TItem = record

//    ID:string;
//    agentID :string;                                  // Здесь закоментированы такие переменные, которые не нужны в дальнейшей
//    Shortname :string;                               // программе, но существуют в get-запросе.
//    addressNotes:string;                              // Вдруг кому-то понадобятся
//    location  :TCoordinates;
//    country   :TCountry;
//    Region    :TReg;
//    _links:TLink;
//    metro : TMetro;
//    Currencies : TCurrencies;

    name  :string;
    address  :string;
    phone     :string;
    WorkingSchedule :TWorkingShedule;
    Operations: array of TOperations;
    notes:string;

  end;

  TPoints = array of TItem;

  uStackPair = ^StackPair;

  StackPair = record
      FJSONPair:TJSONPair;
      FJSONPairPrevious:UStackPair;
  end;

var
  Address: TAddress;
  info:TUnit_Info;
  FJsonValue:TJSONValue;
  Points:TPoints;
  FJSONObject:TJSONObject;
  FJSONArray: TJSONArray;
  FJSONPair:TJSONPair;

implementation

{$R *.dfm}

Procedure Push(Pair:TJSONPair; var Pairs:UStackPair);

var
x:UStackPair;

begin
New(x);
x^.FJSONPair:=Pair;
x^.FJSONPairPrevious:=Pairs;
Pairs:=x;
dispose(x);
end;

Procedure Pop(var Pairs:UStackPair;var Pair:TJSONPair);

var
x:UStackPair;

begin
new(x);
Pair:=Pairs^.FJSONPair;
x:=Pairs;
Pairs:=Pairs^.FJSONPairPrevious;
Dispose(x);
end;


Procedure ReadJSONValue(var FJSONObject:TJSONObject; var Points:TPoints);
var
 FJSONArray:TJSONArray;
 FJSONPair:TJSONPair;
 FJSONTrue:TJSONTrue;
 FJSONFalse:TJSONFalse;
 i,j,k,m,n,c:integer;
 Pairs:UStackPair;
begin
Pairs:=nil;

k:=StrToInt(FJSONObject.Get(0).JsonValue.value);      // Задаем массив записей
if k<10 then
setlength(Points,k)
else
setlength(Points,10);

FJSONFalse:=TJSONFalse.Create;
FJSONArray:=TJSONArray.Create;
FJSONArray:=FJSONObject.Get(1).JsonValue as TJSONArray; // Определили рабочий массив

FJSONPair:=FJSONObject.get('items');
Push(FJSONPair,Pairs);

for I := 0 to  FJSONArray.Size-1 do
begin
  FJSONArray:=FJSONPair.JsonValue as TJSONArray;
  FJSONObject:=FJSONArray.Get(i) as TJSONObject;
 //0='name',
 //1='address',
 //2='phone',
 // 3='WorkingSchedule',
 // 4='Operations',
 // 5='type',
 // 6='OpenNow',
 // 7='timezoneId',
 // 8='workingHours',
 // 9='weekday',
 // 10='date',
 // 11='open',
 // 12='close',
 // 13='workingHoursNotes'
    for j := 0 to FJSONObject.Size-1 do
    case AnsiIndexStr(FJSONObject.Get(j).JSONString.Value,cmdArray) of     // Читаем имя каждой строки JSON  и решаем, что делать
    0: Points[i].name:=VarToStr(FJSONObject.Get(j).JsonValue.value);
    1: Points[i].address:=VarToStr(FJSONObject.Get(j).JsonValue.value);
    2: Points[i].phone:=VarToStr(FJSONObject.Get(j).JsonValue.value);
    3: begin

       FJSONPair:=FJSONObject.get('workingSchedule');
       Push(FJSONPair,Pairs);

       FJSONObject:=FJSONObject.get('workingSchedule').JsonValue as TJSONObject;  // В этом моменте JSON Преподносит нам массив в массиве, поэтому такое нагромождение
       for k := 0 to FJSONObject.Size-1 do
          case AnsiIndexStr(FJSONObject.Get(k).JSONString.Value,cmdArray) of
     6: begin
     FJsonValue:=FJSONObject.Get(k).JsonValue;

     if (FJsonValue is TJSONTrue)  then
     Points[i].WorkingSchedule.OpenNow:='true'
     else
     Points[i].WorkingSchedule.OpenNow:='false';

     end;
     7:Points[i].WorkingSchedule.timezoneId:=VarToStr(FJSONObject.Get(k).JsonValue.value);
     8:       begin


              FJSONArray:=FJSONObject.get(k).JsonValue as TJSONArray;
              SetLength(Points[i].WorkingSchedule.Working_Hours,FJSONArray.Size);
              for n := 0 to FJSONArray.Size-1 do
                begin
                  FJSONObject:=FJSONArray.Get(n) as TJSONObject;
                  for c:=0 to FJSONObject.Size-1 do
                  case AnsiIndexStr(FJSONObject.Get(c).JSONString.Value,cmdArray) of

    9: Points[i].WorkingSchedule.Working_Hours[n].weekday:=VarToStr(FJSONObject.Get(c).JsonValue.value);
    10:Points[i].WorkingSchedule.Working_Hours[n].date:=VarToStr(FJSONObject.Get(c).JsonValue.value);
    11:Points[i].WorkingSchedule.Working_Hours[n].open:=VarToStr(FJSONObject.Get(c).JsonValue.value);
    12:Points[i].WorkingSchedule.Working_Hours[n].close:=VarToStr(FJSONObject.Get(c).JsonValue.value);

                  end;


                end;
              Pop(Pairs,FJSONPair);
              FJSONArray:=FJSONPair.JsonValue as TJSONArray;
              FJSONObject:=FJSONArray.Get(i) as TJSONObject;
              end;

       end;

       Pop(Pairs,FJSONPair);
       FJSONArray:=FJSONPair.JsonValue as TJSONArray;
       FJSONObject:=FJSONArray.Get(i) as TJSONObject;

    end;


end;

end;
end;

procedure TAddress.FormShow(Sender: TObject);
var S:String;
begin
s:='https://info.api.unistream.com/api/v1/poses/search?location=55.7,37.6&radius=2000&maxResults=10';
  FJSONObject:=TJSONObject.Create;
  FJSONObject:=TJSONObject.ParseJSONValue(IdHTTP1.Get(s)) as TJSONObject;
  ReadJSONValue(FJSONObject,Points)
end;

procedure TAddress.MoreInformationClick(Sender: TObject);
begin
Info:=TUnit_Info.Create(nil);
Info.Show;
end;

end.
