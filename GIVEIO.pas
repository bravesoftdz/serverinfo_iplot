
  {*====================================================================*}
  {*                               DELPHI                               *}
  {*                    "WinNT/Win2000/WinXP/Win2003"                   *}
  {*                   Модуль для работы с портами I/O.                 *}
  {*    В этом модуле был использован всем известный драйвер "giveio"   *}
  {*          Автор Модуля   : Nurzhanov Askar (NikNet/Arazel).         *}
  {*                  Автор Драйвера : Крис Каспирский                  *}
  {*                                2005                                *}
  {*====================================================================*}

unit giveio;


interface

uses windows, winsvc;

{*====================================================================*}
{* Основные ф-ций *----------------------------------------------------}
{*====================================================================*}
  // ВНИМАНИЕ!!! Использовать в самом начале
  Procedure InitDriver;

  // После ф-ций InitDrv можете использовать эти

  Procedure OutPort(port:word; value:byte);stdcall;
  Function  InPort(port:word):byte;stdcall;

  Procedure OutPortW(port:word; value:word);stdcall;
  Function  InPortW(port:word):word;stdcall;

  Function  InPortDW(Port: Word):cardinal;
  procedure OutPortDW( Port: word; value:cardinal);

  // ВНИМАНИЕ!!! Использовать в самом конце
  Procedure DoneDriver;

{*====================================================================*}
{* Дополнение к портам ввода/вывод ф-ций (Примеры) *-------------------}
{*====================================================================*}




implementation


uses sysutils;

Var
  hSCMan,
  hService,
  hDevice             : SC_HANDLE;
  lpServiceArgVectors : PChar;
  temp                : LongBool;
  serviceStatus       : TServiceStatus;
  DeviceName          : String;



  function isWin9x: Bool; {True=Win9x} {False=NT}
  asm
    xor eax, eax
    mov ecx, cs
    xor cl, cl
    jecxz @@quit
    inc eax
    @@quit:
  end;


  Procedure InitDriver;
  Begin
     if not isWin9x then
     Begin
       IF not FileExists('giveio.sys') then
       MessageBox(0,'Драйвер giveio.sys не найдет.',nil,0);
       lpServiceArgVectors:=nil;
       DeviceName:='giveio';
       hSCMan:=OpenSCManager(Nil,Nil,SC_MANAGER_CREATE_SERVICE);
       IF hSCMan <> 0 Then
       hService:=CreateService(
       hSCMan,
       pChar(DeviceName),
       pChar(DeviceName),
       SERVICE_ALL_ACCESS,
       SERVICE_KERNEL_DRIVER,
       SERVICE_DEMAND_START,
       SERVICE_ERROR_NORMAL,
       PChar(ExtractFilePath(ParamStr(0))+'giveio.sys'),nil,nil,nil,nil,nil);
       If hService<>0 then
        CloseServiceHandle(hService);
        hService:=OpenService(hSCMan,pChar(DeviceName),SERVICE_ALL_ACCESS);
       If hService<>0 then
       begin
        StartService(hService,0,PChar(lpServiceArgVectors));
        CloseServiceHandle(hService);
       end;
        hDevice:=CreateFile(pChar('\\.\'+DeviceName),
        GENERIC_READ or GENERIC_WRITE,0,PSECURITY_DESCRIPTOR(nil),
        OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
     end;
  end;

  Procedure DoneDriver;
  Begin
  if not isWin9x then
  begin
    CloseHandle(hDevice);
    hService := OpenService(hSCMan,PChar(DeviceName), SERVICE_ALL_ACCESS);
    if hService <> 0 then
    Temp := ControlService(hService,SERVICE_CONTROL_STOP,ServiceStatus);
    if (hService <> 0) then
    CloseServiceHandle(hService);
    hService := OpenService(hSCMan,PChar(DeviceName), SERVICE_ALL_ACCESS);
    temp := DeleteService(hService);
    CloseServiceHandle(hService);
  end;
  end;


  Procedure OutPort(port:word; value:byte);assembler;stdcall;
  asm
    mov al, value
    mov dx, port
    out dx, ax
  end;

  function InPort(port:word):byte;assembler;stdcall;
  asm
    mov dx,port
    in al,dx
    mov Result,al
  end;

  Procedure OutPortW(port:word; value:word);assembler;stdcall;
  asm
    mov ax, value
    mov dx, port
    out dx, ax
  end;

  function InPortW(port:word):word;assembler;stdcall;
  asm
    mov dx,port
    in ax,dx
    mov Result,ax
  end;

  Function  InPortDW(Port: Word):cardinal;
  Begin
   asm
     mov DX, Port;
     in  EAX, DX;
     mov Result, EAX;
   end;
  end;

  procedure OutPortDW( Port: word; value:cardinal);
   Begin
    asm
      mov DX, Port;
      mov EAX, value;
      out DX, EAX;
    end;
   end;




end.

