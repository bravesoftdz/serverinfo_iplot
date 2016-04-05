unit UnMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdCpuUsage, {Giveio, }ExtCtrls, StdCtrls, Gauges, Buttons, Grids, Func, DateUtils,
  ComCtrls, iComponent, iVCLComponent, iCustomComponent, iPlotComponent,
  iPlot, Math, Spin;

type
  TfmMain = class(TForm)
    Timer1: TTimer;
    p_cpu: TPanel;
    Shape1: TShape;
    SpeedButton2: TSpeedButton;
    startdate: TDateTimePicker;
    enddate: TDateTimePicker;
    Label6: TLabel;
    Label7: TLabel;
    starttime: TDateTimePicker;
    endtime: TDateTimePicker;
    Plot: TiPlot;
    CheckBox1: TCheckBox;
    SpeedButton3: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    spinsec: TSpinEdit;
    Label8: TLabel;
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    ListBox2: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure starttimeChange(Sender: TObject);
    procedure endtimeChange(Sender: TObject);
    procedure PlotYAxisSpanChange(Index: Integer; OldValue,
      NewValue: Double);
    procedure PlotYAxisMinChange(Index: Integer; OldValue,
      NewValue: Double);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure spinsecChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
 cr=8; //������������ ���������� ���� ���������� ������� ����� ������ ���������

