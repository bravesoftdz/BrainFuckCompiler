unit Compiler;

interface

uses
  &Assembler.Global, System.SysUtils, Buffer;

type
  TTarget = (tWin32, tWin64, tLinux);

  TTargetHelper = record helper for TTarget
  public
    function ToString: string;
  end;

  TCompiler = object
  strict private
    function InstructionPtr: Pointer;
  protected
    FBuffer: TBuffer;

    FTarget: TTarget;
  public
    {$REGION 'Properties'}
    property Target: TTarget read FTarget default tWin32;
    property IP: Pointer read InstructionPtr;
    {$ENDREGION}

    {$REGION 'Constructors/Destructors'}
    procedure Create;
    {$ENDREGION}

    {$REGION 'Raw Write Functions'}
    procedure WriteModRM(AddrMod: TAddressingType; Dest, Source: TRegIndex); overload; stdcall;
    procedure WriteModRM(AddrMod: TAddressingType; Dest: TRegIndex; IsBase, B1, B2: Boolean); overload; stdcall;
    procedure WriteSIB(Scale: TNumberScale; Base, Index: TRegIndex);
    procedure WriteBase(Dest, Base, Index: TRegIndex; Scale: TNumberScale; Offset: Integer); stdcall;
    procedure WriteImm(Value: Integer; Size: TAddrSize);
    procedure WritePrefix(Prefix: TCmdPrefix);
    {$ENDREGION}

    {$REGION 'Define Functions'}
    procedure DB(Value: Byte); overload;
    procedure DB(const Values: array of Byte); overload;
    procedure DB(const Value: AnsiString); overload;

    procedure DW(Value: SmallInt); overload;
    procedure DW(const Values: array of SmallInt); overload;
    procedure DW(const Value: WideString); overload;

    procedure DD(Value: Integer); overload;
    procedure DD(const Values: array of Integer); overload;

    procedure DQ(Value: Int64); overload;
    procedure DQ(const Values: array of Int64); overload;
    {$ENDREGION}

    procedure WriteAnd(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteAnd(Dest, Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteAnd(Dest, Source: TRegIndex); overload;
    procedure WriteAnd(Dest: TRegIndex; Value: Integer); overload;

    procedure WriteMov(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteMov(Dest, Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteMov(Dest, Source: TRegIndex); overload;
    procedure WriteMov(Dest: TRegIndex; Value: Integer); overload;

    procedure WriteLea(Dest, Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteLea(Dest, Source: TRegIndex; Offset: Integer = 0); overload;
    procedure WriteLea(Dest: TRegIndex; Value: Integer); overload;

    procedure WriteAdd(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteAdd(Dest, Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteAdd(Dest: TRegIndex; Value: Integer); overload;
    procedure WriteAdd(Dest, Source: TRegIndex); overload;

    procedure WriteSub(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteSub(Dest, Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteSub(Dest: TRegIndex; Value: Integer); overload;
    procedure WriteSub(Dest, Source: TRegIndex); overload;

    // ...

    procedure WriteTest(Dest, Source: TRegIndex); overload;
    procedure WriteTest(Dest: TRegIndex; Value: Integer); overload;

    procedure WriteXor(Dest, Base, Index: TRegIndex; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteXor(Dest, Source: TRegIndex); overload;
    procedure WriteXor(Dest: TRegIndex; Value: Integer); overload;

    procedure WriteCmp(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteCmp(Dest, Base, Index: TRegIndex; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload; stdcall;
    procedure WriteCmp(Dest, Source: TRegIndex); overload;
    procedure WriteCmp(Dest: TRegIndex; Value: Integer); overload;

    procedure WritePush(Source: TRegIndex; Dereference: Boolean = False); overload;
    procedure WritePush(Value: Integer; Dereference: Boolean = False); overload;

    procedure WritePop(Source: TRegIndex); overload;
    procedure WritePop(Addr: Pointer); overload;

    procedure WriteRet(Bytes: Integer = 0);

    procedure WriteNop;

    procedure WriteJump(Jump: TJumpType; Here: Pointer);
    procedure WriteCall(Addr: Pointer); overload;
    procedure WriteCall(Reg: TRegIndex); overload;

    procedure WriteInt(Interrupt: Integer);

    procedure WriteInc(Dest: TRegIndex); overload;
    procedure WriteInc(Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload;

    procedure WriteDec(Dest: TRegIndex); overload;
    procedure WriteDec(Base, Index: TRegIndex; RegSize: TAddrSize = msDWord; Scale: TNumberScale = nsNo; Offset: Integer = 0); overload;

    procedure WriteXchg(Dest, Source: TRegIndex); overload;
    procedure WriteXchg(Dest: TRegIndex; Address: Pointer); overload;

    procedure WriteSetCC(Dest: TRegIndex; Condition: TCondition);

    procedure WriteNot(Dest: TRegIndex);

    procedure WriteShr(Reg: TRegIndex; Count: Byte);
    procedure WriteShl(Reg: TRegIndex; Count: Byte);

    procedure WriteMovS(Prefix: TCmdPrefix; Count: TAddrSize); overload;
    procedure WriteMovS(Count: TAddrSize); overload;
    procedure WriteStoS(Prefix: TCmdPrefix; Count: TAddrSize); overload;
    procedure WriteStoS(Count: TAddrSize); overload;

    class function IsRel8(Value: Integer): Boolean; static; inline;
    class procedure Swap(var FReg: TRegIndex; var SReg: TRegIndex); static; inline;
  public
    procedure RaiseException(const Text: string); overload;
    procedure RaiseException(const Fmt: string; const Args: array of const); overload;
  end;

implementation

procedure TCompiler.WriteImm(Value: Integer; Size: TAddrSize);
begin
  case Size of
    msByte: FBuffer.Write<Byte>(Value);
    msWord: FBuffer.Write<SmallInt>(Value);
    msDWord: FBuffer.Write<Integer>(Value);
  end;
end;

procedure TCompiler.WriteInc(Base, Index: TRegIndex; RegSize: TAddrSize;
  Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($FE)
  else
  begin
    if RegSize = msWord then
      WritePrefix(cpRegSize);

    FBuffer.Write<Byte>($FF);
  end;

  WriteBase(TRegIndex(0), Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteInt(Interrupt: Integer);
begin
  if Interrupt = 3 then
    FBuffer.Write<Byte>($CC)
  else
  begin
    FBuffer.Write<Byte>($CD);
    FBuffer.Write<Byte>(Interrupt);
  end;
end;

procedure TCompiler.WriteJump(Jump: TJumpType; Here: Pointer);
var
  I: Integer;
begin
  if Here = nil then
    I := 0
  else
    I := Integer(Here) - Integer(@TBytes(FBuffer.Data)[FBuffer.Position]);

  if Jump = jtJmp then
  begin
    if IsRel8(I) then
    begin
      FBuffer.Write<Byte>($EB);
      FBuffer.Write<Byte>(I - 2);
    end
    else
    begin
      FBuffer.Write<Byte>($E9);
      FBuffer.Write<Integer>(I - 5);
    end;
  end
  else
  begin
    if IsRel8(I) then
    begin
      FBuffer.Write<Byte>($70 or Byte(Jump));
      FBuffer.Write<Byte>(I - 2);
    end
    else
    begin
      FBuffer.Write<Byte>($0F);
      FBuffer.Write<Byte>($80 or Byte(Jump));
      FBuffer.Write<Integer>(I - 6);
    end;
  end;
end;

procedure TCompiler.WriteLea(Dest, Base, Index: TRegIndex; RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    RaiseException('TCompiler.WriteLea: Byte register size is not supported by LEA.')
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($8D);
  end
  else
    FBuffer.Write<Byte>($8D);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteLea(Dest: TRegIndex; Value: Integer);
begin
  FBuffer.Write<Byte>($8D);
  WriteModRM(atIndirAddr, TRegIndex(5), Dest);
  FBuffer.Write<Integer>(Value);
end;

procedure TCompiler.WriteLea(Dest, Source: TRegIndex; Offset: Integer);
begin
  FBuffer.Write<Byte>($8D);

  case Source of
    rEbp:
    begin
      if not IsRel8(Offset) then
      begin
        WriteModRM(atBaseAddr32B, Source, Dest);
        FBuffer.Write<Integer>(Offset);
      end
      else
      begin
        WriteModRM(atBaseAddr8B, Source, Dest);
        FBuffer.Write<Integer>(Offset);
      end;
    end;

    rEsp:
    begin
      if not IsRel8(Offset) then
      begin
        WriteModRM(atBaseAddr32B, Source, Dest);
        WriteSIB(nsNo, Source, Source);
        FBuffer.Write<Integer>(Offset);
      end
      else
      begin
        WriteModRM(atBaseAddr8B, Source, Dest);
        WriteSIB(nsNo, Source, Source);
        FBuffer.Write<Byte>(Offset);
      end;
    end
    else
    begin
      if Offset = 0 then
        WriteModRM(atIndirAddr, Source, Dest)
      else
      begin
        if IsRel8(Offset) then
        begin
          WriteModRM(atBaseAddr8B, Source, Dest);
          FBuffer.Write<Byte>(Offset);
        end
        else
        begin
          WriteModRM(atBaseAddr32B, Source, Dest);
          FBuffer.Write<Integer>(Offset);
        end;
      end;
    end;
  end;
end;

procedure TCompiler.WriteModRM(AddrMod: TAddressingType;
  Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>(Byte(AddrMod) shl 6 or Byte(Source) shl 3 or Byte(Dest));
end;

procedure TCompiler.WriteModRM(AddrMod: TAddressingType;
  Dest: TRegIndex; IsBase, B1, B2: Boolean);
begin
  FBuffer.Write<Byte>((Byte(AddrMod) shl 6) or (Byte(Dest) shl 3));
end;

procedure TCompiler.WriteMov(Dest: TRegIndex; Value: Integer);
begin
  FBuffer.Write<Byte>($B8 or Byte(Dest));
  FBuffer.Write<Integer>(Value);
end;

procedure TCompiler.WriteMov(Value: Integer; Base, Index: TRegIndex; RegSize: TAddrSize;
  Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($C6)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($C7);
  end
  else
    FBuffer.Write<Byte>($C7);

  WriteBase(TRegIndex(0), Base, Index, Scale, Offset);
  WriteImm(Value, RegSize);
end;

procedure TCompiler.WriteMov(Dest, Base, Index: TRegIndex; RegSize: TAddrSize;
  Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($8A)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($8B);
  end
  else
    FBuffer.Write<Byte>($8B);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteMovS(Prefix: TCmdPrefix; Count: TAddrSize);
begin
  WritePrefix(Prefix);
  WriteMovS(Count);
end;

procedure TCompiler.WriteMovS(Count: TAddrSize);
begin
  case Count of
    msByte: FBuffer.Write<Byte>($A4);
    msWord:
    begin
      WritePrefix(cpAddrSize);
      FBuffer.Write<Byte>($A5);
    end;
    msDWord: FBuffer.Write<Byte>($A5);
  end;
end;

procedure TCompiler.WriteNop;
begin
  FBuffer.Write<Byte>($90);
end;

procedure TCompiler.WriteNot(Dest: TRegIndex);
begin
  FBuffer.Write<Byte>($F7);
  WriteModRM(atRegisters, Dest, TRegIndex(2));
end;

procedure TCompiler.WriteMov(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($89);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteDec(Base, Index: TRegIndex; RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($FE)
  else
  begin
    if RegSize = msWord then
      WritePrefix(cpRegSize);

     FBuffer.Write<Byte>($FF);
  end;

  WriteBase(TRegIndex(1), Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteInc(Dest: TRegIndex);
begin
  FBuffer.Write<Byte>($40 or Byte(Dest));
end;

procedure TCompiler.RaiseException(const Text: string);
begin
  raise System.SysUtils.Exception.CreateFmt('%s', [Text]);
end;

procedure TCompiler.Create;
begin

end;

procedure TCompiler.DB(const Values: array of Byte);
var
  I: Integer;
begin
  for I := 0 to Length(Values) - 1 do
    FBuffer.Write<Byte>(Values[I]);
end;

procedure TCompiler.DB(Value: Byte);
begin
  FBuffer.Write<Byte>(Value);
end;

procedure TCompiler.DB(const Value: AnsiString);
begin
  FBuffer.Write<AnsiString>(Value);
end;

procedure TCompiler.DD(const Values: array of Integer);
var
  I: Integer;
begin
  for I := 0 to Length(Values) - 1 do
    FBuffer.Write<Integer>(Values[I]);
end;

procedure TCompiler.DD(Value: Integer);
begin
  FBuffer.Write<Integer>(Value);
end;

procedure TCompiler.DQ(const Values: array of Int64);
var
  I: Integer;
begin
  for I := 0 to Length(Values) - 1 do
    FBuffer.Write<Int64>(Values[I]);
end;

procedure TCompiler.DW(const Value: WideString);
begin
  FBuffer.Write<WideString>(Value);
end;

procedure TCompiler.DQ(Value: Int64);
begin
  FBuffer.Write<Int64>(Value);
end;

procedure TCompiler.DW(const Values: array of SmallInt);
var
  I: Integer;
begin
  for I := 0 to Length(Values) - 1 do
    FBuffer.Write<SmallInt>(Values[I]);
end;

procedure TCompiler.DW(Value: SmallInt);
begin
  FBuffer.Write<SmallInt>(Value);
end;

function TCompiler.InstructionPtr: Pointer;
begin
  Result := @TBytes(FBuffer.Data)[FBuffer.Position];
end;

class function TCompiler.IsRel8(Value: Integer): Boolean;
begin
  Result := (Value >= -128) and (Value <= 127);
end;

procedure TCompiler.RaiseException(const Fmt: string; const Args: array of const);
var
  Text: string;
begin
  Text := Format(Fmt, Args);
  RaiseException(Text);
end;

class procedure TCompiler.Swap(var FReg: TRegIndex; var SReg: TRegIndex);
var
  TempReg: TRegIndex;
begin
  TempReg := FReg;
  FReg := SReg;
  SReg := TempReg;
end;

procedure TCompiler.WriteAdd(Dest: TRegIndex; Value: Integer);
begin
  if not IsRel8(Value) then
  begin
    if Dest = rEax then
      FBuffer.Write<Byte>($05) // eax opcode
    else
    begin
      FBuffer.Write<Byte>($81); // default opcode
      WriteModRM(atRegisters, Dest, TRegIndex(0));
    end;

    FBuffer.Write<Integer>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($83); // one-byte opcode
    WriteModRM(atRegisters, Dest, TRegIndex(0));
    FBuffer.Write<Byte>(Value);
  end;
end;

procedure TCompiler.WriteAdd(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($01);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteAdd(Value: Integer; Base, Index: TRegIndex;
  RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($80)
  else
  begin
    if RegSize = msWord then
    begin
      WritePrefix(cpRegSize);
      FBuffer.Write<Byte>($81);
    end
    else
      FBuffer.Write<Byte>($81)
  end;

  WriteBase(TRegIndex(0), Base, Index, Scale, Offset);
  WriteImm(Value, RegSize);
end;

procedure TCompiler.WriteAdd(Dest, Base, Index: TRegIndex; RegSize: TAddrSize;
  Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($02)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($03);
  end
  else
    FBuffer.Write<Byte>($03);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteAnd(Value: Integer; Base, Index: TRegIndex;
  RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($80)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($81);
  end
  else
    FBuffer.Write<Byte>($81);

  WriteBase(TRegIndex(4), Base, Index, Scale, Offset);
  WriteImm(Value, RegSize);
end;

procedure TCompiler.WriteAnd(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($21);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteAnd(Dest: TRegIndex; Value: Integer);
begin
  if IsRel8(Value) then
  begin
    FBuffer.Write<Byte>($82);
    WriteModRM(atRegisters, Dest, TRegIndex(4));
    FBuffer.Write<Byte>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($81);
    WriteModRM(atRegisters, Dest, TRegIndex(4));
    FBuffer.Write<Integer>(Value);
  end;
end;

procedure TCompiler.WriteAnd(Dest, Base, Index: TRegIndex; RegSize: TAddrSize;
  Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($22)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($23);
  end
  else
    FBuffer.Write<Byte>($23);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteBase(Dest, Base, Index: TRegIndex; Scale: TNumberScale;
  Offset: Integer);
begin
  if Index = rEsp then
    Swap(Index, Base);

  if Offset <> 0 then
  begin
    if IsRel8(Offset) then
    begin
      if (Scale = nsNo) and (Index = Base) then
      begin
        WriteModRM(atBaseAddr8B, Base, Dest);

        if Index = rEsp then
          WriteSIB(Scale, Index, Index);
      end
      else
      begin
        WriteModRM(atBaseAddr8B, TRegIndex(4), Dest);
        WriteSIB(Scale, Base, Index);
      end;

      FBuffer.Write<Byte>(Offset);
    end
    else
    begin
      if (Scale = nsNo) and (Index = Base) then
        WriteModRM(atBaseAddr32B, Base, Dest)
      else
      begin
        WriteModRM(atBaseAddr32B, TRegIndex(4), Dest);
        WriteSIB(Scale, Base, Index);
      end;

      FBuffer.Write<Integer>(Offset);
    end;
  end
  else
  begin
    if (Scale = nsNo) and (Index = Base) then
    begin
      WriteModRM(atIndirAddr, Base, Dest);

      if Index = rEsp then
        WriteSIB(Scale, Index, Index);
    end
    else
    begin
      WriteModRM(atIndirAddr, TRegIndex(4), Dest);
      WriteSIB(Scale, Base, Index);
    end;
  end;
end;

procedure TCompiler.WriteCall(Reg: TRegIndex);
begin
  FBuffer.Write<Byte>($FF);
  FBuffer.Write<Byte>($D0 or Byte(Reg));
end;

procedure TCompiler.WriteCmp(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($39);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteCmp(Dest: TRegIndex; Value: Integer);
begin
  if IsRel8(Value) then
  begin
    FBuffer.Write<Byte>($83);
    WriteModRM(atRegisters, Dest, TRegIndex(7));
    FBuffer.Write<Byte>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($81);
    WriteModRM(atRegisters, Dest, TRegIndex(7));
    FBuffer.Write<Integer>(Value);
  end;
end;

procedure TCompiler.WriteCmp(Value: Integer; Base, Index: TRegIndex;
  RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($80)
  else
  begin
    if RegSize = msWord then
      WritePrefix(cpRegSize);

    FBuffer.Write<Byte>($81);
  end;

  WriteBase(TRegIndex(7), Base, Index, Scale, Offset);
  WriteImm(Value, RegSize);
end;

procedure TCompiler.WriteCmp(Dest, Base, Index: TRegIndex; Scale: TNumberScale;
  Offset: Integer);
begin
  FBuffer.Write<Byte>($3B);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteCall(Addr: Pointer);

  function Relative(Func, Addr: Pointer): Pointer; inline;
  begin
    Result := Pointer(Integer(Func) - Integer(Addr) - 4);
  end;

begin
  FBuffer.Write<Byte>($E8);
  FBuffer.Write<Integer>(Integer(Relative(Addr, @TBytes(FBuffer.Data)[FBuffer.Position])));
end;

procedure TCompiler.WriteDec(Dest: TRegIndex);
begin
  FBuffer.Write<Byte>($48 or Byte(Dest));
end;

procedure TCompiler.WritePush(Source: TRegIndex; Dereference: Boolean);
begin
  if Dereference then
  begin
    FBuffer.Write<Byte>($FF);

    if Source = rEsp then
    begin
      WriteModRM(atIndirAddr, Source, TRegIndex(6));
      WriteSIB(nsNo, Source, Source);
    end
    else
    if Source = rEbp then
    begin
      WriteModRM(atBaseAddr8B, Source, TRegIndex(6));
      FBuffer.Write<Byte>(0);
    end
    else
      WriteModRM(atIndirAddr, Source, TRegIndex(6));
  end
  else
    FBuffer.Write<Byte>($50 or Byte(Source));
end;

procedure TCompiler.WriteRet(Bytes: Integer);
begin
  if Bytes <> 0 then
  begin
    FBuffer.Write<Byte>($C2);
    FBuffer.Write<Word>(Bytes);
  end
  else
    FBuffer.Write<Byte>($C3);
end;

procedure TCompiler.WriteSetCC(Dest: TRegIndex; Condition: TCondition);
begin
  FBuffer.Write<Byte>($0F);
  FBuffer.Write<Byte>($90 or Byte(Condition));
  WriteModRM(atRegisters, Dest, TRegIndex(3));
end;

procedure TCompiler.WriteShl(Reg: TRegIndex; Count: Byte);
begin
  FBuffer.Write<Byte>($C1);
  WriteModRM(atRegisters, Reg, TRegIndex(4));
  FBuffer.Write<Byte>(Count);
end;

procedure TCompiler.WriteShr(Reg: TRegIndex; Count: Byte);
begin
  FBuffer.Write<Byte>($C1);
  WriteModRM(atRegisters, Reg, TRegIndex(5));
  FBuffer.Write<Byte>(Count);
end;

procedure TCompiler.WriteSIB(Scale: TNumberScale; Base, Index: TRegIndex);
begin
  FBuffer.Write<Byte>(Byte(Scale) shl 6 or Byte(Index) shl 3 or Byte(Base));
end;

procedure TCompiler.WriteStoS(Prefix: TCmdPrefix; Count: TAddrSize);
begin
  WritePrefix(Prefix);
  WriteStoS(Count);
end;

procedure TCompiler.WriteStoS(Count: TAddrSize);
begin
  case Count of
    msByte: FBuffer.Write<Byte>($AA);
    msWord:
    begin
      WritePrefix(cpRegSize);
      FBuffer.Write<Byte>($AB);
    end;
    msDWord: FBuffer.Write<Byte>($AB);
  end;
end;

procedure TCompiler.WriteSub(Dest: TRegIndex; Value: Integer);
begin
  if not IsRel8(Value) then
  begin
    if Dest = rEax then
      FBuffer.Write<Byte>($2D) // eax opcode
    else
    begin
      FBuffer.Write<Byte>($81); // default opcode
      WriteModRM(atRegisters, Dest, TRegIndex(5));
    end;

    FBuffer.Write<Integer>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($83);
    WriteModRM(atRegisters, Dest, TRegIndex(5));
    FBuffer.Write<Byte>(Value);
  end;
end;

procedure TCompiler.WriteSub(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($29);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteSub(Value: Integer; Base, Index: TRegIndex;
  RegSize: TAddrSize; Scale: TNumberScale; Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($80)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($81);
  end
  else
    FBuffer.Write<Byte>($81);

  WriteBase(TRegIndex(5), Base, Index, Scale, Offset);
  WriteImm(Value, RegSize);
end;

procedure TCompiler.WriteSub(Dest, Base, Index: TRegIndex; RegSize: TAddrSize; Scale: TNumberScale;
  Offset: Integer);
begin
  if RegSize = msByte then
    FBuffer.Write<Byte>($2A)
  else
  if RegSize = msWord then
  begin
    WritePrefix(cpRegSize);
    FBuffer.Write<Byte>($2B);
  end
  else
    FBuffer.Write<Byte>($2B);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteTest(Dest: TRegIndex; Value: Integer);
begin
  if Dest = rEax then
  begin
    FBuffer.Write<Byte>($A9);
    FBuffer.Write<Integer>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($F7);
    WriteModRM(atRegisters, Dest, TRegIndex(0));
    FBuffer.Write<Integer>(Value);
  end;
end;

procedure TCompiler.WriteTest(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($85);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WriteXchg(Dest, Source: TRegIndex);
begin
  if Dest = rEax then
    FBuffer.Write<Byte>($90 or Byte(Source))
  else
  begin
    FBuffer.Write<Byte>($87);
    WriteModRM(atRegisters, Dest, Source);
  end;
end;

procedure TCompiler.WriteXchg(Dest: TRegIndex; Address: Pointer);
begin
  FBuffer.Write<Byte>($87);
  WriteModRM(atIndirAddr, TRegIndex(5), Dest);
  FBuffer.Write<Pointer>(Address);
end;

procedure TCompiler.WriteXor(Dest, Base, Index: TRegIndex; Scale: TNumberScale;
  Offset: Integer);
begin
  FBuffer.Write<Byte>($33);

  WriteBase(Dest, Base, Index, Scale, Offset);
end;

procedure TCompiler.WriteXor(Dest: TRegIndex; Value: Integer);
begin
  if IsRel8(Value) then
  begin
    FBuffer.Write<Byte>($83);
    WriteModRM(atRegisters, Dest, TRegIndex(6));
    FBuffer.Write<Byte>(Value);
  end
  else
  begin
    FBuffer.Write<Byte>($81);
    WriteModRM(atRegisters, Dest, TRegIndex(6));
    FBuffer.Write<Integer>(Value);
  end;
end;

procedure TCompiler.WriteXor(Dest, Source: TRegIndex);
begin
  FBuffer.Write<Byte>($31);
  WriteModRM(atRegisters, Dest, Source);
end;

procedure TCompiler.WritePop(Source: TRegIndex);
begin
  FBuffer.Write<Byte>($58 or Byte(Source));
end;

procedure TCompiler.WritePop(Addr: Pointer);
begin
  FBuffer.Write<Byte>($8F);
  WriteModRM(atIndirAddr, TRegIndex(5), TRegIndex(0));
  FBuffer.Write<Pointer>(Addr);
end;

procedure TCompiler.WritePrefix(Prefix: TCmdPrefix);
begin
  FBuffer.Write<Byte>(Byte(Prefix));
end;

procedure TCompiler.WritePush(Value: Integer; Dereference: Boolean = False);
begin
  if Dereference then
  begin
    FBuffer.Write<Byte>($FF);
    FBuffer.Write<Byte>($35);
    FBuffer.Write<Integer>(Value);
  end
  else
  begin
    if IsRel8(Value) then
    begin
      FBuffer.Write<Byte>($6A);
      FBuffer.Write<Byte>(Value);
    end
    else
    begin
      FBuffer.Write<Byte>($68);
      FBuffer.Write<Integer>(Value);
    end;
  end;
end;

{ TTargetHelper }

function TTargetHelper.ToString: string;
begin
  case Self of
    tWin32: Result := 'Win32';
    tWin64: Result := 'Win64';
    tLinux: Result := 'Linux'
  else Result := 'Unknown';
  end;
end;

end.
