unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,System.JSON;

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
    OpenNow:boolean;
    timezoneId:string;
    Working_Hours:array of TWorking_hours;
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
    WorkingSchedule :TWorkingShedule;
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
  Points:TPoints;
  FJSONObjectIn:TJSONObject ;
  FJSONArrayIn: TJSONArray;
implementation

{$R *.dfm}

procedure TForm2.Button1Click(Sender: TObject);
begin
  s:='https://info.api.unistream.com/api/v1/poses/search?location='+location.text+'&radius='+radius.text+'&maxResults='+maxNumber.text;
  FJSONObject:=TJSONObject.ParseJSONValue(IdHTTP1.Get(s)) as TJSONObject;
  setlength(Points, StrToInt(FJSONObject.Pairs[0].JsonValue.Value)+1);  // Ќе будем извращатьс€ и нумеровать будем с единицы
  FJSONArray:=FJSONObject.get('items').JsonValue as TJSONArray;
  s:=IdHTTP1.Get(s);
  end;

Procedure ReadJSONValue(FJSONObject:TJSONObject;FJSONArray:TJSONArray);
var j,k,m:integer;
FJSONArrayInIn: TJSONArray;
begin
k:=0;
j:=1;
m:=0;
FJSONObject.ParseJSONValue(FJSONArray.Items[i].ToString) as TJSONObject;   //Ѕерем i-ый элемент исходного массива JSON и расматриваем его
  case VarToStr(FJSONObject.Pairs[i].JsonString.Value) of                  //—мотрим как называетс€ пара

  'id':                 Points[j].ID:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  'agentId':            Points[j].agentID:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  'name':               Points[j].name:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);          // ¬ самом простом случае напр€мую считываем значение в переменную
  'shortName':          Points[j].Shortname:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  'address'   :         Points[j].address:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  'addressNotes':       Points[j].addressNotes:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);
  'location'     :
  begin                         //≈сли же полученна€ вещь - массив, то ни чего не остаетс€ как обрабатывать его как массив
  k:=0;                         //ѕо сути делаем то же самое только получаем цикл в цикле, но в будущем  нас ждет нечто еще интереснее.
  m:=0;
    FJSONArrayIn:=FJSONObject.get('location').JsonValue as TJSONArray;
    while k<FJSONArrayIn.Count-1 do
      begin
      FJSONObjectIn.ParseJSONValue(FJSONArrayIn.items[k].ToString) as TJSONObject;
      for M := 0 to FJSONObjectIn.Count-1 do
      case VarToStr(FJSONObjectIn.Pairs[m].JsonString.Value) of

      'lat':            Points[j].location.lat:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'lon':            Points[j].location.lon:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'zoom':           Points[j].location.zoom:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value) ;

      end;
      end;
      k:=k+1;
  end;
  'phone'        :      Points[j].phone:=VarToStr(FJSONObject.Pairs[i].JsonValue.Value);

  'country'      :
   begin
    k:=0;
    FJSONArrayIn:=FJSONObject.get('country').JsonValue as TJSONArray;
    while k<FJSONArrayIn.Count-1 do
      begin
      FJSONObjectIn.ParseJSONValue(FJSONArrayIn.items[k].ToString) as TJSONObject;
      for M := 0 to FJSONObjectIn.Count-1 do
      case VarToStr(FJSONObjectIn.Pairs[m].JsonString.Value) of

      'countryCode':     Points[j].country.ID:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'name':            Points[j].country.Name:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);

      end;
      end;
      k:=k+1;
  end;
  'region'       :
    begin
    k:=0;
    FJSONArrayIn:=FJSONObject.get('region').JsonValue as TJSONArray;
    while k<FJSONArrayIn.Count-1 do
      begin
      FJSONObjectIn.ParseJSONValue(FJSONArrayIn.items[k].ToString) as TJSONObject;
      for M := 0 to FJSONObjectIn.Count-1 do
      case VarToStr(FJSONObjectIn.Pairs[m].JsonString.Value) of

      'id':           Points[j].Region.ID:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'countryCode':  Points[j].Region.CountryID:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'name':         Points[j].Region.Name:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'subway':       Points[j].Region.Subway:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);

      end;
      end;
      k:=k+1;
  end;

//  'workingSchedule' :

  'metro'         :
    begin
    k:=0;
    FJSONArrayIn:=FJSONObject.get('metro').JsonValue as TJSONArray;
    while k<FJSONArrayIn.Count-1 do
      begin
      FJSONObjectIn.ParseJSONValue(FJSONArrayIn.items[k].ToString) as TJSONObject;
      for M := 0 to FJSONObjectIn.Count-1 do
      case VarToStr(FJSONObjectIn.Pairs[m].JsonString.Value) of

      'id':           Points[j].metro.MetroID:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);
      'name':         Points[j].metro.MetroName:=VarToStr(FJSONObjectIn.Pairs[i].JsonValue.Value);

      end;
      end;
      k:=k+1;
  end;
 // 'currencies'    :
 // 'operations'    :
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