type
(*  TNewSQLThread = class(TThread)
  private
   msg : boolean;
   item:LongInt;
  protected
   procedure Execute; override;
  public
   constructor Create(sp:boolean;sek:LongInt);
  end; //type.. ����� *)

  TIndexStruct=record
   Index,Position:Int64;
  end;
  TfileStruct=record
   time:Double;    //����� � �������������
   data:Double;   //������
   core:byte;       //����� ����
  end; //type

var
  fmMain: TfmMain;
  cpu:array[1..cr] of Double;
//  cpu_temp:Double;
  sgp:boolean;
  //NewSQL:TNewSQLThread;
  //MySQLClient: TMysqlClient;
  day,CurrentDay:String;
  stop:boolean;
  //CacheBuf1:array[0..59] of TfileStruct;
  //CacheBuf2:array[0..59] of TfileStruct;
  cCount:Integer;
  DataWrite:file of TfileStruct;
  IndexWrite:file of TIndexStruct;
  IndexM:Int64;

const
 IntelBasePort:Integer = $290;

implementation

uses iPlotObjects;

{$R *.dfm}

function AddZero(n:integer):String;
begin
 if n<10 then Result:='0'+IntToStr(n)
 else Result:=IntToStr(n);
end; //function

(*//������ ������ ========================================================================
constructor TNewSQLThread.Create(sp:boolean;sek:LongInt);
{������� �����}
BEGIN
  msg:=sp;
  item:=sek;
  inherited Create(True);
END;

procedure TNewSQLThread.Execute;
var
 i:integer;
 str:string;
BEGIN
 while break_read do Application.ProcessMessages;
 fmMain.Shape3.Brush.Color:=clRed;
 break_write:=true;
 Application.ProcessMessages;
 try
  {if fmMain.CheckBox3.Checked then begin
   AssignFile(fStruct, CurrentDay);
   if FileExists(CurrentDay) then Reset(fStruct) else Rewrite(fStruct);
   seek(fStruct,item); //FileSize(fLoadCpuPacked)
  end; //if }
  if msg then
   //sg2
   for i:=0 to 59 do begin
    //if fmMain.CheckBox3.Checked then Write(fStruct,CacheBuf2[i]);
    //if fmMain.CheckBox4.Checked then str:=str+'(),';
   end //for i
  else //if
   //sg1
   for i:=0 to 59 do begin
    //if fmMain.CheckBox3.Checked then Write(fStruct,CacheBuf1[i]);
    //if fmMain.CheckBox4.Checked then str:=str+'(),';
   end; //for i

  //if fmMain.CheckBox3.Checked then CloseFile(fStruct);
 except end;
 break_write:=false;
 fmMain.Shape3.Brush.Color:=clBtnFace;

 //fmMain.Memo1.Lines.Add('INSERT INTO `loadcpu` (`dt`,`serverid`,`core`,`load`) VALUES '+str+';');
 //if MySQLClient.connect('tppasu04', 'pma', 'logotip','monitoring', 3306, '', false, 0) then begin
  //MySQLClient.query(Trim(fmMain.Memo1.Text), false, ok);
  //if not ok then MessageBox(fmMain.Handle,'�������� SQL ������','',MB_OK);
  //MessageBox(fmMain.Handle,'������������','',MB_OK); //if
 // MySQLClient.close;
 //end; //else MessageBox(fmMain.Handle,'��������� ������������ � ����','',MB_OK); //if
END;*)
//����� ������ =================================================================

{function MB_Temp:Integer;
begin
  OutPort(IntelBasePort+5,$27);
  Result:=InPort(IntelBasePort+6);
end;

function CPU_Temp:Word;
var
  tmp1: byte;
  tmp2: byte;
  Temp: word; // 16-bit unsigned integer
//  Temp1: integer;
//  i:integer;
begin asm
  mov  cx,128    //decimal, poll busy flag max. 128 times
  mov  dx,$0295
@WaitReady1:
  in  al,dx
  and  al,128 //decimal
  jz  @ExitWait
  dec  cx
  jnz  @WaitReady1
@ExitWait:
   mov  dx,$0295
  mov  al,78 // 78 dec. is the bank select register
  out  dx,al
  inc  dx
  mov  al,1 // select bank 1
  out  dx,al
  mov  dx,$0295
  mov  al,80 // 80 dec. is the temperature High register
  out  dx,al
  inc  dx
  in  al,dx // fetch temp Hi from 81 dec.
  shl  al,1
  mov  tmp1,al
  mov  dx,$0295
  mov  al,81 // 81 dec. is the temperature Low register
  out  dx,al
  inc  dx
  in  al,dx // fetch temp Lo from 82 dec.
  shr  al,7
  mov  tmp2,al
  // calculate reading
  xor  ah,ah
  xor  cx,cx
  mov  al,tmp1
  mov  cl,tmp2
  add  ax,cx
  shr  ax,1
  mov Temp,ax
  end;
  if Temp<0 then Temp:=0;
  if Temp>65536 then Temp:=0;
  Result:=Temp;
end;}

procedure TfmMain.FormCreate(Sender: TObject);
var
 i{, j }: Integer;
 Gauge : TGauge;
 yy,mm,dd,hh,mi,ss,aa:Word;
 Nw:TDateTime;
 index:TIndexStruct;
 //tm:String;
begin
// InitDriver;
 if not DirectoryExists(ExeP+'data') then CreateDir(ExeP+'data');
 Nw:=Now;
 enddate.DateTime:=IncSecond(Nw,1);
 endtime.DateTime:=enddate.DateTime;
 startdate.DateTime:=IncMinute(enddate.DateTime,-2);
 starttime.DateTime:=startdate.DateTime;
 Plot.XAxis[0].Min:=enddate.DateTime;
 Plot.XAxis[0].Span:=enddate.DateTime-startdate.DateTime;
 CollectCPUData;
 cCount:=GetCPUCount-1;
 for i:=1 to cCount do begin
  Gauge:=TGauge.Create(fmMain);
  Gauge.Name:=Format('g_cpu%d',[i]);
  with TGauge(FindComponent(Format('g_cpu%d',[i]))) do begin
   Parent:=p_cpu;
   Top:=0;
   Width:=round(p_cpu.Width/cCount);
   Height:=p_cpu.Height;
   Left:=((i-1)*Width);
   MinValue:=0;
   MaxValue:=100;
   ForeColor:=p_cpu.Color;
   Kind:=gkVerticalBar;
  end; //with TGauge
  cpu[i]:=0;
  Plot.Channel[i-1].Clear;
  Plot.Channel[i-1].Visible:=True;
  Plot.Channel[i-1].VisibleInLegend:=True;
  with Plot.YAxis[i-1] do begin
   StartPercent:=100-(i*100)/cCount;
   StopPercent:=100-((i-1)*100)/cCount;
   Visible:=True;
  end; //with
 end; //for i
 //MySQLClient := TMysqlClient.Create;
 DecodeDateTime(Nw,yy,mm,dd,hh,mi,ss,aa);
 sgp:=odd(mi);
 Timer1.Interval:=spinsec.Value;
 day:=IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd); //��� ����� �����
 //tm:=IntToStr(yy)+AddZero(mm)+AddZero(dd)+AddZero(hh)+AddZero(mi);
 IndexM:=0;//StrToInt64(tm);
 CurrentDay:=ExeP+'data\'+day+'.cpu';
 AssignFile(DataWrite, CurrentDay);
 if FileExists(CurrentDay) then Reset(DataWrite) else Rewrite(DataWrite);
 seek(DataWrite,FileSize(DataWrite));
 AssignFile(IndexWrite, CurrentDay+'i');
 if FileExists(CurrentDay+'i') then Reset(IndexWrite) else Rewrite(IndexWrite);
 while not Eof(IndexWrite) do begin
  Read(IndexWrite,Index);
  ListBox1.Items.Add(IntToStr(index.Index)+' - '+IntToStr(index.Position));
 end; //while
 seek(IndexWrite,FileSize(IndexWrite));
 Timer1.Enabled:=True;
end; //procedure FormCreate

{procedure CreateNewSQLThread(SG:Boolean;sek:LongInt);
begin
 NewSQL := TNewSQLThread.Create(SG,sek);
 NewSQL.FreeOnTerminate:=True; //���������� ����� ������������� ��� ���������� �� ������
 NewSQL.Priority:=tpLower;     //����� � ������ �����������, ���� �� ������� ���������
 NewSQL.Resume;                //��������� �����
end; //procedure}

procedure TfmMain.Timer1Timer(Sender: TObject);
var
 //sec:LongInt;
 n{,mb_tmp,cpu_tmp}:Byte;
 cp:Double;
 yy,mm,dd,hh,mi,ss,aa:Word;
 Nw:Double;
 item:TfileStruct;
 index:TIndexStruct;
 IndexM_:Int64;
 //cpu:Double;
begin
 Nw:=Now;
 fmMain.Caption:='CPU Usage: '+DateTimeToStr(Nw);
 DecodeDateTime(Nw,yy,mm,dd,hh,mi,ss,aa);
// sec:=ss+(mi*60)+(hh*60*60); //����� ��� ����������� �����
 day:=IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd); //��� ����� �����
 CurrentDay:=ExeP+'data\'+day+'.cpu';
 if not FileExists(CurrentDay) then begin
  CloseFile(DataWrite);
  AssignFile(DataWrite, CurrentDay);
  Rewrite(DataWrite);
  CloseFile(IndexWrite);
  AssignFile(IndexWrite, CurrentDay+'i');
  Rewrite(IndexWrite);
 end; //if not
 IndexM_:=StrToInt64(IntToStr(yy)+AddZero(mm)+AddZero(dd)+AddZero(hh)+AddZero(mi)+AddZero(ss));
 if IndexM<>IndexM_ then begin
  IndexM:=IndexM_;
  index.Index:=IndexM;
  index.Position:=FilePos(DataWrite);
  ListBox1.Items.Add(IntToStr(index.Index)+' - '+IntToStr(index.Position));
  try
   Write(IndexWrite,index);
  except end;
 end; //if
 CollectCPUData; //cpu:=0;
 for n:=1 to cCount do begin
  cp:=GetCPUUsage(n)*100;
  if cp<0 then cp:=0.0;
  if cp>100 then cp:=100.0;
  if cpu[n]<>cp then begin
  cpu[n]:=cp;
  item.time:=Nw;
  item.core:=n;
  item.data:=cp;
  try
   Write(DataWrite,item);
  except end;
  {if odd(mi) then begin
    //AddItemToSG(sg1,[IntToStr(DateTimeToUnixTime(Nw)),IntToStr(n),Format('%3.1n',[cp])]);
    CacheBuf1[ss].CRC:=sec;
    CacheBuf1[ss].coreLoad[n]:=cp;
    if not sgp then begin
     sgp:=true;
     CreateNewSQLThread(sgp,sec);
    end; //if not sgp
   end else begin
    //AddItemToSG(sg2,[IntToStr(DateTimeToUnixTime(Nw)),IntToStr(n),Format('%3.1n',[cp])]);
    CacheBuf2[ss].CRC:=sec;
    CacheBuf2[ss].coreLoad[n]:=cp;
    if sgp then begin
     sgp:=false;
     CreateNewSQLThread(sgp,sec);
    end; //if sgp
   end; //odd }
  end; //if cpu[n]<>cp
  TGauge(FindComponent('g_cpu'+IntToStr(n))).Progress:=StrToInt(Format('%0.0n',[cp]));  //Format('%0.0f%',[cpu])
  if CheckBox1.Checked then Plot.Channel[n-1].AddXY(Nw,cp);
 end; //for n

 //GetDriveFreeSpace('C:')

 //mb_tmp:=MB_Temp; l_temp_mb.Caption:=IntToStr(mb_tmp)+'/'+IntToStr(g_mb_temp.MaxValue); g_mb_temp.Progress:=mb_tmp;
 //cpu_tmp:=CPU_Temp; l_temp_cpu.Caption:=IntToStr(cpu_tmp)+'/'+IntToStr(g_cpu_temp.MaxValue); g_cpu_temp.Progress:=cpu_tmp;
end; //procedure Timer

procedure TfmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
// DoneDriver;
 //if MySQLClient.connect then MySQLClient.close;
 CloseFile(IndexWrite);
 CloseFile(DataWrite);
 ExitProcess(0);
end; //procedure FormClose

procedure TfmMain.FormDestroy(Sender: TObject);
begin
// DoneDriver;
 //MySQLClient.Free;
 ExitProcess(0);
end; //procedure FormDestroy

procedure TfmMain.SpeedButton2Click(Sender: TObject);
 procedure Graphic(CurDay:String;a1,a2,Dat:Int64);
 var
  fStruct:file of TfileStruct;
  Struct:TfileStruct;
  DT:TDateTime;
  i:integer;
 begin
  if not FileExists(CurDay) then Exit;
  FileMode:=fmOpenRead or fmShareExclusive;
  AssignFile(fStruct, CurDay);
  Reset(fStruct);
  //seek(fStruct,a1+60);
  DT:=UnixToDateTime(a1+1);
  for i:=a1 to a2 do begin
   if stop then Break;
   if not Eof(fStruct) then read(fStruct, Struct) else Break;
   DT:=UnixToDateTime(Dat+i);
   Plot.Channel[0].AddXY(DT,Struct.data);
   Application.ProcessMessages;
  end; //for i
  CloseFile(fStruct);
  Plot.Channel[0].AddXY(DT,-1000);
 end;

var
// i:integer;
 day:string;
 sec1,sec2:LongInt;
 yy,mm,dd,hh,mi,ss,aa:word;
begin
 CheckBox1.Checked:=false;
 //while break_write do Application.ProcessMessages;
 //fmMain.Shape3.Brush.Color:=clLime;
 //break_read:=true;
 startdate.Time:=starttime.Time;
 enddate.Time:=endtime.Time;
 SpeedButton2.Enabled:=false;
 SpeedButton3.Enabled:=true;
 stop:=false;

 Application.ProcessMessages;
 //���� ������ ���������� �� 1 ����

 if trunc(startdate.Date)=trunc(enddate.Date) then begin
  DecodeDateTime(startdate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  day:=ExeP+'data\'+IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd)+'.cpu';
  sec1:=ss+(mi*60)+(hh*60*60);
  DecodeDateTime(enddate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  sec2:=ss+(mi*60)+(hh*60*60);
  Graphic(day,sec1,sec2,DateTimeToUnix(Trunc(startdate.Date)));
 end else begin //���� ������ ���������� �� ������ ����
  DecodeDateTime(startdate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  day:=ExeP+'data\'+IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd)+'.cpu';
  sec1:=ss+(mi*60)+(hh*60*60);
  Graphic(day,sec1,86400,DateTimeToUnix(Trunc(startdate.Date)));
  DecodeDateTime(enddate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  sec2:=ss+(mi*60)+(hh*60*60);
  day:=ExeP+'data\'+IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd)+'.cpu';
  Graphic(day,0,sec2,DateTimeToUnix(Trunc(enddate.Date)));
 end;
 SpeedButton2.Enabled:=true;
 SpeedButton3.Enabled:=false;
 //break_read:=false;
// fmMain.Shape3.Brush.Color:=clBtnFace;
end;

procedure TfmMain.starttimeChange(Sender: TObject);
begin
 startdate.Time:=starttime.Time;
end;

procedure TfmMain.endtimeChange(Sender: TObject);
begin
 enddate.Time:=endtime.Time;
end;

procedure TfmMain.PlotYAxisSpanChange(Index: Integer; OldValue,
  NewValue: Double);
begin
// Plot.YAxis[Index].Span:=100;
end;

procedure TfmMain.PlotYAxisMinChange(Index: Integer; OldValue,
  NewValue: Double);
begin
// Plot.YAxis[Index].Min:=0;
end;

procedure TfmMain.SpeedButton3Click(Sender: TObject);
begin
 stop:=true;
end;

procedure TfmMain.SpeedButton1Click(Sender: TObject);
var
 sec:integer;
begin
 CheckBox1.Checked:=false;
 sec:=SecondsBetween(startdate.DateTime,enddate.DateTime);
 startdate.DateTime:=IncSecond(startdate.DateTime,-sec);
 starttime.DateTime:=startdate.DateTime;
 enddate.DateTime:=IncSecond(enddate.DateTime,-sec);
 endtime.DateTime:=enddate.DateTime;
 SpeedButton2Click(Sender);
end;

procedure TfmMain.SpeedButton4Click(Sender: TObject);
var
 sec:integer;
begin
 CheckBox1.Checked:=false;
 sec:=SecondsBetween(startdate.DateTime,enddate.DateTime);
 startdate.DateTime:=IncSecond(startdate.DateTime,sec);
 starttime.DateTime:=startdate.DateTime;
 enddate.DateTime:=IncSecond(enddate.DateTime,sec);
 endtime.DateTime:=enddate.DateTime;
 SpeedButton2Click(Sender);
end;

procedure TfmMain.SpeedButton5Click(Sender: TObject);
begin
 enddate.DateTime:=IncSecond(Now,1);
 endtime.DateTime:=enddate.DateTime;
 startdate.DateTime:=IncMinute(enddate.DateTime,-5);
 starttime.DateTime:=startdate.DateTime;
 SpeedButton2Click(Sender);
end;

procedure TfmMain.Button1Click(Sender: TObject);
var
 //Unix1,Unix2:Int64;
 item:TfileStruct;
 //dt1,dt2:TDateTime;
 //fs: TFormatSettings;
 i:integer;
begin
{    fs.DecimalSeparator:='.';
    fs.TimeSeparator:=':';
    fs.DateSeparator:='-';
    fs.LongTimeFormat:='yyyy-mm-dd hh:nn:ss.zzz';}

//Unix1:=DateTimeToUnix(Now);
//New(item);
for i:=1 to 100000 do begin
item.time:=DateTimeToUnixMs(Now);
item.core:=Random(255);
item.data:=Random(100000);
try
 Write(DataWrite,item);
except end;
end; //for i

//dt1:=UnixToDateTime(Unix1);
//dt2:=UnixMsToDateTime(Unix2);
//ShowMessage(IntToStr(Unix1)+' - '+DateTimeToStr(dt1)+#13+IntToStr(Unix2)+' - '+DateTimeToStr(dt2,fs));
end;

procedure TfmMain.spinsecChange(Sender: TObject);
begin
 Timer1.Interval:=spinsec.Value;
end;

procedure TfmMain.Button2Click(Sender: TObject);
var
 item:TfileStruct;
 source : TFileStream;
 tick:Cardinal;
 i,j:integer;
 yy,mm,dd,hh,mi,ss,aa:word;
 sec1,sec2:LongInt;
begin
 tick:=GetTickCount;
 CheckBox1.Checked:=False;
 if trunc(startdate.Date)=trunc(enddate.Date) then begin
  DecodeDateTime(startdate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  day:=ExeP+'data\'+IntToStr(yy)+'-'+AddZero(mm)+'-'+AddZero(dd)+'.cpu';
  sec1:=ss+(mi*60)+(hh*60*60);
  DecodeDateTime(enddate.DateTime,yy,mm,dd,hh,mi,ss,aa);
  sec2:=ss+(mi*60)+(hh*60*60);
 end;
 source := TFileStream.Create(day, fmOpenRead or fmShareDenyNone);
 j:=ListBox1.Items.IndexOf(IntToStr(yy)+AddZero(mm)+AddZero(dd)+AddZero(hh)+AddZero(mi)+AddZero(ss));
 if j>0 then begin
  source.Position:=SizeOf(item)*StrToInt(trim(Copy(ListBox1.Items[j],Pos(' - ',ListBox1.Items[j]),Length(ListBox1.Items[j]))));//
  for i:=0 to Plot.ChannelCount-1 do Plot.Channel[i].Clear;
  try
   //i:=0;
   while not (source.Position >= source.Size) do begin
    source.ReadBuffer(item, SizeOf(item));
    Plot.Channel[item.core-1].AddXY(TDateTime(item.time),item.data);
   end; //while
  finally
   FreeAndNil(Source);
  end;
 end; //if
 tick:=GetTickCount-tick;
 Button2.Caption:=FloatToStr(tick/1000);
end;

end.
